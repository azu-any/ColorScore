import UIKit
import CoreImage
import Vision

class TeamClassifier {
    
    private let context = CIContext()
    private var visionModel: VNCoreMLModel
    private var kmeans: SimpleKMeans?
    var playerTeamDict: [UUID: Int] = [:]
    
    private var clusterMap: [Int: Int]?

    init() {
        // Load the SiglipVision model from the app bundle.
//        guard let model = try? SiglipVision(configuration: MLModelConfiguration()).model,
        guard let model = try? MobileClip(configuration: MLModelConfiguration()).model,
              let visionModel = try? VNCoreMLModel(for: model) else {
            fatalError("Failed to load the SiglipVision Core ML model from the bundle.")
        }
        self.visionModel = visionModel
    }
    
    /// Extracts the average color from the *center 50%* of the image, ignoring the border.
    private func extractCenterColor(from crop: CIImage) -> [Double] {
        let ciImage = crop // CIImage(cgImage: crop)
        
        // 1. Create a smaller rectangle in the center of the image
        let extent = ciImage.extent
        let insetX = extent.width * 0.25 // Inset 25% on each side
        let insetY = extent.height * 0.25
        
        let centerRect = extent.insetBy(dx: insetX, dy: insetY)
        
        // 2. Create the "average" filter, but give it the *center* extent
        let extentVector = CIVector(x: centerRect.origin.x,
                                  y: centerRect.origin.y,
                                  z: centerRect.size.width,
                                  w: centerRect.size.height)
        
        guard let filter = CIFilter(name: "CIAreaAverage",
                                    parameters: [kCIInputImageKey: ciImage, kCIInputExtentKey: extentVector]),
              let outputImage = filter.outputImage else {
            return [0.0, 0.0, 0.0]
        }

        // 3. Get the 1x1 average pixel
        var bitmap = [UInt8](repeating: 0, count: 4)
        self.context.render(outputImage,
                            toBitmap: &bitmap,
                            rowBytes: 4,
                            bounds: CGRect(x: 0, y: 0, width: 1, height: 1),
                            format: .RGBA8,
                            colorSpace: nil)
        
        // 4. Convert to [Double]
        let red = Double(bitmap[0]) / 255.0
        let green = Double(bitmap[1]) / 255.0
        let blue = Double(bitmap[2]) / 255.0
        
        return [red, green, blue]
    }
    

    /// Finds the most dominant color in the crop.
    private func extractDominantColor(from crop: CIImage) -> [Double] {
        let ciImage = crop
        
//        guard !ciImage.extent.isEmpty else {
//                print("Extracted dominant color: [0, 0, 0] (Received an empty crop)")
//                return [0.0, 0.0, 0.0]
//            }
        
        // 1. Downscale
        let scale = 50.0 / ciImage.extent.width
        guard let scaleFilter = CIFilter(name: "CILanczosScaleTransform",
                                         parameters: [kCIInputImageKey: ciImage, kCIInputScaleKey: scale, kCIInputAspectRatioKey: 1.0]),
              let scaledImage = scaleFilter.outputImage else {
            return [0.0, 0.0, 0.0]
        }
        
        // 2. CIKMeans
        guard let kmeansFilter = CIFilter(name: "CIKMeans",
                                          parameters: [
                                              kCIInputImageKey: scaledImage,
                                              "inputCount": 3 // Find 3 dominant colors
                                          ]),
              let kmeansOutput = kmeansFilter.outputImage else {
            return [0.0, 0.0, 0.0]
        }

        // 3. Get the 3 dominant colors
        let dominantColors = kmeansFilter.value(forKey: "outputClusterCenters") as? [CIColor] ?? []
        
        // 4. CIAreaHistogram
        guard let histogramFilter = CIFilter(name: "CIAreaHistogram",
                                             parameters: [
                                                 kCIInputImageKey: kmeansOutput,
                                                 kCIInputExtentKey: kmeansOutput.extent,
                                                 "inputCount": 3,
                                                 "inputScale": 1.0
                                             ]),
              let histogramData = histogramFilter.outputImage else {
            return [0.0, 0.0, 0.0]
        }

        // 5. Read histogram data
        var bitmap = [Float](repeating: 0, count: 3 * 4)
        let rowBytes = 3 * 4 * MemoryLayout<Float>.size
        
        self.context.render(histogramData,
                            toBitmap: &bitmap,
                            rowBytes: rowBytes,
                            bounds: histogramData.extent,
                            format: .RGBAf,
                            colorSpace: nil)

        let counts = [
            UInt32(bitmap[0]), // Count for color 0
            UInt32(bitmap[4]), // Count for color 1
            UInt32(bitmap[8])  // Count for color 2
        ]
        
        // --- THIS IS THE FIX ---
        // 6. Find the color with the highest count, period.
        var bestColor: [Double] = [0.0, 0.0, 0.0]
        var maxCount: UInt32 = 0
        
        for (i, color) in dominantColors.enumerated() {
            guard i < counts.count else { continue }
            let count = counts[i]
            
            // Whichever color has the most pixels wins.
            if count > maxCount {
                maxCount = count
                bestColor = [Double(color.red), Double(color.green), Double(color.blue)]
            }
        }
        
        // Log what we found
        print("Extracted dominant color: \(bestColor) with count \(maxCount)")
        return bestColor
    }
    // MARK: - Public Methods

    func fit(on crops: [CIImage]) async throws {
        
        // Limit number of crops
        let maxCropsToUse = 2000
        let croppedCrops = crops.prefix( maxCropsToUse)
        print("Fitting TeamClassifier on \(croppedCrops.count) player crops...")
        
        let features = croppedCrops.map { extractCenterColor(from: $0) }
        // --- (No 'await' needed, this is all synchronous) ---
        
        guard features.count > 1 else {
            print("❌ Fit Error: Not enough features collected. Count: \(features.count)")
            throw ClassifierError.notEnoughData
        }
                
        // --- MODIFIED: Find 3 clusters (2 teams + 1 noise) ---
        let nClustersToFind = 2
        var kmeans = SimpleKMeans(nClusters: nClustersToFind)
        
        // 1. Run fit and get the assignments for all points
        let assignments = kmeans.fit(points: features)
        
        // 2. Count the number of points in each cluster
        // This gives [ClusterID: Count], e.g., [0: 150, 1: 130, 2: 20]
        let clusterCounts = Dictionary(grouping: assignments, by: { $0 })
            .mapValues { $0.count }
        
        print("KMeans finished. Cluster counts: \(clusterCounts)")

        // 3. Find the two largest clusters
        let sortedClusters = clusterCounts.sorted { $0.value > $1.value }
        
        guard sortedClusters.count >= 2 else {
            print("❌ Fit Error: Could not find two distinct clusters. Found: \(sortedClusters.count)")
            throw ClassifierError.notEnoughData
        }
        
        // 4. Get the cluster IDs for the top two (our "real" teams)
        let teamAClusterID = sortedClusters[0].key
        let teamBClusterID = sortedClusters[1].key
        
        // 5. Create the map
        // This maps the "raw" ID (e.g., 2) to our "team" ID (e.g., 0)
        self.clusterMap = [
            teamAClusterID: 0,
            teamBClusterID: 1
        ]
        
        // 6. Save the fitted kmeans
        self.kmeans = kmeans
        
        self.playerTeamDict.removeAll()
        print("✅ TeamClassifier fit complete. Mapped teams \(teamAClusterID) -> 0 and \(teamBClusterID) -> 1.")
    }

    func predict(for crop: CIImage, playerID: UUID) async throws -> Int {
        // 1. Check cache (unchanged)
        if let teamID = playerTeamDict[playerID] {
            return teamID
        }
        
        guard let kmeans = self.kmeans, let clusterMap = self.clusterMap else {
            throw ClassifierError.modelNotFitted
        }

        let features = extractCenterColor(from: crop)
        
        // 3. Get the "raw" cluster ID (e.g., 0, 1, or 2)
        let rawTeamID = kmeans.predict(features)
        
        // 4. Map the raw ID to our final team ID (0 or 1)
        guard let finalTeamID = clusterMap[rawTeamID] else {
            // This object is in a "noise" cluster (e.g., cluster 2)
            // It's not Team A or Team B.
            throw ClassifierError.noiseDetected
        }
        
        // 5. Cache the final ID
        playerTeamDict[playerID] = finalTeamID
        
        return finalTeamID
    }

    // MARK: - Core ML Feature Extraction

    /// Runs the Siglip model on an array of images concurrently. (Used by fit)
    private func extractFeatures(from crops: [CGImage]) async throws -> [[Double]] {
        try await withThrowingTaskGroup(of: [Double].self) { group in
            var allFeatures: [[Double]] = []

            for crop in crops {
                group.addTask {
                    // --- MODIFIED ---
                    // Call our new singular function
                    try await self.extractFeature(from: crop)
                }
            }
            
            for try await features in group {
                allFeatures.append(features)
            }
            
            return allFeatures
        }
    }
    
    // --- NEW FUNCTION ---
    /// Performs a VNCoreMLRequest for a SINGLE image to get its feature vector.
    private func extractFeature(from image: CGImage) async throws -> [Double] {
        return try await withCheckedThrowingContinuation { continuation in
            let request = VNCoreMLRequest(model: self.visionModel) { request, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                guard let results = request.results as? [VNCoreMLFeatureValueObservation],
                      let featureObservation = results.first,
                      let multiArray = featureObservation.featureValue.multiArrayValue else {
                    continuation.resume(throwing: ClassifierError.featureExtractionFailed)
                    return
                }
                
                // Convert MLMultiArray (Float) to [Double]
                let pointer = multiArray.dataPointer.bindMemory(to: Float.self, capacity: multiArray.count)
                let buffer = UnsafeBufferPointer(start: pointer, count: multiArray.count)
                let features = buffer.map { Double($0) }
                
                continuation.resume(returning: features)
            }

            request.imageCropAndScaleOption = .scaleFill
            let handler = VNImageRequestHandler(cgImage: image)
            
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
    
    enum ClassifierError: Error {
        case modelNotFitted
        case featureExtractionFailed
        case notEnoughData
        case noiseDetected
    }
}
