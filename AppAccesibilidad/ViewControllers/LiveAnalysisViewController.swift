//
//  LiveAnalysisViewController.swift
//  TestModel Camera
//
//  Created by Azuany Mila Cerón on 11/8/25.
//

import UIKit
import AVFoundation
import Vision

class LiveAnalysisViewController: VisionViewController, CalibrationViewControllerDelegate {
    
    var classifier: TeamClassifier?

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // If we don't have a classifier, we must run calibration
        if self.classifier == nil {
            presentCalibrationView()
        } else {
            // Start camera for detection and classification
            startCaptureSession()
        }
    }
    
    override func visionService(_ service: VisionProcessor, didFind results: [VNRecognizedObjectObservation], on buffer: CVPixelBuffer) {
            
        guard let classifier = self.classifier else {
            // Classifier not ready. Fall back to parent's behavior
            super.visionService(service, didFind: results, on: buffer)
            return
        }
        
        // Classifier is ready
        Task {
            let classifiedResults = await self.classifyDetections(results, from: buffer, classifier: classifier)
            self.drawClassifiedResults(classifiedResults)
        }
    }
    
    private func classifyDetections(
        _ results: [VNRecognizedObjectObservation],
        from buffer: CVPixelBuffer,
        classifier: TeamClassifier
    ) async -> [(VNRecognizedObjectObservation, Int?)] {
            
        let context = CIContext()
        let ciImage = CIImage(cvPixelBuffer: buffer)
        var classifiedResults: [(VNRecognizedObjectObservation, Int?)] = []
        
        for observation in results {
            // Get the crop
            let pixelRect = VNImageRectForNormalizedRect(observation.boundingBox, Int(bufferSize.width), Int(bufferSize.height))
            let croppedCIImage = ciImage.cropped(to: pixelRect)
            
            guard let cgImage = context.createCGImage(croppedCIImage, from: croppedCIImage.extent) else {
                classifiedResults.append((observation, nil)) // Append with nil team
                continue
            }
            
            // Get the unique ID for this observation
            let playerID = observation.uuid
            
            do {
                // Predict the team
                let teamID = try await classifier.predict(for: cgImage, playerID: playerID)
                classifiedResults.append((observation, teamID))
            } catch {
                classifiedResults.append((observation, nil)) // Failed prediction
            }
        }
        return classifiedResults
    }
    
    private func drawClassifiedResults(_ classifiedResults: [(VNRecognizedObjectObservation, Int?)]) {
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        detectionOverlay.sublayers = nil // remove all
        
        for (observation, teamID) in classifiedResults {
            let objectBounds = VNImageRectForNormalizedRect(observation.boundingBox, Int(bufferSize.width), Int(bufferSize.height))
            let objectLabel = observation.labels.first?.identifier ?? "Unknown"
            // Create the bounding box
            let shapeLayer = self.createShapeLayerWithBounds(objectBounds, objectLabel, teamID: teamID)
            
            detectionOverlay.addSublayer(shapeLayer)
        }
        
        self.updateLayerGeometry()
        CATransaction.commit()
    }
    
    private func presentCalibrationView() {
        let calibrationVC = CalibrationViewController()
        calibrationVC.delegate = self
        calibrationVC.modalPresentationStyle = .fullScreen // Present it modally
        self.present(calibrationVC, animated: true)
    }
    
    // MARK: - Capture Output (For Prediction)
    
    override func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // If we don't have a classifier, don't do anything.
        guard let classifier = self.classifier else {
            // You could optionally still show basic detections
            // by calling super.captureOutput(...)
            return
        }
        
        super.captureOutput(output, didOutput: sampleBuffer, from: connection) 
        
        // If we *do* have a classifier, run the full
        // detection + prediction + cropping logic here.
        
        // ... (your logic to run detection) ...
        
        // ... (your logic to get crops) ...
        
        // ... (your logic to call `await classifier.predict(...)`) ...
        
        // ... (your logic to draw results *with team colors*) ...
    }

    // MARK: - CalibrationViewControllerDelegate
    
    func calibrationDidFinish(with classifier: TeamClassifier) {
        print("Received fitted classifier from delegate!")
        self.classifier = classifier
        
        // We are done with calibration, dismiss the VC
        self.dismiss(animated: true, completion: nil)
    }
    
    func calibrationDidCancel() {
        print("Calibration was cancelled.")
        
        // Dismiss the VC
        self.dismiss(animated: true, completion: nil)
        
        // Here, you might want to show an alert to the user
        // telling them they must calibrate to use the app,
        // or just let them tap a "Calibrate" button to try again.
    }
}
