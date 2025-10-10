import UIKit
import CoreImage
import Vision

class TeamClassifier {
    
    /// A reference to the compiled Core ML model.
    private var visionModel: VNCoreMLModel

    /// The KMeans algorithm for clustering the feature vectors.
    private var kmeans: SimpleKMeans?
    
    /// A cache to store predictions for tracked players.
    private var playerTeamDict: [UUID: Int] = [:]

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
        print("Fitting TeamClassifier on \(crops.count) player crops...")
        
        // 1. Extract high-dimensional feature vectors from all player crops.
        let features = try await extractFeatures(from: crops)
        
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
    func predict(for crop: CGImage, playerID: UUID) async throws -> Int {
        // Check the cache first for this tracked player.
        if let teamID = playerTeamDict[playerID] {
            return teamID
        }
        
        guard let kmeans = self.kmeans else {
            throw ClassifierError.modelNotFitted
        }

        // 1. Extract the feature vector for the new player crop.
        guard let features = try await extractFeatures(from: [crop]).first else {
            throw ClassifierError.featureExtractionFailed
        }
        
        // 2. Predict which cluster the features belong to.
        let teamID = kmeans.predict(features)
        
        // 3. Cache the result.
        playerTeamDict[playerID] = teamID
        
        return teamID
    }

    // MARK: - Core ML Feature Extraction

    /// Runs the Siglip model on an array of images concurrently to get their feature embeddings.
    private func extractFeatures(from crops: [CGImage]) async throws -> [[Double]] {
        try await withThrowingTaskGroup(of: [Double].self) { group in
            var allFeatures: [[Double]] = []

            for crop in crops {
                group.addTask {
                    try await self.performVisionRequest(on: crop)
                }
            }
            
            for try await features in group {
                allFeatures.append(features)
            }
            
            return allFeatures
        }
    }
    
    /// Performs a VNCoreMLRequest for a single image to get its feature vector.
    private func performVisionRequest(on image: CGImage) async throws -> [Double] {
        return try await withCheckedThrowingContinuation { continuation in
            let request = VNCoreMLRequest(model: self.visionModel) { request, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                guard let results = request.results as? [VNCoreMLFeatureValueObservation],
                      let featureObservation = results.first,
                      // ❗️IMPORTANT: Check your .mlmodel file in Xcode. The output name
                      // might be different. "output_embedding" is what we set in the script.
                      let multiArray = featureObservation.featureValue.multiArrayValue else {
                    continuation.resume(throwing: ClassifierError.featureExtractionFailed)
                    return
                }
                
                // Convert MLMultiArray to a standard [Double] array.
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
