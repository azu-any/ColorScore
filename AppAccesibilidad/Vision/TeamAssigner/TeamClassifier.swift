import UIKit
import CoreImage
import Vision

class TeamClassifier {
    
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

    // MARK: - Public Methods

    /// "Trains" the classifier by learning the two team clusters from a set of player images.
    /// - Parameter crops: An array of CGImage crops, one for each player.
    func fit(on crops: [CGImage]) async throws {
            print("Fitting TeamClassifier on \(crops.count) player crops...")
            
            let features = try await extractFeatures(from: crops)
            guard features.count > 1 else {
                throw ClassifierError.notEnoughData
            }
            
            // --- MODIFIED: Find 3 clusters (2 teams + 1 noise) ---
            let nClustersToFind = 3
            var kmeans = SimpleKMeans(nClusters: nClustersToFind)
            
            // 1. Run fit and get the assignments for all points
            let assignments = kmeans.fit(points: features)
            
            // 2. Count the number of points in each cluster
            // This gives [ClusterID: Count], e.g., [0: 150, 1: 130, 2: 20]
            let clusterCounts = Dictionary(grouping: assignments, by: { $0 })
                .mapValues { $0.count }

            // 3. Find the two largest clusters
            let sortedClusters = clusterCounts.sorted { $0.value > $1.value }
            
            guard sortedClusters.count >= 2 else {
                print("Could not find two distinct clusters.")
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

    /// Predicts the team for a single player.
    /// - Parameters:
    ///   - crop: The CGImage of the player to classify.
    ///   - playerID: The unique tracking ID for the player.
    /// - Returns: The team ID (0 or 1).
    /// Predicts the team for a single player.
    func predict(for crop: CGImage, playerID: UUID) async throws -> Int {
            // 1. Check cache (unchanged)
            if let teamID = playerTeamDict[playerID] {
                return teamID
            }
            
            guard let kmeans = self.kmeans, let clusterMap = self.clusterMap else {
                throw ClassifierError.modelNotFitted
            }

            // 2. Extract features (unchanged)
            let features = try await extractFeature(from: crop)
            
            // --- MODIFIED: Map the prediction ---
            
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
