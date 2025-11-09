import UIKit
import CoreImage
import Vision

class TeamClassifier {
    
    /// A reference to the compiled Core ML model.
    private var visionModel: VNCoreMLModel

    /// The KMeans algorithm for clustering the feature vectors.
    private var kmeans: SimpleKMeans?
    
    /// A cache to store predictions for tracked players.
    var playerTeamDict: [UUID: Int] = [:]

    init() {
        // Load the SiglipVision model from the app bundle.
        guard let model = try? SiglipVision(configuration: MLModelConfiguration()).model,
              let visionModel = try? VNCoreMLModel(for: model) else {
            fatalError("Failed to load the SiglipVision Core ML model from the bundle.")
        }
        self.visionModel = visionModel
    }

    // MARK: - Public Methods

    /// "Trains" the classifier by learning the two team clusters from a set of player images.
    /// - Parameter crops: An array of CGImage crops, one for each player.
    func fit(on crops: [CGImage]) async throws {
        // Limit the number of crops
        let maxCrops = 2000
        let firstCrops = Array(crops.prefix(maxCrops))
        print("Fitting TeamClassifier on \(firstCrops.count) player crops...")
        
        // 1. Extract high-dimensional feature vectors from all player crops.
        let features = try await extractFeatures(from: firstCrops)
        
        guard features.count > 1 else {
            print("Not enough features to fit the model.")
            throw ClassifierError.notEnoughData
        }
        
        // 2. Cluster those features into two teams.
        var kmeans = SimpleKMeans(nClusters: 2)
        kmeans.fit(points: features)
        self.kmeans = kmeans
        
        // Clear the old cache.
        self.playerTeamDict.removeAll()
        
        print("✅ TeamClassifier fit complete.")
    }

    /// Predicts the team for a single player.
    /// - Parameters:
    ///   - crop: The CGImage of the player to classify.
    ///   - playerID: The unique tracking ID for the player.
    /// - Returns: The team ID (0 or 1).
    /// Predicts the team for a single player.
    func predict(for crop: CGImage, playerID: UUID) async throws -> Int {
        // 1. Check cache (Fastest path)
        if let teamID = playerTeamDict[playerID] {
            return teamID
        }
        
        guard let kmeans = self.kmeans else {
            throw ClassifierError.modelNotFitted
        }

        // 2. Extract features (This is now faster)
        // --- MODIFIED ---
        // We now call the singular extractFeature, which has no TaskGroup overhead.
        let features = try await extractFeature(from: crop)
        
        // 3. Predict from features
        let teamID = kmeans.predict(features)
        
        // 4. Cache the result
        playerTeamDict[playerID] = teamID
        
        return teamID
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
    }
}
