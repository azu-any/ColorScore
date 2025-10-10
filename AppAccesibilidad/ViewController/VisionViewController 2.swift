////
////  VisionViewController.swift
////  AppAccesibilidad
////
////  Created by Azuany Mila Cerón on 10/6/25.
////
//
//
//import UIKit
//import AVFoundation
//import Vision
//import SwiftUI
//import CoreImage
//
//class VisionViewController: ViewController {
//    
//    private var detectionOverlay: CALayer! = nil
////    private var latestBuffer: CMSampleBuffer? = nil
//    private var pixelBuffer: CVPixelBuffer? = nil
//    private var isClassifierFitted = false
//    
//    private var detectionRequest: VNCoreMLRequest!
//    private var trackedObjects: [UUID: VNTrackObjectRequest] = [:]
//    
//    // Vision parts
//    private var requests = [VNRequest]()
//    private var results = [VNRecognizedObjectObservation]()
////    private let teamAssigner = TeamAssigner()
//    private let teamClassifier = TeamClassifier()
//    
//    private var trackedObjectInfo: [UUID: (box: CGRect, label: String, teamID: Int?)] = [:]
//
//    
//    func setupVision() {
//            guard let modelURL = Bundle.main.url(forResource: "football-detection", withExtension: "mlmodelc") else {
//                fatalError("Model file is missing")
//            }
//            do {
//                let visionModel = try VNCoreMLModel(for: MLModel(contentsOf: modelURL))
//                detectionRequest = VNCoreMLRequest(model: visionModel, completionHandler: handleDetectionResults)
//                detectionRequest.imageCropAndScaleOption = .scaleFill
//            } catch {
//                fatalError("Failed to load Vision ML model: \(error)")
//            }
//        }
//    
//    @objc func calibrateTeamsButtonPressed() {
//        guard let pixelBuffer = self.pixelBuffer else {
//            print("No video frame available for calibration.")
//            return
//        }
//        
//        print("Calibrating teams...")
//        
//        // Run a one-time detection on the current frame to find players to train on.
//        let request = VNCoreMLRequest(model: self.detectionRequest.model) { [weak self] request, error in
//            guard let self = self, let results = request.results as? [VNRecognizedObjectObservation] else { return }
//            
//            let playerObservations = results.filter { $0.labels.first?.identifier == "player" }
//            
//            guard !playerObservations.isEmpty else {
//                print("No players found in the frame to calibrate."); return
//            }
//            
//            Task {
//                do {
//                    let playerCrops = try playerObservations.map { try self.cropImage(from: pixelBuffer, using: $0) }
//                    try await self.teamClassifier.fit(on: playerCrops)
//                    self.isClassifierFitted = true
//                    print("✅ TeamClassifier is now calibrated!")
//                } catch {
//                    print("❌ Calibration failed: \(error)")
//                    self.isClassifierFitted = false
//                }
//            }
//        }
//        
//        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: exifOrientationFromDeviceOrientation())
//        try? handler.perform([request])
//    }
//    
//    /// Handles the results for each individual tracking request.
//    private func handleTrackingResults(for request: VNRequest, error: Error?) {
//        guard let results = request.results as? [VNDetectedObjectObservation],
//              let observation = results.first else { return }
//        
//        guard let uuid = self.trackedObjects.first(where: { $0.value === request })?.key else { return }
//
//        if observation.confidence > 0.5 {
//            // Update the tracker with the new position for the next frame.
//            self.trackedObjects[uuid]?.inputObservation = observation
//            
//            // Update the info for drawing.
//            self.trackedObjectInfo[uuid]?.box = observation.boundingBox
//            
//            // If it's a player and teams are calibrated, run classification.
//            if self.isClassifierFitted && self.trackedObjectInfo[uuid]?.label == "player" {
//                classifyPlayer(with: uuid, observation: observation)
//            }
//        } else {
//            // The tracker lost the object.
//            self.trackedObjects.removeValue(forKey: uuid)
//            self.trackedObjectInfo.removeValue(forKey: uuid)
//        }
//        
//        // Update the UI on the main thread.
//        updateDetectionOverlay()
//    }
//    
//    /// Runs the initial object detection model to find new objects.
//    private func performDetection(on pixelBuffer: CVPixelBuffer, orientation: CGImagePropertyOrientation) {
//        let requestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: orientation, options: [:])
//        do {
//            try requestHandler.perform([self.detectionRequest])
//        } catch {
//            print("Failed to perform detection: \(error.localizedDescription)")
//        }
//    }
//    
//    /// Runs the active tracking requests on the current frame.
//    private func performTracking(on pixelBuffer: CVPixelBuffer, orientation: CGImagePropertyOrientation) {
//        let requests = Array(self.trackedObjects.values)
//        if requests.isEmpty { return }
//        
//        DispatchQueue.global(qos: .userInitiated).async {
//            let requestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: orientation, options: [:])
//            do {
//                try requestHandler.perform(requests)
//            } catch {
//                print("Failed to perform tracking: \(error.localizedDescription)")
//            }
//        }
//    }
//    
//    /// Handles the results of the initial detection request.
//    private func handleDetectionResults(for request: VNRequest, error: Error?) {
//        guard let results = request.results as? [VNRecognizedObjectObservation] else { return }
//        
//        var newTrackers: [UUID: VNTrackObjectRequest] = [:]
//        var newTrackedInfo: [UUID: (box: CGRect, label: String, teamID: Int?)] = [:]
//        
//        for observation in results where observation.confidence > 0.6 {
//            let uuid = UUID()
//            let trackRequest = VNTrackObjectRequest(detectedObjectObservation: observation, completionHandler: self.handleTrackingResults)
//            newTrackers[uuid] = trackRequest
//            
//            let label = observation.labels.first?.identifier ?? "Unknown"
//            newTrackedInfo[uuid] = (observation.boundingBox, label, nil)
//        }
//        
//        self.trackedObjects = newTrackers
//        self.trackedObjectInfo = newTrackedInfo
//        
//        updateDetectionOverlay()
//    }
//    
//    func drawVisionRequestResults(_ results: [Any]) {
//        CATransaction.begin()
//        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
//        detectionOverlay.sublayers = nil // remove all the old recognized objects
//        for observation in results where observation is VNRecognizedObjectObservation {
//            guard let objectObservation = observation as? VNRecognizedObjectObservation else {
//                continue
//            }
//            
//            guard objectObservation.confidence > 0.5 else { continue }
//            
//            // Select only the label with the highest confidence.
//            let topLabelObservation = objectObservation.labels[0]
//            let objectBounds = VNImageRectForNormalizedRect(objectObservation.boundingBox, Int(bufferSize.width), Int(bufferSize.height))
//            
//            let shapeLayer = self.createShapeLayerWithBounds(objectBounds, topLabelObservation.identifier)
//            
//            let textLayer = self.createTextSubLayerInBounds(objectBounds,
//                                                            identifier: topLabelObservation.identifier,
//                                                            confidence: topLabelObservation.confidence)
//            shapeLayer.addSublayer(textLayer)
//            detectionOverlay.addSublayer(shapeLayer)
//        }
//        self.updateLayerGeometry()
//        CATransaction.commit()
//    }
//    
//    override func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
//            guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
//            self.pixelBuffer = pixelBuffer
//            let exifOrientation = exifOrientationFromDeviceOrientation()
//            
//            // If we are not tracking any objects, run detection. Otherwise, track.
//            if trackedObjects.isEmpty {
//                performDetection(on: pixelBuffer, orientation: exifOrientation)
//            } else {
//                performTracking(on: pixelBuffer, orientation: exifOrientation)
//            }
//        }
//    
//    override func setupAVCapture() {
//        super.setupAVCapture()
//        
//        // setup Vision parts
//        setupLayers()
//        updateLayerGeometry()
//        setupVision()
//        
//        // start the capture
//        startCaptureSession()
//    }
//    
//    func setupLayers() {
//        detectionOverlay = CALayer() // container layer that has all the renderings of the observations
//        detectionOverlay.name = "DetectionOverlay"
//        detectionOverlay.bounds = CGRect(x: 0.0,
//                                         y: 0.0,
//                                         width: bufferSize.width,
//                                         height: bufferSize.height)
//        detectionOverlay.position = CGPoint(x: rootLayer.bounds.midX, y: rootLayer.bounds.midY)
//        rootLayer.addSublayer(detectionOverlay)
//    }
//    
//    func updateLayerGeometry() {
//        let bounds = rootLayer.bounds
//        var scale: CGFloat
//        
//        let xScale: CGFloat = bounds.size.width / bufferSize.height
//        let yScale: CGFloat = bounds.size.height / bufferSize.width
//        
//        scale = fmax(xScale, yScale)
//        if scale.isInfinite {
//            scale = 1.0
//        }
//        CATransaction.begin()
//        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
//        
//        // rotate the layer into screen orientation and scale and mirror
//        detectionOverlay.setAffineTransform(CGAffineTransform(rotationAngle: CGFloat(.pi / 2.0)).scaledBy(x: scale, y: -scale))
//        // center the layer
//        detectionOverlay.position = CGPoint(x: bounds.midX, y: bounds.midY)
//        
//        CATransaction.commit()
//        
//    }
//    
//    func createTextSubLayerInBounds(_ bounds: CGRect, identifier: String, confidence: VNConfidence) -> CATextLayer {
//        let textLayer = CATextLayer()
//        textLayer.name = "Object Label"
//        let formattedString = NSMutableAttributedString(string: String(format: "\(identifier)\nConfidence:  %.2f", confidence))
//        let largeFont = UIFont(name: "Helvetica", size: 12.0)!
//        formattedString.addAttributes([NSAttributedString.Key.font: largeFont], range: NSRange(location: 0, length: identifier.count))
//        textLayer.string = formattedString
//        textLayer.bounds = CGRect(x: 0, y: 0, width: bounds.size.height - 10, height: bounds.size.width - 10)
//        textLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
//        textLayer.shadowOpacity = 0.7
//        textLayer.shadowOffset = CGSize(width: 2, height: 2)
//        textLayer.foregroundColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [0.0, 0.0, 0.0, 1.0])
//        textLayer.contentsScale = 2.0 // retina rendering
//        // rotate the layer into screen orientation and scale and mirror
//        textLayer.setAffineTransform(CGAffineTransform(rotationAngle: CGFloat(.pi / 2.0)).scaledBy(x: 1.0, y: -1.0))
//        return textLayer
//    }
//    
////    func createRoundedRectLayerWithBounds(_ bounds: CGRect, _ label: String) -> CALayer {
////        let shapeLayer = CALayer()
////
////        shapeLayer.name = label
////        shapeLayer.cornerRadius = 1
////        shapeLayer.bounds = bounds
////        shapeLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
////
////
////        print(label)
////        switch label {
////        case "ball":
////            shapeLayer.cornerRadius = 3
////            // Make the ball look bigger
////            shapeLayer.bounds = bounds.applying(CGAffineTransform(scaleX: 1.5, y: 1.5))
////            shapeLayer.backgroundColor = UIColor(Color.ball).cgColor
////
////        case "player":
////            shapeLayer.backgroundColor = UIColor(Color.teamA).cgColor
////            
////        default:
////            shapeLayer.bounds = bounds
////            shapeLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
////            shapeLayer.backgroundColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [1.0, 1.0, 0.2, 0.4])
////        }
////        
////        return shapeLayer
////    }
//    
//    func createShapeLayerWithBounds(_ bounds: CGRect, _ label: String, teamID: Int?) -> CAShapeLayer {
//        let shapeLayer = CAShapeLayer()
//        shapeLayer.name = label
//        let path: UIBezierPath
//
//        switch label {
//        case "ball":
//            path = UIBezierPath(ovalIn: bounds)
//            shapeLayer.fillColor = UIColor(Color.ball).cgColor
//        case "player":
//            path = UIBezierPath(rect: bounds)
//            if let id = teamID {
//                let teamColor = (id == 0) ? Color.teamA : Color.blue
//                shapeLayer.fillColor = UIColor(teamColor).withAlphaComponent(0.6).cgColor
//            } else {
//                shapeLayer.fillColor = UIColor.gray.withAlphaComponent(0.5).cgColor
//            }
//        default:
//            path = UIBezierPath(rect: bounds)
//            shapeLayer.fillColor = UIColor.yellow.withAlphaComponent(0.5).cgColor
//        }
//        
//        shapeLayer.path = path.cgPath
//        return shapeLayer
//    }
//    
//    /// Kicks off the asynchronous task to classify a single player.
//    private func classifyPlayer(with uuid: UUID, observation: VNDetectedObjectObservation) {
//        guard let pixelBuffer = self.latestPixelBuffer else { return }
//        
//        Task {
//            do {
//                let crop = try self.cropImage(from: pixelBuffer, using: observation)
//                let teamID = try await self.teamClassifier.predict(for: crop, playerID: uuid)
//                
//                // Store the result. The UI will be updated on the next frame.
//                self.trackedObjectInfo[uuid]?.teamID = teamID
//            } catch {
//                // If prediction fails, we can clear the teamID.
//                self.trackedObjectInfo[uuid]?.teamID = nil
//            }
//        }
//    }
//        
//    
//    /// Central function to clear and redraw all layers based on the latest tracking info.
//    private func updateDetectionOverlay() {
//        DispatchQueue.main.async {
//            CATransaction.begin()
//            CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
//            
//            self.detectionOverlay.sublayers = nil // Clear previous layers
//            
//            for (_, info) in self.trackedObjectInfo {
//                let objectBounds = VNImageRectForNormalizedRect(info.box, Int(self.bufferSize.width), Int(self.bufferSize.height))
//                
//                let shapeLayer = self.createShapeLayerWithBounds(objectBounds, info.label, teamID: info.teamID)
//                self.detectionOverlay.addSublayer(shapeLayer)
//            }
//            
//            self.updateLayerGeometry()
//            CATransaction.commit()
//        }
//    }
//    
//    private func cropImage(from pixelBuffer: CVPixelBuffer, using observation: VNRecognizedObjectObservation) throws -> CGImage {
//            let cropRect = VNImageRectForNormalizedRect(observation.boundingBox, CVPixelBufferGetWidth(pixelBuffer), CVPixelBufferGetHeight(pixelBuffer))
//            
//            let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
//            let croppedCIImage = ciImage.cropped(to: cropRect)
//            
//            let context = CIContext()
//            guard let croppedCGImage = context.createCGImage(croppedCIImage, from: croppedCIImage.extent) else {
//                throw NSError(domain: "VisionViewController", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to crop image."])
//            }
//            
//            return croppedCGImage
//        }
//}
