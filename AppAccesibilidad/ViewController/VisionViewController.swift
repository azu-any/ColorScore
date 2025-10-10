import UIKit
import AVFoundation
import Vision
import SwiftUI

class VisionViewController: ViewController {
    
    // MARK: - Properties
    
    // Vision & Core ML
    private var visionModel: VNCoreMLModel!
    private var detectionRequest: VNCoreMLRequest!
   
    
/// A serial queue to protect access to our tracking dictionaries.
    private let trackerQueue = DispatchQueue(label: "Ccookers.trackerQueue")
    private var trackedObjects: [UUID: VNTrackObjectRequest] = [:]
    private var trackedObjectInfo: [UUID: (box: CGRect, label: String, teamID: Int?)] = [:]
    
    // Team Classification
    private let teamClassifier = TeamClassifier()
    private var isClassifierFitted = false
    
    // UI & Drawing
    private var detectionOverlay: CALayer! = nil
    
    // Data Management
    private var latestPixelBuffer: CVPixelBuffer?

    // MARK: - Lifecycle & Setup
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // The calibration button must be set up to be used
        setupCalibrationButton()
    }
    
    override func setupAVCapture() {
        super.setupAVCapture()
        setupVision()
        setupLayers()
        updateLayerGeometry()
        startCaptureSession()
    }
    
    func setupVision() {
        guard let modelURL = Bundle.main.url(forResource: "football-detection", withExtension: "mlmodelc") else {
            fatalError("Model file is missing")
        }
        do {
            let model = try MLModel(contentsOf: modelURL)
            visionModel = try VNCoreMLModel(for: model)
            detectionRequest = VNCoreMLRequest(model: visionModel, completionHandler: handleDetectionResults)
            detectionRequest.imageCropAndScaleOption = .scaleFill
        } catch {
            fatalError("Failed to load Vision ML model: \(error)")
        }
    }
    
    // MARK: - Main Vision Pipeline
    
    override func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        self.latestPixelBuffer = pixelBuffer
        let exifOrientation = exifOrientationFromDeviceOrientation()
        
        // If we are not tracking any objects, run detection. Otherwise, track.
        if trackedObjects.isEmpty {
            performDetection(on: pixelBuffer, orientation: exifOrientation)
        } else {
            performTracking(on: pixelBuffer, orientation: exifOrientation)
        }
    }

    /// Runs the initial object detection model to find new objects.
    private func performDetection(on pixelBuffer: CVPixelBuffer, orientation: CGImagePropertyOrientation) {
        let requestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: orientation, options: [:])
        do {
            try requestHandler.perform([self.detectionRequest])
        } catch {
            print("Failed to perform detection: \(error.localizedDescription)")
        }
    }
    
    /// Runs the active tracking requests on the current frame in the background.
    private func performTracking(on pixelBuffer: CVPixelBuffer, orientation: CGImagePropertyOrientation) {
        let requests = trackerQueue.sync { Array(self.trackedObjects.values) }
        guard !requests.isEmpty else { return }
        
        // Tracking can be dispatched to a global queue.
        DispatchQueue.global(qos: .userInitiated).async {
            let requestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: orientation, options: [:])
            do {
                try requestHandler.perform(requests)
            } catch {
                print("Failed to perform tracking: \(error.localizedDescription)")
            }
        }
    }
        
    
    // MARK: - Vision Completion Handlers

    private func handleDetectionResults(for request: VNRequest, error: Error?) {
        guard let results = request.results as? [VNRecognizedObjectObservation] else { return }
        
        trackerQueue.sync { // Protect dictionary access
            var newTrackers: [UUID: VNTrackObjectRequest] = [:]
            var newTrackedInfo: [UUID: (box: CGRect, label: String, teamID: Int?)] = [:]
            
            for observation in results where observation.confidence > 0.6 {
                let uuid = UUID()
                // IMPORTANT: The completion handler for trackers must be thread-safe.
                let trackRequest = VNTrackObjectRequest(detectedObjectObservation: observation) { [weak self] (request, error) in
                    self?.handleTrackingResults(for: request, with: uuid)
                }
                newTrackers[uuid] = trackRequest
                
                let label = observation.labels.first?.identifier ?? "Unknown"
                newTrackedInfo[uuid] = (observation.boundingBox, label, nil)
            }
            
            self.trackedObjects = newTrackers
            self.trackedObjectInfo = newTrackedInfo
        }
        
        updateDetectionOverlay()
    }
    
    private func handleTrackingResults(for request: VNRequest, with uuid: UUID) {
        guard let results = request.results as? [VNDetectedObjectObservation], let observation = results.first else {
            // No result, clear the drawing for this object if it existed.
            trackerQueue.sync {
                trackedObjects.removeValue(forKey: uuid)
                trackedObjectInfo.removeValue(forKey: uuid)
            }
            return
        }
        
        var needsClassification = false
        
        trackerQueue.sync { // Protect dictionary access
            if observation.confidence > 0.5 {
                self.trackedObjects[uuid]?.inputObservation = observation
                self.trackedObjectInfo[uuid]?.box = observation.boundingBox
                
                if self.isClassifierFitted && self.trackedObjectInfo[uuid]?.label == "player" {
                    needsClassification = true
                }
            } else {
                self.trackedObjects.removeValue(forKey: uuid)
                self.trackedObjectInfo.removeValue(forKey: uuid)
            }
        }
        
        if needsClassification {
            classifyPlayer(with: uuid, observation: observation)
        }
        
        updateDetectionOverlay()
    }
        
    // MARK: - Team Classification Logic
    
    @objc func calibrateTeamsButtonPressed() {
        guard let pixelBuffer = self.latestPixelBuffer else {
            print("No video frame available for calibration.")
            return
        }
        
        print("Calibrating teams...")
        
        let request = VNCoreMLRequest(model: self.visionModel) { [weak self] request, error in
            guard let self = self, let results = request.results as? [VNRecognizedObjectObservation] else { return }
            
            let playerObservations = results.filter { $0.labels.first?.identifier == "player" }
            
            guard !playerObservations.isEmpty else {
                print("No players found in the frame to calibrate."); return
            }
            
            Task {
                do {
                    let playerCrops = try playerObservations.map { try self.cropImage(from: pixelBuffer, using: $0) }
                    try await self.teamClassifier.fit(on: playerCrops)
                    self.isClassifierFitted = true
                    print("✅ TeamClassifier is now calibrated!")
                } catch {
                    print("❌ Calibration failed: \(error)")
                    self.isClassifierFitted = false
                }
            }
        }
        
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: exifOrientationFromDeviceOrientation())
        try? handler.perform([request])
    }
    
    private func classifyPlayer(with uuid: UUID, observation: VNDetectedObjectObservation) {
        guard let pixelBuffer = self.latestPixelBuffer else { return }
        
        Task {
            do {
                let crop = try self.cropImage(from: pixelBuffer, using: observation)
                let teamID = try await self.teamClassifier.predict(for: crop, playerID: uuid)
                self.trackedObjectInfo[uuid]?.teamID = teamID
            } catch {
                self.trackedObjectInfo[uuid]?.teamID = nil
            }
        }
    }
    
    // MARK: - UI Drawing
    
    private func updateDetectionOverlay() {
        DispatchQueue.main.async {
            CATransaction.begin()
            CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
            
            self.detectionOverlay.sublayers = nil // Clear previous layers
            
            for (_, info) in self.trackedObjectInfo {
                let objectBounds = VNImageRectForNormalizedRect(info.box, Int(self.bufferSize.width), Int(self.bufferSize.height))
                
                let shapeLayer = self.createShapeLayerWithBounds(objectBounds, info.label, teamID: info.teamID)
                
                // Optional: Add a text label
                // let textLayer = self.createTextSubLayerInBounds(...)
                // shapeLayer.addSublayer(textLayer)
                
                self.detectionOverlay.addSublayer(shapeLayer)
            }
            
            self.updateLayerGeometry()
            CATransaction.commit()
        }
    }
    
    func createShapeLayerWithBounds(_ bounds: CGRect, _ label: String, teamID: Int?) -> CAShapeLayer {
        let shapeLayer = CAShapeLayer()
        shapeLayer.name = label
        let path: UIBezierPath

        switch label {
        case "ball":
            path = UIBezierPath(ovalIn: bounds)
            shapeLayer.fillColor = UIColor(Color.ball).withAlphaComponent(0.6).cgColor
        case "player":
            path = UIBezierPath(rect: bounds)
            if let id = teamID {
                let teamColor = (id == 0) ? Color.teamA : Color.blue
                shapeLayer.fillColor = UIColor(teamColor).withAlphaComponent(0.6).cgColor
            } else {
                shapeLayer.fillColor = UIColor.gray.withAlphaComponent(0.5).cgColor
            }
        default:
            path = UIBezierPath(rect: bounds)
            shapeLayer.fillColor = UIColor.yellow.withAlphaComponent(0.5).cgColor
        }
        
        shapeLayer.path = path.cgPath
        return shapeLayer
    }

    // ... (Keep your existing setupLayers, updateLayerGeometry, createTextSubLayerInBounds) ...

    // MARK: - Helpers
    
    private func setupCalibrationButton() {
        let button = UIButton(type: .system)
        button.setTitle("Calibrate Teams", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 18)
        button.backgroundColor = .systemBlue
        button.tintColor = .white
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(calibrateTeamsButtonPressed), for: .touchUpInside)
        
        view.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.widthAnchor.constraint(equalToConstant: 200),
            button.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func cropImage(from pixelBuffer: CVPixelBuffer, using observation: VNDetectedObjectObservation) throws -> CGImage {
        // The bounding box is in normalized coordinates, so convert it to pixel coordinates.
        let cropRect = VNImageRectForNormalizedRect(observation.boundingBox, CVPixelBufferGetWidth(pixelBuffer), CVPixelBufferGetHeight(pixelBuffer))
        
        // Create a CIImage from the pixel buffer.
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let croppedCIImage = ciImage.cropped(to: cropRect)
        
        // Create a CGImage from the cropped CIImage.
        let context = CIContext()
        guard let croppedCGImage = context.createCGImage(croppedCIImage, from: croppedCIImage.extent) else {
            throw NSError(domain: "VisionViewController", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to crop image."])
        }
        
        return croppedCGImage
    }
    
    func setupLayers() {
        detectionOverlay = CALayer() // container layer that has all the renderings of the observations
        detectionOverlay.name = "DetectionOverlay"
        detectionOverlay.bounds = CGRect(x: 0.0,
                                         y: 0.0,
                                         width: bufferSize.width,
                                         height: bufferSize.height)
        detectionOverlay.position = CGPoint(x: rootLayer.bounds.midX, y: rootLayer.bounds.midY)
        rootLayer.addSublayer(detectionOverlay)
    }
    
    func updateLayerGeometry() {
        let bounds = rootLayer.bounds
        var scale: CGFloat
        
        let xScale: CGFloat = bounds.size.width / bufferSize.height
        let yScale: CGFloat = bounds.size.height / bufferSize.width
        
        scale = fmax(xScale, yScale)
        if scale.isInfinite {
            scale = 1.0
        }
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        
        // rotate the layer into screen orientation and scale and mirror
        detectionOverlay.setAffineTransform(CGAffineTransform(rotationAngle: CGFloat(.pi / 2.0)).scaledBy(x: scale, y: -scale))
        // center the layer
        detectionOverlay.position = CGPoint(x: bounds.midX, y: bounds.midY)
        
        CATransaction.commit()
        
    }
    
    func createTextSubLayerInBounds(_ bounds: CGRect, identifier: String, confidence: VNConfidence) -> CATextLayer {
        let textLayer = CATextLayer()
        textLayer.name = "Object Label"
        let formattedString = NSMutableAttributedString(string: String(format: "\(identifier)\nConfidence:  %.2f", confidence))
        let largeFont = UIFont(name: "Helvetica", size: 12.0)!
        formattedString.addAttributes([NSAttributedString.Key.font: largeFont], range: NSRange(location: 0, length: identifier.count))
        textLayer.string = formattedString
        textLayer.bounds = CGRect(x: 0, y: 0, width: bounds.size.height - 10, height: bounds.size.width - 10)
        textLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
        textLayer.shadowOpacity = 0.7
        textLayer.shadowOffset = CGSize(width: 2, height: 2)
        textLayer.foregroundColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [0.0, 0.0, 0.0, 1.0])
        textLayer.contentsScale = 2.0 // retina rendering
        // rotate the layer into screen orientation and scale and mirror
        textLayer.setAffineTransform(CGAffineTransform(rotationAngle: CGFloat(.pi / 2.0)).scaledBy(x: 1.0, y: -1.0))
        return textLayer
    }
}
