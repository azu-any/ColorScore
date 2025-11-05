//
//  VisionManager.swift
//
//


import SwiftUI
import Vision

class VisionManager {

    private var visionModel: VNCoreMLModel!
    private var request: VNCoreMLRequest!
    
    private var isProcessing: Bool = false
    private var addToObservationStream: (([VNRecognizedObjectObservation]) -> Void)?
    
    lazy var observationStream: AsyncStream<[VNRecognizedObjectObservation]> = {
        AsyncStream { continuation in
            addToObservationStream = { observations in
                continuation.yield(observations)
            }
        }
    }()
    
    
    init() {
        guard let modelURL = Bundle.main.url(forResource: "football-detection-mini", withExtension: "mlmodelc") else {
            fatalError("Model file is missing")
        }
        do {
            let model = try MLModel(contentsOf: modelURL)
            visionModel = try VNCoreMLModel(for: model)
            
            // 1. Create the request and assign its completion handler
            let request = VNCoreMLRequest(model: visionModel) { [weak self] request, error in
                // 2. The requestHandler will call this function when it's done
                self?.handleDetectionResults(request: request, error: error)
            }
            self.request = request

        } catch {
            fatalError("Failed to load Vision ML model: \(error)")
        }
    }
    
    /// This is the completion handler that is called automatically
    /// after `requestHandler.perform()` is finished.
    func handleDetectionResults(request: VNRequest, error: Error?) {
        if let error = error {
            print("Vision request failed: \(error.localizedDescription)")
            return
        }
        
        guard let newDetections = request.results as? [VNRecognizedObjectObservation] else {
            print("Failed to cast results.")
            return
        }
        
        // 3. Send the successful results to the stream
        print("observations: \(newDetections.count)")
        addToObservationStream?(newDetections)
    }
    
    
    func processHumanDetection(_ ciImage: CIImage) {
        if isProcessing { return }
        isProcessing = true // Set the lock

        // Use a Task to move this work off the main thread
        Task {
            // 4. Reset the lock after the task is done
            defer {
                self.isProcessing = false
            }
            
//            let requestHandler = VNImageRequestHandler(ciImage: ciImage, orientation: .up)
            let requestHandler = VNImageRequestHandler(ciImage: ciImage, options: [:])
            do {
                // 5. Perform the request.
                // The results will be delivered to `handleDetectionResults`
                try requestHandler.perform([self.request])
            } catch {
                print("Failed to perform detection: \(error.localizedDescription)")
            }
        }
    }
}
