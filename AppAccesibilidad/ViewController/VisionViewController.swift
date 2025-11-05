import UIKit
import AVFoundation
import Vision
import SwiftUI

class VisionViewController: ViewController {
    
    // MARK: - Properties
    // Vision & Core ML
    private var visionModel: VNCoreMLModel!
    // REMOVE: private var detectionRequest: VNCoreMLRequest!
    // ADD: A stateful handler for tracking
    private let sequenceHandler = VNSequenceRequestHandler()

    // ADD: A frame counter for periodic detection
    private var frameCounter = 0
    private let detectionStride = 10 // Run detection every 30 frames (adjust as needed)

    /// A serial queue to protect access to our tracking dictionaries.
    private let trackerQueue = DispatchQueue(label: "Ccookers.trackerQueue")
    // ... (rest of your properties are fine)
    
//    // Vision & Core ML
//    private var visionModel: VNCoreMLModel!
//    private var detectionRequest: VNCoreMLRequest!
//   
//    
//    /// A serial queue to protect access to our tracking dictionaries.
//    private let trackerQueue = DispatchQueue(label: "Ccookers.trackerQueue")
    private var trackedObjects: [UUID: VNTrackObjectRequest] = [:]
    private var trackedObjectInfo: [UUID: (box: CGRect, label: String, teamID: Int?)] = [:]
//    
    // Team Classification
    private let teamClassifier = TeamClassifier()
    private var isClassifierFitted = false
        private var calibrationCrops: [CGImage] = []
    private let minCropsForCalibration = 20 // Threshold of crops to collect
    private var isFittingModel = false      // Lock to prevent multiple fits at once
    
    // UI & Drawing
    private var detectionOverlay: CALayer! = nil
    
    // Data Management
    private var latestPixelBuffer: CVPixelBuffer?

    // MARK: - Lifecycle & Setup
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // The calibration button is now handled by the SwiftUI overlay.
    }
    
    override func setupAVCapture() {
        super.setupAVCapture()
    
        setupVision()
        setupLayers()
        updateLayerGeometry()
        startCaptureSession()
    }
    
    func setupVision() {
        guard let modelURL = Bundle.main.url(forResource: "football-detection-mini", withExtension: "mlmodelc") else {
            fatalError("Model file is missing")
        }
        do {
            let model = try MLModel(contentsOf: modelURL)
            visionModel = try VNCoreMLModel(for: model)
//            detectionRequest = VNCoreMLRequest(model: visionModel, completionHandler: handleDetectionResults)
//            detectionRequest.imageCropAndScaleOption = .scaleFill
        } catch {
            fatalError("Failed to load Vision ML model: \(error)")
        }
    }
    
    // MARK: - Main Vision Pipeline
    
    override func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        self.latestPixelBuffer = pixelBuffer
        let exifOrientation = exifOrientationFromDeviceOrientation()
        
        // 1. Get all active tracker requests
        let trackers = trackerQueue.sync { Array(self.trackedObjects.values) }
        
        // 2. Build the list of requests for this frame
        var requests: [VNRequest] = trackers
        
        // 3. Periodically, add a new detection request
        if frameCounter % detectionStride == 0 {
            requests.append(createDetectionRequest())
        }
        frameCounter = (frameCounter + 1) % detectionStride // Loop counter
        
        // 4. Perform all requests *inside a do-catch block*
        do {
            try sequenceHandler.perform(requests, on: pixelBuffer, orientation: exifOrientation)
        } catch {
            // --- THIS IS THE SAFETY NET ---
            print("❌ Failed to perform requests: \(error.localizedDescription), \(String(describing: error))")
            
            // This specific error is unrecoverable.
            // We MUST reset the tracker state to prevent an immediate crash.
            // This will clear all boxes, and detection will restart.
            trackerQueue.sync {
                self.trackedObjects.removeAll()
                self.trackedObjectInfo.removeAll()
            }
        }
        
        // 5. Update the UI *once* after all requests are processed
        updateDetectionOverlay()
    }
    
    // MARK: - Main Vision Pipeline

//    override func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
//        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
//        self.latestPixelBuffer = pixelBuffer
//        let exifOrientation = exifOrientationFromDeviceOrientation()
//        
//        // 1. Get all active tracker requests
//        let trackers = trackerQueue.sync { Array(self.trackedObjects.values) }
//        
//        // 2. Build the list of requests for this frame
//        var requests: [VNRequest] = trackers
//        
//        // 3. Periodically, add a new detection request
//        if frameCounter % detectionStride == 0 {
//            requests.append(createDetectionRequest())
//        }
//        frameCounter = (frameCounter + 1) % detectionStride // Loop counter
//        
//        // 4. Perform all requests using the *stateful* sequence handler
//        do {
//            try sequenceHandler.perform(requests, on: pixelBuffer, orientation: exifOrientation)
//        } catch {
//            print("Failed to perform requests: \(error.localizedDescription)")
//        }
//        
//        // 5. Update the UI *once* after all requests are processed
//        updateDetectionOverlay()
//    }
    
    /// Helper to create a new detection request for the current frame.
    private func createDetectionRequest() -> VNCoreMLRequest {
        let request = VNCoreMLRequest(model: visionModel, completionHandler: handleDetectionResults)
        request.imageCropAndScaleOption = .scaleFill
        return request
    }
        
    
    // MARK: - Vision Completion Handlers

//    private func handleDetectionResults(for request: VNRequest, error: Error?) {
//        guard let results = request.results as? [VNRecognizedObjectObservation] else { return }
//        
//        trackerQueue.sync { // Protect dictionary access
//            // Get the boxes of objects we are *already* tracking
//            let existingBoxes = self.trackedObjectInfo.values.map { $0.box }
//            
//            for observation in results where observation.confidence > 0.6 {
//                
//                // Check if this "new" detection overlaps significantly with an existing tracker
//                var isNew = true
//                for box in existingBoxes {
//                    if iou(observation.boundingBox, box) > 0.7 { // 70% overlap
//                        isNew = false
//                        break
//                    }
//                }
//                
//                if isNew {
//                    // This is a NEWLY detected object. Create a tracker for it.
//                    let uuid = UUID()
//                    
//                    // Create a tracker with its own completion handler
//                    let trackRequest = VNTrackObjectRequest(detectedObjectObservation: observation) { [weak self] (req, err) in
//                        self?.handleTrackingResults(for: req, with: uuid)
//                    }
//                    
//                    // Add it to our state
//                    self.trackedObjects[uuid] = trackRequest
//                    
//                    let label = observation.labels.first?.identifier ?? "Unknown"
//                    self.trackedObjectInfo[uuid] = (observation.boundingBox, label, nil)
//                    
//                    // If classifier is ready, classify this new player immediately
//                    if self.isClassifierFitted && label == "player" {
//                        self.classifyPlayer(with: uuid, observation: observation)
//                    }
//                }
//            }
//        }
//    }
    
    private func handleDetectionResults(for request: VNRequest, error: Error?) {
        guard let results = request.results as? [VNRecognizedObjectObservation] else { return }
        
        trackerQueue.sync {
            let currentTrackersInfo = self.trackedObjectInfo
            var matchedUUIDs: Set<UUID> = []

            // --- PART 1: MATCH AND UPDATE ---
            // Loop through all new detections from the model
            for newObservation in results where newObservation.confidence > 0.6 {
                
                var bestMatchUUID: UUID? = nil
                var bestIOU: CGFloat = 0.0
                
                // Find the existing tracker with the best overlap
                for (uuid, info) in currentTrackersInfo {
                    if matchedUUIDs.contains(uuid) { continue }
                    
                    let iou = iou(newObservation.boundingBox, info.box)
                    if iou > bestIOU && iou > 0.2 { // 0.2 is a good "catch" threshold
                        bestIOU = iou
                        bestMatchUUID = uuid
                    }
                }
                
                if let matchedUUID = bestMatchUUID {
                    // --- A: RE-DETECTION ---
                    // We found a match. Update the tracker with the new,
                    // more-accurate box. This "snaps" it back.
                    self.trackedObjects[matchedUUID]?.inputObservation = newObservation
                    self.trackedObjectInfo[matchedUUID]?.box = newObservation.boundingBox
                    matchedUUIDs.insert(matchedUUID)

                } else {
                    // --- B: NEW DETECTION ---
                    // This is a new object. Create a tracker.
                    let uuid = UUID()
                    let trackRequest = VNTrackObjectRequest(detectedObjectObservation: newObservation) { [weak self] (req, err) in
                        self?.handleTrackingResults(for: req, with: uuid)
                    }
                    
                    self.trackedObjects[uuid] = trackRequest
                    let label = newObservation.labels.first?.identifier ?? "Unknown"
                    self.trackedObjectInfo[uuid] = (newObservation.boundingBox, label, nil)
                    matchedUUIDs.insert(uuid) // Also add new trackers to the set

                    if self.isClassifierFitted && label == "player" {
                        self.classifyPlayer(with: uuid, observation: newObservation)
                    }
                }
            }
            
            // --- ⭐️ PART 2: PRUNE ZOMBIES (THE FIX) ⭐️ ---
            //
            // We've now matched all the detections we can.
            // Any tracker that *wasn't* in the `matchedUUIDs` set
            // is a "zombie" (it's lost, drifted, or occluded)
            // and must be removed.
            
            // 1. Get all UUIDs we were tracking before this pass
            let allCurrentUUIDs = Set(self.trackedObjectInfo.keys)
            
            // 2. Find the ones that were NOT matched or created
            let unmatchedUUIDs = allCurrentUUIDs.subtracting(matchedUUIDs)
            
            // 3. Remove them.
            for uuid in unmatchedUUIDs {
                // Optional: You might want to be more careful, e.g.,
                // only prune "players" and not the "ball".
                // For now, removing all unmatched is safest.
                self.trackedObjects.removeValue(forKey: uuid)
                self.trackedObjectInfo.removeValue(forKey: uuid)
            }
        }
    }
    
    private func handleTrackingResults(for request: VNRequest, with uuid: UUID) {
        guard let results = request.results as? [VNDetectedObjectObservation], let observation = results.first else {
            // No result, object was lost.
            trackerQueue.sync {
                trackedObjects.removeValue(forKey: uuid)
                trackedObjectInfo.removeValue(forKey: uuid)
            }
            return
        }
        
        var needsClassification = false
        
        trackerQueue.sync { // Protect dictionary access
            if observation.confidence > 0.5 {
                // CRITICAL: Update the tracker's observation so it tracks
                // from this new position in the *next* frame.
                self.trackedObjects[uuid]?.inputObservation = observation
                
                // Update the info for drawing
                let oldInfo = self.trackedObjectInfo[uuid]
                self.trackedObjectInfo[uuid] = (observation.boundingBox, oldInfo?.label ?? "Unknown", oldInfo?.teamID)
                
                // Check if we need to classify this player
                // (e.g., if classifier was just fitted, or if teamID is still nil)
                if self.isClassifierFitted &&
                   oldInfo?.label == "player" &&
                   oldInfo?.teamID == nil {
                    needsClassification = true
                }
                
            } else {
                // Tracker lost confidence
                self.trackedObjects.removeValue(forKey: uuid)
                self.trackedObjectInfo.removeValue(forKey: uuid)
            }
        }
        
        if needsClassification {
            // This is async (Task) so it's safe to call from here
            classifyPlayer(with: uuid, observation: observation)
        }
        
        // REMOVED: updateDetectionOverlay()
        // This was the source of major UI performance issues, as it was
        // being called N times per frame (once for each tracker).
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
//    
//    private func classifyPlayer(with uuid: UUID, observation: VNDetectedObjectObservation) {
//        guard let pixelBuffer = self.latestPixelBuffer else { return }
//        
//        Task {
//            do {
//                let crop = try self.cropImage(from: pixelBuffer, using: observation)
//                let teamID = try await self.teamClassifier.predict(for: crop, playerID: uuid)
//                self.trackedObjectInfo[uuid]?.teamID = teamID
//            } catch {
//                self.trackedObjectInfo[uuid]?.teamID = nil
//            }
//        }
//    }
    
    private func classifyPlayer(with uuid: UUID, observation: VNDetectedObjectObservation) {
        // This read is a minor data race, but is generally safe
        // as it's just a pointer swap.
        guard let pixelBuffer = self.latestPixelBuffer else { return }
        
        Task {
            do {
                // 1. Expensive work (crop, predict) happens concurrently,
                //    outside of the queue.
                let crop = try self.cropImage(from: pixelBuffer, using: observation)
                let teamID = try await self.teamClassifier.predict(for: crop, playerID: uuid)
                
                // 2. ⭐️ THE FIX: Perform the write operation *inside*
                //    the queue to prevent the race condition.
                self.trackerQueue.async {
                    // Check if the tracker still exists.
                    // It could have been lost/removed by the time prediction finished.
                    if self.trackedObjectInfo[uuid] != nil {
                         self.trackedObjectInfo[uuid]?.teamID = teamID
                    }
                }
            } catch {
                // 3. ⭐️ THE FIX: The error case must also be synchronized.
                self.trackerQueue.async {
                    if self.trackedObjectInfo[uuid] != nil {
                        self.trackedObjectInfo[uuid]?.teamID = nil
                    }
                }
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


    // MARK: - Helpers

    /// Calculates the Intersection over Union (IOU) of two bounding boxes.
    private func iou(_ a: CGRect, _ b: CGRect) -> CGFloat {
        let intersection = a.intersection(b)
        let union = a.union(b)
        
        // Avoid division by zero if union is empty
        guard union.width > 0, union.height > 0 else { return 0 }
        
        return (intersection.width * intersection.height) / (union.width * union.height)
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
        
        // **THE FIX:**
        // The buffer is now landscape (e.g., 1920x1080).
        // The bounds are also landscape (e.g., 812x375).
        // We match width-to-width and height-to-height.
        
        let xScale: CGFloat = bounds.size.width / bufferSize.width
        let yScale: CGFloat = bounds.size.height / bufferSize.height
        
        scale = fmax(xScale, yScale)
        if scale.isInfinite {
            scale = 1.0
        }
        
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        
        // **THE FIX:**
        // REMOVED: CGAffineTransform(rotationAngle: CGFloat(.pi / 2.0))
        // We only need to scale and flip vertically (because Core Graphics
        // and CALayer have different coordinate origins).
        detectionOverlay.setAffineTransform(CGAffineTransform(scaleX: scale, y: -scale))
        
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
        
        // **THE FIX:** The bounds are now in the correct orientation,
        // so we don't swap width and height.
        textLayer.bounds = CGRect(x: 0, y: 0, width: bounds.size.width - 10, height: bounds.size.height - 10)
        textLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
        
        textLayer.shadowOpacity = 0.7
        textLayer.shadowOffset = CGSize(width: 2, height: 2)
        textLayer.foregroundColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [0.0, 0.0, 0.0, 1.0])
        textLayer.contentsScale = 2.0 // retina rendering
        
        // **THE FIX:** REMOVED the 90-degree rotation.
        // We only need to scale and flip.
        textLayer.setAffineTransform(CGAffineTransform(scaleX: 1.0, y: -1.0))
        
        return textLayer
    }
    
    
    
    
    // MARK: - Team Classification Logic
    // ... (keep calibrateTeamsButtonPressed and classifyPlayer)

    /// Asynchronously crops a new player and adds it to the calibration buffer.
    private func collectCropForCalibration(from observation: VNDetectedObjectObservation) {
        // Run this off the trackerQueue to avoid blocking
        Task {
            // Check flags *before* doing expensive work
            guard !self.isClassifierFitted, !self.isFittingModel else { return }
            guard let pixelBuffer = self.latestPixelBuffer else { return }
            
            do {
                let crop = try self.cropImage(from: pixelBuffer, using: observation)
                
                // Add the crop to our collection and check if we're ready
                // This must be synchronized
                self.trackerQueue.async { // Use .async to not block the Task
                    // Check flags again inside the queue
                    guard !self.isClassifierFitted, !self.isFittingModel else { return }
                    
                    self.calibrationCrops.append(crop)
                    print("Collected crop \(self.calibrationCrops.count)/\(self.minCropsForCalibration)")
                    
                    if self.calibrationCrops.count >= self.minCropsForCalibration {
                        self.isFittingModel = true // Set lock
                        let cropsToFit = self.calibrationCrops // Copy
                        self.calibrationCrops.removeAll() // Clear
                        
                        // Run the async fit function
                        self.runCalibration(with: cropsToFit)
                    }
                }
            } catch {
                print("Failed to get crop for calibration: \(error)")
            }
        }
    }

    /// Runs the classifier's fit method on the collected crops.
    private func runCalibration(with crops: [CGImage]) {
        print("Starting automatic calibration with \(crops.count) crops...")
        
        Task { // This is an async task
            do {
                try await self.teamClassifier.fit(on: crops)
                
                // Success! Set flags and classify all players we're already tracking
                self.isClassifierFitted = true
                self.isFittingModel = false // Release lock
                print("✅ Automatic calibration successful!")
                self.classifyAllExistingPlayers()
                
            } catch {
                print("❌ Automatic calibration failed: \(error)")
                
                // Failure. Release lock to allow retry.
                // The collection process will start over.
                self.isClassifierFitted = false
                self.isFittingModel = false
            }
        }
    }

    /// Finds all currently tracked players and runs classification on them.
    private func classifyAllExistingPlayers() {
        print("Classifier fitted. Re-classifying all existing players...")
        let currentPlayers = self.trackerQueue.sync {
            // Get all UUIDs and observations for objects labeled "player"
            return self.trackedObjectInfo
                .filter { $0.value.label == "player" }
                .compactMap { (uuid, info) -> (UUID, VNDetectedObjectObservation)? in
                    guard let tracker = self.trackedObjects[uuid] else { return nil }
                    return (uuid, tracker.inputObservation)
                }
        }
        
        // Call classifyPlayer for each one. This is safe because
        // classifyPlayer already runs as an async Task.
        for (uuid, observation) in currentPlayers {
            self.classifyPlayer(with: uuid, observation: observation)
        }
    }
}
