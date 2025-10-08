//
//  VisionViewController.swift
//  AppAccesibilidad
//
//  Created by Azuany Mila Cerón on 10/6/25.
//


import UIKit
import AVFoundation
import Vision
import SwiftUI

class VisionViewController: ViewController {
    
    private var detectionOverlay: CALayer! = nil
    
    // Vision parts
    private var requests = [VNRequest]()
    
    @discardableResult
    func setupVision() -> NSError? {
        // Setup Vision parts
        let error: NSError! = nil

        // Load model
        guard let modelURL = Bundle.main.url(forResource: "football-detection", withExtension: "mlmodelc") else {
            return NSError(domain: "VisionViewController", code: -1, userInfo: [NSLocalizedDescriptionKey: "Model file is missing"])
        }

        do {
            let visionModel = try VNCoreMLModel(for: MLModel(contentsOf: modelURL))
            let objectRecognition = VNCoreMLRequest(model: visionModel, completionHandler: { (request, error) in
                DispatchQueue.main.async(execute: {
                    // Perform all the UI updates on the main queue
                    if let results = request.results {
                        self.drawVisionRequestResults(results)
                    }
                })
            })
            self.requests = [objectRecognition]
        } catch let error as NSError {
            print("Model loading went wrong: \(error)")
        }
        
        return error
    }
    
    func drawVisionRequestResults(_ results: [Any]) {
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        detectionOverlay.sublayers = nil // remove all the old recognized objects
        for observation in results where observation is VNRecognizedObjectObservation {
            guard let objectObservation = observation as? VNRecognizedObjectObservation else {
                continue
            }
            // Select only the label with the highest confidence.
            let topLabelObservation = objectObservation.labels[0]
            let objectBounds = VNImageRectForNormalizedRect(objectObservation.boundingBox, Int(bufferSize.width), Int(bufferSize.height))
            
            let shapeLayer = self.createShapeLayerWithBounds(objectBounds, topLabelObservation.identifier)
            
            let textLayer = self.createTextSubLayerInBounds(objectBounds,
                                                            identifier: topLabelObservation.identifier,
                                                            confidence: topLabelObservation.confidence)
            shapeLayer.addSublayer(textLayer)
            detectionOverlay.addSublayer(shapeLayer)
        }
        self.updateLayerGeometry()
        CATransaction.commit()
    }
    
    override func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        let exifOrientation = exifOrientationFromDeviceOrientation()
        
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: exifOrientation, options: [:])
        do {
            try imageRequestHandler.perform(self.requests)
        } catch {
            print(error)
        }
    }
    
    override func setupAVCapture() {
        super.setupAVCapture()
        
        // setup Vision parts
        setupLayers()
        updateLayerGeometry()
        setupVision()
        
        // start the capture
        startCaptureSession()
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
    
//    func createRoundedRectLayerWithBounds(_ bounds: CGRect, _ label: String) -> CALayer {
//        let shapeLayer = CALayer()
//
//        shapeLayer.name = label
//        shapeLayer.cornerRadius = 1
//        shapeLayer.bounds = bounds
//        shapeLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
//
//
//        print(label)
//        switch label {
//        case "ball":
//            shapeLayer.cornerRadius = 3
//            // Make the ball look bigger
//            shapeLayer.bounds = bounds.applying(CGAffineTransform(scaleX: 1.5, y: 1.5))
//            shapeLayer.backgroundColor = UIColor(Color.ball).cgColor
//
//        case "player":
//            shapeLayer.backgroundColor = UIColor(Color.teamA).cgColor
//            
//        default:
//            shapeLayer.bounds = bounds
//            shapeLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
//            shapeLayer.backgroundColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [1.0, 1.0, 0.2, 0.4])
//        }
//        
//        return shapeLayer
//    }
    
    func createShapeLayerWithBounds(_ bounds: CGRect, _ label: String) -> CAShapeLayer {
        // 1. Create a CAShapeLayer instead of a CALayer
        let shapeLayer = CAShapeLayer()
        shapeLayer.name = label
        
        // Create a path object that we will define in the switch statement
        let path: UIBezierPath

        print(label)
        switch label {
        case "ball": // Circle
            // Create a circular path that fills the given bounds
            // Make the ball look bigger
            //            shapeLayer.bounds = bounds.applying(CGAffineTransform(scaleX: 1.5, y: 1.5))
            path = UIBezierPath(ovalIn: bounds)
            
            // Use fillColor for the shape's inner color
            shapeLayer.fillColor = UIColor(Color.ball).cgColor

        case "player": // Rectangle
            // Create a rectangular path
            path = UIBezierPath(rect: bounds)
            shapeLayer.fillColor = UIColor(Color.teamA).cgColor
                
        default: //Triangle
            path = UIBezierPath()
            // Move to the top center point of the bounds
            path.move(to: CGPoint(x: bounds.midX, y: bounds.minY))
            // Add a line to the bottom right
            path.addLine(to: CGPoint(x: bounds.maxX, y: bounds.maxY))
            // Add a line to the bottom left
            path.addLine(to: CGPoint(x: bounds.minX, y: bounds.maxY))
            // Close the path to complete the triangle
            path.close()
            
            shapeLayer.fillColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [1.0, 1.0, 0.2, 1.0])
        }
            
        // 2. Assign the created path to the layer
        shapeLayer.path = path.cgPath
        // shapeLayer.strokeColor = UIColor.black.cgColor
        // shapeLayer.lineWidth = 2.0
        return shapeLayer
    }
    
}
