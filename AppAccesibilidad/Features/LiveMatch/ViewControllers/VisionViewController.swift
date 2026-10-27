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
    var settings: MatchSettings?

    
    // ADD: A frame counter for periodic detection
    private var frameCounter = 0
    private let detectionStride = 10 // Run detection every 30 frames (adjust as needed)

    /// A serial queue to protect access to our tracking dictionaries.
    private let trackerQueue = DispatchQueue(label: "Xcookers.trackerQueue")
    private var trackedObjects: [UUID: VNTrackObjectRequest] = [:]
    private var trackedObjectInfo: [UUID: (box: CGRect, label: String, teamID: Int?)] = [:]

    // Team Classification
    var teamClassifier = TeamClassifier()
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
        super.captureOutput(output, didOutput: sampleBuffer, from: connection)
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        self.latestPixelBuffer = pixelBuffer
        let exifOrientation = exifOrientationFromDeviceOrientation()
        
        // Call visionProcessor to process frames
        visionProcessor.performRequest(on: pixelBuffer, orientation: exifOrientation)
    }
            
    // MARK: - UI Drawing
    
    func drawVisionRequestResults(_ results: [VNRecognizedObjectObservation]) {
        guard detectionOverlay != nil else { return }
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        detectionOverlay.sublayers = nil // remove all the old recognized objects
        
        for objectObservation in results {
            guard let topLabelObservation = objectObservation.labels.first else { continue }
            let objectBounds = VNImageRectForNormalizedRect(objectObservation.boundingBox, Int(bufferSize.width), Int(bufferSize.height))
            
            let shapeLayer = self.createShapeLayerWithBounds(objectBounds, topLabelObservation.identifier)
            
            detectionOverlay.addSublayer(shapeLayer)
        }
        self.updateLayerGeometry()
        CATransaction.commit()
    }
    
    func setupLayers() {
        if rootLayer == nil {
            rootLayer = view.layer
        }
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
        guard rootLayer != nil, detectionOverlay != nil, bufferSize.width > 0, bufferSize.height > 0 else { return }
        let bounds = rootLayer.bounds
        var scale: CGFloat
        
        let xScale: CGFloat = bounds.size.width / bufferSize.width
        let yScale: CGFloat = bounds.size.height / bufferSize.height
        
        scale = fmax(xScale, yScale)
        if scale.isInfinite || scale.isNaN {
            scale = 1.0
        }
        
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        detectionOverlay.setAffineTransform(CGAffineTransform(scaleX: scale, y: -scale))
        
        // center the layer
        detectionOverlay.position = CGPoint(x: bounds.midX, y: bounds.midY)
        
        CATransaction.commit()
    }
    
    
    
    func createShapeLayerWithBounds(_ bounds: CGRect, _ label: String, teamID: Int? = nil) -> CAShapeLayer {
        // Compute a small square marker positioned just above the player's head
        let markerSize = min(max(bounds.width * 0.45, 10.0), 22.0)
        let verticalSpacing: CGFloat = 4.0
        let markerRect = CGRect(
            x: bounds.midX - markerSize / 2.0,
            y: bounds.maxY + verticalSpacing,
            width: markerSize,
            height: markerSize
        )
        
        // Safely unwrap the settings. If they're not ready,
        // draw a default gray marker above the player and exit the function.
        guard let settings = self.settings else {
            let defaultLayer = CAShapeLayer()
            defaultLayer.name = label
            defaultLayer.path = UIBezierPath(ovalIn: markerRect).cgPath
            defaultLayer.fillColor = UIColor.gray.withAlphaComponent(0.75).cgColor
            defaultLayer.lineWidth = 1.5
            defaultLayer.strokeColor = UIColor.white.cgColor
            return defaultLayer
        }
        
        let detection = DetectionType(label: label, teamID: teamID)
        let style = settings.style(for: detection)
        let shapeLayer = CAShapeLayer()
        shapeLayer.name = label
        
        // High-contrast rendering for low-vision & colorblind accessibility
        let fillAlpha: CGFloat = UIAccessibility.isReduceTransparencyEnabled ? 0.95 : 0.9
        let strokeWidth: CGFloat = UIAccessibility.shouldDifferentiateWithoutColor ? 2.5 : 1.5
        
        shapeLayer.path = style.shape.path(in: markerRect).cgPath
        shapeLayer.fillColor = style.color.withAlphaComponent(fillAlpha).cgColor
        shapeLayer.lineWidth = strokeWidth
        shapeLayer.strokeColor = UIColor.white.cgColor
        shapeLayer.shadowColor = UIColor.black.cgColor
        shapeLayer.shadowOpacity = 0.6
        shapeLayer.shadowRadius = 2.0
        shapeLayer.shadowOffset = .zero
        
        return shapeLayer
    }
}
