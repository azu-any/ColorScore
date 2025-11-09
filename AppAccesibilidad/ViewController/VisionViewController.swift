//
//  VisionViewController.swift
//  AppAccesibilidad
//
//  Created by Azuany Mila Cerón on 11/8/25.
//


import UIKit
import AVFoundation
import Vision
import SwiftUI

class VisionViewController: CameraViewController, VisionProcesorDelegate {
    
    // MARK: - Properties
    var visionProcessor = VisionProcessor()
    
    // ADD: A frame counter for periodic detection
    private var frameCounter = 0
    private let detectionStride = 10 // Run detection every 30 frames (adjust as needed)

    /// A serial queue to protect access to our tracking dictionaries.
    private let trackerQueue = DispatchQueue(label: "Xcookers.trackerQueue")
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
    var detectionOverlay: CALayer! = nil
    
    // Data Management
    private var latestPixelBuffer: CVPixelBuffer?

    // MARK: - Lifecycle & Setup
    
    override func setupAVCapture() {
        super.setupAVCapture()
    
        setupLayers()
        updateLayerGeometry()
        
        visionProcessor.delegate = self
        
        if let error = visionProcessor.setupVision() {
            print("FATAL ERROR: Failed to setup Vision: \(error.localizedDescription)")
            return
        }
        
//        startCaptureSession()
    }
    
    
    func visionService(_ service: VisionProcessor, didFind results: [VNRecognizedObjectObservation], on buffer: CVPixelBuffer) {
        // We received results from the service.
        // This is called on the main thread, so it's safe to update the UI.
        self.drawVisionRequestResults(results)
        
    }
    
    // In case, the vision service failed
    func visionService(_ service: VisionProcessor, didFailWithError error: Error) {
        print("Vision service failed with error: \(error.localizedDescription)")
    }
    
    // MARK: - Main Vision Pipeline
    
    // Manage output of camera
    override func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        self.latestPixelBuffer = pixelBuffer
        let exifOrientation = exifOrientationFromDeviceOrientation()
        
        // Call visionProcessor to process frames
        visionProcessor.performRequest(on: pixelBuffer, orientation: exifOrientation)
    }
            
    // MARK: - UI Drawing
    
    func drawVisionRequestResults(_ results: [VNRecognizedObjectObservation]) {
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        detectionOverlay.sublayers = nil // remove all the old recognized objects
        
        // The loop is now simpler since we know the type
        for objectObservation in results {
            // Select only the label with the highest confidence.
            let topLabelObservation = objectObservation.labels[0]
            let objectBounds = VNImageRectForNormalizedRect(objectObservation.boundingBox, Int(bufferSize.width), Int(bufferSize.height))
            
            let shapeLayer = self.createShapeLayerWithBounds(objectBounds, topLabelObservation.identifier)
            
            detectionOverlay.addSublayer(shapeLayer)
        }
        self.updateLayerGeometry()
        CATransaction.commit()
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
    
    
    
    func createShapeLayerWithBounds(_ bounds: CGRect, _ label: String, teamID: Int? = nil) -> CAShapeLayer {
        let shapeLayer = CAShapeLayer()
        shapeLayer.name = label
        var path: UIBezierPath

        switch label {
        case "ball":
            path = UIBezierPath(ovalIn: bounds)
            shapeLayer.fillColor = UIColor(Color.ball).withAlphaComponent(0.6).cgColor
        case "player":
            path = UIBezierPath(rect: bounds)
            if let id = teamID {
                let teamColor = (id == 0) ? Color.teamA : Color.blue
                path = (id == 0) ? UIBezierPath(rect: bounds) : UIBezierPath(ovalIn: bounds)
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
}
