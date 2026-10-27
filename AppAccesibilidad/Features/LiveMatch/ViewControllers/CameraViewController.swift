//
//  ViewController.swift
//  AppAccesibilidad
//
//  Created by Azuany Mila Cerón on 10/7/25.
//


import UIKit
import AVFoundation
import Vision
import CoreImage

class CameraViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    var bufferSize: CGSize = CGSize(width: 640, height: 480)
    var rootLayer: CALayer! = nil
    
    private var previewView = UIView()
    private let session = AVCaptureSession()
    private var previewLayer: AVCaptureVideoPreviewLayer! = nil
    private let filteredPreviewLayer = CALayer()
    private let ciContext = CIContext(options: [.useSoftwareRenderer: false, .cacheIntermediates: false])
    private(set) var currentFilter: CameraFilter = .none
    private var currentInterfaceOrientation: UIInterfaceOrientation = .landscapeRight
    private let videoDataOutput = AVCaptureVideoDataOutput()
    
    private let videoDataOutputQueue = DispatchQueue(label: "VideoDataOutput", qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem)
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        renderFilteredFrame(from: sampleBuffer)
    }
    
    func setCameraFilter(_ filter: CameraFilter) {
        guard currentFilter != filter else { return }
        currentFilter = filter
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            self.filteredPreviewLayer.isHidden = (filter == .none)
            if filter == .none {
                self.filteredPreviewLayer.contents = nil
            }
            CATransaction.commit()
        }
    }
    
    func renderFilteredFrame(from sampleBuffer: CMSampleBuffer) {
        let filter = currentFilter
        guard filter != .none,
              let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        var ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        if currentInterfaceOrientation == .landscapeLeft {
            ciImage = ciImage.oriented(.down)
        }
        
        let filteredImage = filter.apply(to: ciImage)
        guard let cgImage = ciContext.createCGImage(filteredImage, from: ciImage.extent) else {
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self, self.currentFilter != .none else { return }
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            self.filteredPreviewLayer.isHidden = false
            self.filteredPreviewLayer.contents = cgImage
            CATransaction.commit()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(previewView)
        self.previewView.frame = self.view.bounds
        self.rootLayer = self.previewView.layer
        setupAVCapture()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        // Ensure the previewView itself fills the entire screen
        previewView.frame = self.view.bounds
        
        // Ensure the camera preview layer fills the previewView
        previewLayer?.frame = previewView.bounds
        filteredPreviewLayer.frame = previewView.bounds
        CATransaction.commit()
        
        let interfaceOrientation = self.view.window?.windowScene?.effectiveGeometry.interfaceOrientation ?? .landscapeRight
        self.currentInterfaceOrientation = interfaceOrientation
        
        // This fixes the rotated camera preview.
        if let connection = self.previewLayer?.connection {
            // Set the preview layer's orientation to match the interface
            let rotationAngle: CGFloat
            switch interfaceOrientation {
            case .landscapeLeft:
                rotationAngle = 180
            case .landscapeRight:
                rotationAngle = 0
            default:
                // Default to landscape right if in portrait (which it shouldn't be)
                rotationAngle = 0
            }
            if connection.isVideoRotationAngleSupported(rotationAngle) {
                connection.videoRotationAngle = rotationAngle
            }
        }
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
        rootLayer = previewView.layer
        
        // Safely select a video device without force-unwrapping
        guard let videoDevice = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInWideAngleCamera],
            mediaType: .video,
            position: .back
        ).devices.first else {
            print("No back video camera device available.")
            return
        }
        
        let deviceInput: AVCaptureDeviceInput
        do {
            deviceInput = try AVCaptureDeviceInput(device: videoDevice)
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
            try videoDevice.lockForConfiguration()
            let dimensions = CMVideoFormatDescriptionGetDimensions(videoDevice.activeFormat.formatDescription)
            bufferSize.width = CGFloat(dimensions.width)
            bufferSize.height = CGFloat(dimensions.height)
            videoDevice.unlockForConfiguration()
        } catch {
            print(error)
        }
        
        session.commitConfiguration()
        let layer = AVCaptureVideoPreviewLayer(session: session)
        layer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        layer.frame = rootLayer.bounds
        rootLayer.addSublayer(layer)
        previewLayer = layer
        
        filteredPreviewLayer.contentsGravity = .resizeAspectFill
        filteredPreviewLayer.frame = rootLayer.bounds
        filteredPreviewLayer.isHidden = (currentFilter == .none)
        rootLayer.addSublayer(filteredPreviewLayer)
    }
    
    func startCaptureSession() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.session.startRunning()
        }
    }
    
    func stopCaptureSession() {
        if session.isRunning {
            session.stopRunning()
        }
    }
    
    deinit {
        if session.isRunning {
            session.stopRunning()
        }
        filteredPreviewLayer.removeFromSuperlayer()
        previewLayer?.removeFromSuperlayer()
        previewLayer = nil
        print("VisionViewController deallocated and capture session torn down.")
    }
    
    // Clean up capture setup
    func teardownAVCapture() {
        filteredPreviewLayer.removeFromSuperlayer()
        previewLayer?.removeFromSuperlayer()
        previewLayer = nil
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.session.stopRunning()
        }
    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput, didDrop didDropSampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // print("frame dropped")
    }
    
    
    public func exifOrientationFromDeviceOrientation() -> CGImagePropertyOrientation {
        return .up
    }
}
