//
//  VisionProcessor.swift
//  AppAccesibilidad
//
//  Created by Azuany Mila Cerón on 11/6/25.
//

import AVFoundation
import UIKit
import Vision

enum VisionTrackerProcessorError: Error {
    case readerInitializationFailed
    case firstFrameReadFailed
    case objectTrackingFailed
    case rectangleDetectionFailed
}


protocol VisionTrackerProcessorDelegate: AnyObject {
    func displayFrame(_ frame: CVPixelBuffer?, withAffineTransform transform: CGAffineTransform, rects: [TrackedPolyRect]?)
    func displayFrameCounter(_ frame: Int)
    func didFinifshTracking()
}


class VisionProcessor {
    var visionModel: VNCoreMLModel!
    var trackingLevel = VNRequestTrackingLevel.fast
    var objectsToTrack = [TrackedPolyRect]()
    weak var delegate: VisionTrackerProcessorDelegate?
    
    
    private var yoloRequest: VNCoreMLRequest? // Your existing detection request
    private var tracker: Any?
    
    private var teamClassifier: TeamClassifier!
    private var trainingCrops: [CGImage] = []

    
    init() {
        // Load model
        guard let modelURL = Bundle.main.url(forResource: "football-detection-mini", withExtension: "mlmodelc") else {
            fatalError("Model file is missing")
        }
        do {
            let model = try MLModel(contentsOf: modelURL)
            visionModel = try VNCoreMLModel(for: model)
            
            yoloRequest = VNCoreMLRequest(model: visionModel)
            
            self.teamClassifier = TeamClassifier()
            
        } catch {
            fatalError("Failed to load Vision ML model: \(error)")
        }
    }
    
    
    func process(_ pixelBuffer: CVPixelBuffer, state: DetectionState) {
        
        guard let observations = yoloRequest?.results as? [VNRecognizedObjectObservation] else { return }
        let playerObservations = observations.filter { $0.labels.first?.identifier == "player" }
        switch state {
        case .preTraining:
            // Do nothing, just show the boxes
            // You can draw bounding boxes for all 'player' detections
            break
            
        case .isTraining:
            // Collect crops for training
            let crops = extractCrops(from: pixelBuffer, for: playerObservations)
            self.trainingCrops.append(contentsOf: crops)
            
        case .isDetecting:
            // **Run live tracking and prediction**
            
            // 1. Update your tracker with playerObservations
            guard let results = yoloRequest?.results as? [VNRecognizedObjectObservation] else { return }
//            let currentTrackersInfo = self.trackedObjectInfo
//            var matchedUUIDs: Set<UUID> = []
            
            // 2. Get crops for *currently* tracked players
//            let crops = extractCrops(from: pixelBuffer, for: playerObservations)
            
//            Task {
//                for crop in crops {
//                    do {
//                        let teamID = try await self.teamClassifier.predict(for: crop, playerID: uuid)
//                        self.trackedObjectInfo[uuid]?.teamID = teamID
//                    } catch {
//                        self.trackedObjectInfo[uuid]?.teamID = nil
//                    }
//                }
//            }
//            // 3. Predict the team for each crop
//            let teamIDs = teamClassifier.predict(for: crop, )
            
            // 4. Draw annotations with colors
            // You would now loop through your tracked players,
            // match them to their teamID, and draw a colored box.
            // drawAnnotations(players, teamIDs)
            break
        }
//        var inputObservations = [UUID: VNDetectedObjectObservation]()
//        var trackedObjects = [UUID: TrackedPolyRect]()
//        
//        for object in self.objectsToTrack {
//            let inputObservation = VNDetectedObjectObservation(boundingBox: object.boundingBox)
//            inputObservations[inputObservation.uuid] = inputObservation
//            trackedObjects[inputObservation.uuid] = object
//        }
//        
//        let requestHandler = VNSequenceRequestHandler()
//        var frames = 1
//        var trackingFailedForAtLeastOneObject = false
//        
//        
//        while true {
//            delegate?.displayFrameCounter(frames)
//            frames += 1
//            
//            var rects = [TrackedPolyRect]()
//            var trackingRequests = [VNRequest]()
//            for inputObservation in inputObservations {
//                let request = VNTrackObjectRequest(detectedObjectObservation: inputObservation.value)
//                request.trackingLevel = trackingLevel
//             
//                trackingRequests.append(request)
//            }
//            
//            // Perform array of requests
//            do {
//                try requestHandler.perform(trackingRequests, on: pixelBuffer, orientation: .up)
//            } catch {
//                trackingFailedForAtLeastOneObject = true
//            }
//
//            for processedRequest in trackingRequests {
//                guard let results = processedRequest.results else {
//                    continue
//                }
//                guard let observation = results.first as? VNDetectedObjectObservation else {
//                    continue
//                }
//                // Assume threshold = 0.5f
//                let rectStyle: TrackedPolyRectStyle = observation.confidence > 0.5 ? .solid : .dashed
//                let knownRect = trackedObjects[observation.uuid]!
//
//                rects.append(TrackedPolyRect(observation: observation, color: knownRect.color, style: rectStyle))
//                // Initialize inputObservation for the next iteration
//                inputObservations[observation.uuid] = observation
//            }
//
//            // Draw results
//            delegate?.displayFrame(pixelBuffer, withAffineTransform: .identity, rects: rects)
//
//        }
        
//        if trackingFailedForAtLeastOneObject {
//            throw VisionTrackerProcessorError.objectTrackingFailed
//        }
//        let request = VNCoreMLRequest(model: visionModel) { (request, error) in
//            try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
//        }
    }
    func performTracking() {
        var inputObservations = [UUID: VNDetectedObjectObservation]()
        var trackedObjects = [UUID: TrackedPolyRect]()
    }
    
    
    func trainClassifier(completion: @escaping (Bool) -> Void) {
        if trainingCrops.isEmpty {
            print("Error: No player crops were collected.")
            completion(false)
            return
        }
        
        print("Starting to fit classifier on \(trainingCrops.count) crops.")
        
        // This can be slow, so run it async
        Task {
            do {
                try await self.teamClassifier.fit(on: self.trainingCrops)
                
                // Clear memory
                self.trainingCrops.removeAll()
                
                DispatchQueue.main.async {
                    print("Classifier fitting complete.")
                    completion(true)
                }
            }
        }
    }
    
    // 6. HELPER: This is your "get_crops" equivalent
    private func extractCrops(from pixelBuffer: CVPixelBuffer, for observations: [VNRecognizedObjectObservation]) -> [CGImage] {
        
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let imageSize = ciImage.extent.size
        
        var crops: [CGImage] = []
        
        for observation in observations {
            // Convert normalized rect (0-1) to pixel rect
            let boundingBox = observation.boundingBox
            let pixelRect = VNImageRectForNormalizedRect(boundingBox,
                                                         Int(imageSize.width),
                                                         Int(imageSize.height))
            
            // Crop the CIImage
            let crop = ciImage.cropped(to: pixelRect)
            let context = CIContext()
            guard let croppedCGImage = context.createCGImage(crop, from: crop.extent) else {
                print("Error creating CGImage from CIImage")
                continue
            }
            crops.append(croppedCGImage)
        }
        return crops
    }
}
