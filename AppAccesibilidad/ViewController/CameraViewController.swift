//
//  ViewController.swift
//  AppAccesibilidad
//
//  Created by Azuany Mila Cerón on 10/7/25.
//


import UIKit
import AVFoundation
import Vision

class CameraViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    var bufferSize: CGSize = .zero
    var rootLayer: CALayer! = nil
    
    private var previewView = UIView()
    private let session = AVCaptureSession()
    private var previewLayer: AVCaptureVideoPreviewLayer! = nil
    private let videoDataOutput = AVCaptureVideoDataOutput()
    
    private let videoDataOutputQueue = DispatchQueue(label: "VideoDataOutput", qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem)
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // to be implemented in the subclass
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(previewView)
        self.previewView.frame = self.view.bounds
        setupAVCapture()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Ensure the previewView itself fills the entire screen
        previewView.frame = self.view.bounds
        
        // Ensure the camera preview layer fills the previewView
        previewLayer?.frame = previewView.bounds
        
        // This fixes the rotated camera preview.
        if let connection = self.previewLayer?.connection, connection.isVideoOrientationSupported {
            let interfaceOrientation = self.view.window?.windowScene?.interfaceOrientation ?? .landscapeRight
            
            // Set the preview layer's orientation to match the interface
            switch interfaceOrientation {
            case .landscapeLeft:
                connection.videoOrientation = .landscapeLeft
            case .landscapeRight:
                connection.videoOrientation = .landscapeRight
            default:
                // Default to landscape right if in portrait (which it shouldn't be)
                connection.videoOrientation = .landscapeRight
            }
        }
        
//        THIS DOES NOT WORK
//        if let connection = self.previewLayer?.connection {
//            let interfaceOrientation = self.view.window?.windowScene?.effectiveGeometry.interfaceOrientation ?? .landscapeRight
//            let rotationAngle: CGFloat
//
//            // Determine the correct rotation angle based on the UI's orientation
//            switch interfaceOrientation {
//            case .landscapeLeft:
//                rotationAngle = -90 // or 270
//            case .landscapeRight:
//                rotationAngle = 90
//            default:
//                // Default to landscape right as per your app's setup
//                rotationAngle = 90
//            }
//            
//            // Set the rotation angle on the preview layer's connection
//            if connection.isVideoRotationAngleSupported(rotationAngle) {
//                connection.videoRotationAngle = rotationAngle
//            }
//        }
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape // This allows both left and right landscape
    }

    override var shouldAutorotate: Bool {
        return true
    }

    // This helps force the orientation on presentation
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .landscapeRight
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupAVCapture() {
        var deviceInput: AVCaptureDeviceInput!
        
        // Select a video device, make an input
        let videoDevice = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .back).devices.first
        do {
            deviceInput = try AVCaptureDeviceInput(device: videoDevice!)
        } catch {
            print("Could not create video device input: \(error)")
            return
        }
        
        session.beginConfiguration()
        session.sessionPreset = .vga640x480 // Model image size is smaller.
        
        // Add a video input
        guard session.canAddInput(deviceInput) else {
            print("Could not add video device input to the session")
            session.commitConfiguration()
            return
        }
        session.addInput(deviceInput)
        if session.canAddOutput(videoDataOutput) {
            session.addOutput(videoDataOutput)
            // Add a video data output
            videoDataOutput.alwaysDiscardsLateVideoFrames = true
            videoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)]
            videoDataOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
        } else {
            print("Could not add video data output to the session")
            session.commitConfiguration()
            return
        }
        
        let captureConnection = videoDataOutput.connection(with: .video)
        // Always process the frames
        captureConnection?.isEnabled = true
        do {
            try  videoDevice!.lockForConfiguration()
            let dimensions = CMVideoFormatDescriptionGetDimensions((videoDevice?.activeFormat.formatDescription)!)
            bufferSize.width = CGFloat(dimensions.width)
            bufferSize.height = CGFloat(dimensions.height)
            videoDevice!.unlockForConfiguration()
        } catch {
            print(error)
        }
        
        session.commitConfiguration()
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        rootLayer = previewView.layer
        previewLayer.frame = rootLayer.bounds
        rootLayer.addSublayer(previewLayer)
    }
    
    func startCaptureSession() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.session.startRunning()
        }
    }
    
    // Clean up capture setup
    func teardownAVCapture() {
        previewLayer.removeFromSuperlayer()
        previewLayer = nil
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.session.stopRunning()
        }
    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput, didDrop didDropSampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // print("frame dropped")
    }
    
    
//    public func exifOrientationFromDeviceOrientation() -> CGImagePropertyOrientation {
////        let curDeviceOrientation = UIDevice.current.orientation
////        let exifOrientation: CGImagePropertyOrientation
////        
////        switch curDeviceOrientation {
////        case UIDeviceOrientation.portraitUpsideDown:  // Device oriented vertically, home button on the top
////            exifOrientation = .left
////        case UIDeviceOrientation.landscapeLeft:       // Device oriented horizontally, home button on the right
////            exifOrientation = .upMirrored
////        case UIDeviceOrientation.landscapeRight:      // Device oriented horizontally, home button on the left
////            exifOrientation = .down
////        case UIDeviceOrientation.portrait:            // Device oriented vertically, home button on the bottom
////            exifOrientation = .up
////        default:
////            exifOrientation = .up
////        }
////        return exifOrientation
//    }
    
    public func exifOrientationFromDeviceOrientation() -> CGImagePropertyOrientation {
        // We get the PHYSICAL device orientation,
        // even if the UI is locked in landscape.
        let curDeviceOrientation = UIDevice.current.orientation
        
        let exifOrientation: CGImagePropertyOrientation
        
        switch curDeviceOrientation {
        case .portraitUpsideDown:  // Device oriented vertically, home button on the top
            exifOrientation = .left
        case .landscapeLeft:       // Device oriented horizontally, home button on the right
            // CORRECTED: This should be .upMirrored or .left
            exifOrientation = .left
        case .landscapeRight:      // Device oriented horizontally, home button on the left
            // CORRECTED: This should be .downMirrored or .right
            exifOrientation = .right
        case .portrait:            // Device oriented vertically, home button on the bottom
            exifOrientation = .up
        default:
            // Use the last known valid orientation, or default to .up.
            // For a landscape-locked app, .right is a good default.
            exifOrientation = .right
        }
        return exifOrientation
    }
}


