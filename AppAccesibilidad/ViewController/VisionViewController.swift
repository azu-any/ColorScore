import UIKit
import AVFoundation
import Vision
import SwiftUI

class VisionViewController: ViewController {
    
    private var currentState: DetectionState = .preTraining {
        didSet {
            updateUI(for: currentState)
        }
    }
    
    // MARK: - Properties

    private var visionProcessor: VisionProcessor!
    private let trackerQueue = DispatchQueue(label: "Xcookers.trackerQueue", qos: .userInitiated)
    private var trainingTimer: Timer?
    private var trainingSecondsRemaining: Int = 0
    private let trainingDuration: TimeInterval = 30.0
    private var objectsToTrack = [TrackedPolyRect]()

    
    private func updateUI(for state: DetectionState) {
        // Show/hide your overlay components based on state
        switch state {
        case .preTraining:
            trainingOverlayView.showStartButton()
        case .isTraining:
            trainingOverlayView.showTrainingProgress(secondsRemaining: 30) // e.g., "Calibrating... 30s"
        case .isDetecting:
            trainingOverlayView.hide()
        }
    }
    
    // UI & Drawing
    private var detectionOverlay: CALayer! = nil
    private var trainingOverlayView: TrainingOverlayView!
    
    // Data Management
    private var latestPixelBuffer: CVPixelBuffer?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupOverlayView()
        
        // Initialize the processor
        self.visionProcessor = VisionProcessor()
        
        // Set initial state
        self.currentState = .preTraining
    }
    
    private func setupOverlayView() {
        // Add your new view over the camera feed
        trainingOverlayView = TrainingOverlayView(frame: view.bounds)
        view.addSubview(trainingOverlayView)
        
        // Add a target to the button in the overlay
        trainingOverlayView.startButton.addTarget(self,
               action: #selector(didTapStartTraining),
               for: .touchUpInside)
    }
    
    override func setupAVCapture() {
        super.setupAVCapture()
        setupLayers()
        updateLayerGeometry()
        startCaptureSession()
    }
    
    @objc private func didTapStartTraining() {
        // --- STATE 1 -> 2 ---
        currentState = .isTraining
        
        trainingSecondsRemaining = Int(trainingDuration)
        trainingOverlayView?.showTrainingProgress(secondsRemaining: trainingSecondsRemaining)

        // Start the 1-second UI update timer
        trainingTimer?.invalidate() // In case it's already running
        trainingTimer = Timer.scheduledTimer(timeInterval: 1.0,
                                             target: self,
                                             selector: #selector(trainingTimerTick),
                                             userInfo: nil,
                                             repeats: true)
        
        // Schedule the *actual* end of training
        DispatchQueue.main.asyncAfter(deadline: .now() + trainingDuration) { [weak self] in
            // Using [weak self] is good practice for asyncAfter
            self?.finishTraining()
        }
    }

    @objc private func trainingTimerTick() {
        // --- FIX: Add countdown logic and UI update ---
        if trainingSecondsRemaining > 0 {
            trainingSecondsRemaining -= 1
        } else {
            // This is a safeguard, but 'finishTraining' should have
            // already invalidated the timer.
            trainingTimer?.invalidate()
        }
        
        // Update the overlay UI with the new remaining time
        trainingOverlayView?.showTrainingProgress(secondsRemaining: trainingSecondsRemaining)
    }

    private func finishTraining() {
        // This function was logically correct, but I'll include it for completeness.
        
        // --- STATE 2 -> 3 ---
        
        // Stop the 1-second UI timer
        trainingTimer?.invalidate()
        
        // 1. Tell the processor to train on the crops it collected
        print("Training classifier...")
        visionProcessor.trainClassifier { [weak self] success in
            // Ensure we are still on the main thread for UI/state updates
            DispatchQueue.main.async {
                guard let self = self, success else {
                    print("Training failed. Resetting.")
                    self?.currentState = .preTraining // Go back to start
                    return
                }
                
                // 2. Move to live detection
                print("Training complete. Going live.")
                self.currentState = .isDetecting
            }
        }
    }
    
    // MARK: - Main Vision Pipeline
    
    override func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        // Obtain image from camera
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        self.latestPixelBuffer = pixelBuffer
        let exifOrientation = exifOrientationFromDeviceOrientation()
        
        visionProcessor.process(pixelBuffer, state: currentState)

        updateDetectionOverlay()
    }
    
    
    // MARK: - UI Drawing
    
    private func updateDetectionOverlay() {
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
//                
//                // Optional: Add a text label
//                // let textLayer = self.createTextSubLayerInBounds(...)
//                // shapeLayer.addSublayer(textLayer)
//                
//                self.detectionOverlay.addSublayer(shapeLayer)
//            }
//            
//            self.updateLayerGeometry()
//            CATransaction.commit()
//        }
    }
    
//    func createShapeLayerWithBounds(_ bounds: CGRect, _ label: String, teamID: Int?) -> CAShapeLayer {
//        let shapeLayer = CAShapeLayer()
//        shapeLayer.name = label
//        let path: UIBezierPath
//
//        switch label {
//        case "ball":
//            path = UIBezierPath(ovalIn: bounds)
//            shapeLayer.fillColor = UIColor(Color.ball).withAlphaComponent(0.6).cgColor
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
        
        let xScale: CGFloat = bounds.size.width / bufferSize.width
        let yScale: CGFloat = bounds.size.height / bufferSize.height
        
        scale = fmax(xScale, yScale)
        if scale.isInfinite {
            scale = 1.0
        }
        
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        
        detectionOverlay.setAffineTransform(CGAffineTransform(scaleX: scale, y: -scale))
        
        // center the layer
        detectionOverlay.position = CGPoint(x: bounds.midX, y: bounds.midY)
        
        CATransaction.commit()
    }
    
}
