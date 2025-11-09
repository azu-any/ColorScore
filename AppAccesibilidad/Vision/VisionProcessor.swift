//
//  VisionProcessor.swift
//  AppAccesibilidad
//
//  Created by Azuany Mila Cerón on 11/6/25.
//

import Foundation
import Vision
import UIKit
import AVFoundation

// Defines the communication channel from the processing service back to the view controller
protocol VisionProcesorDelegate: AnyObject {
    
    /// Called when the service has successfully processed a frame and found observations.
    /// - Parameters:
    ///   - service: The service that completed the request.
    ///   - results: An array of recognized object observations.
    ///   - buffer: Frame from the camera
    func visionService(_ service: VisionProcessor, didFind results: [VNRecognizedObjectObservation], on buffer: CVPixelBuffer)
    
    /// Called when the service encounters an error during processing.
    /// - Parameters:
    ///   - service: The service that failed.
    ///   - error: The error that occurred.
    func visionService(_ service: VisionProcessor, didFailWithError error: Error)
}


class VisionProcessor {
    
    // MARK: - Delegate
    weak var delegate: VisionProcesorDelegate?
    
    let yoloModelName = "best" // "football-detection-mini"
    // Vision requests
    var requests = [VNRequest]()
    // A serial dispatch queue to perform requests on.
    // This prevents blocking the camera's sample buffer queue.
    private let visionQueue = DispatchQueue(label: "Xcookers.visionQueue")
    
    private var isProcessing: Bool = false
    
    
    @discardableResult
    func setupVision() -> NSError? {
        
        guard let modelURL = Bundle.main.url(forResource: yoloModelName, withExtension: "mlmodelc")
        else {
            return NSError(
                domain: "VisionProcessingService",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Model file '\(yoloModelName).mlmodelc' is missing"]
            )
        }
        
        do {
            let visionModel = try VNCoreMLModel(for: MLModel(contentsOf: modelURL))
            let objectRecognition = VNCoreMLRequest(model: visionModel)
            self.requests = [objectRecognition]
            
        } catch let error as NSError {
            print("Model loading went wrong: \(error)")
            return error
        }
        
        return nil
    }
    
    /// Performs the Vision request on a given pixel buffer.
    /// This method is asynchronous and non-blocking.
    func performRequest(on pixelBuffer: CVPixelBuffer, orientation: CGImagePropertyOrientation) {
        guard !isProcessing else { return }
        
        // Run the request on our dedicated serial queue
        visionQueue.async { [weak self] in
            guard let self = self else { return }
            
            // Mark as processing
            self.isProcessing = true
            defer {
                self.isProcessing = false
            }
            
            let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer,
                                                              orientation: orientation,
                                                              options: [:])
            
            do {
                // Perform the request *synchronously* on this background queue
                try imageRequestHandler.perform(self.requests)
                
                guard let results = self.requests.first?.results as? [VNRecognizedObjectObservation] else {
                    // No error, but no results.
                    return
                }
                
                // --- SUCCESS ---
                DispatchQueue.main.async {
                    self.delegate?.visionService(self, didFind: results, on: pixelBuffer)
                }
            } catch {
                // --- FAILED ---
                print("Failed to perform Vision request: \(error)")
                DispatchQueue.main.async {
                    self.delegate?.visionService(self, didFailWithError: error)
                }
                self.isProcessing = false
            }
        }
    }
    
    
    /// Thread-safe method to swap the active Vision requests
    func updateRequests(_ newRequests: [VNRequest]) {
        // With visionQueue to prevent conflicts
        visionQueue.async {
            self.requests = newRequests
        }
    }
    
}
