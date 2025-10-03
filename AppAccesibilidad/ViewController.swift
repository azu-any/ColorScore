//
//  ViewController.swift
//  AppAccesibilidad
//
//  Created by Azuany Mila Cerón on 9/29/25.
//


import UIKit
import AVFoundation
import Vision // Vision is great for handling coordinate space transformations

class ViewController: UIViewController {

    // A simple UIView that will contain the video preview layer
    private let videoPreviewView = UIView()

    // MARK: - AVFoundation Properties
    private let captureSession = AVCaptureSession()
    private var previewLayer: AVCaptureVideoPreviewLayer!
    
    // Vision
    private var requests = [VNRequest]()

    // MARK: - Drawing Properties
    // An array to keep track of the bounding box layers we've drawn
    private var boundingBoxLayers = [CAShapeLayer]()

    // MARK: - View Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCamera()
        try? setupVision()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Ensure the preview layer's frame is updated when the view's layout changes
        previewLayer.frame = videoPreviewView.bounds
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        videoPreviewView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(videoPreviewView)
        NSLayoutConstraint.activate([
            videoPreviewView.topAnchor.constraint(equalTo: view.topAnchor),
            videoPreviewView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            videoPreviewView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            videoPreviewView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    func setupVision() throws {
        guard let modelURL = Bundle.main.url(forResource: "football-player-detection-v9-4", withExtension: "mlmodelc") else {
            throw NSError(domain: "ViewController", code: -1, userInfo: [NSLocalizedDescriptionKey: "Model file is missing"])
        }
        
        do {
            let visionModel = try VNCoreMLModel(for: MLModel(contentsOf: modelURL))
            let objectRecognition = VNCoreMLRequest(model: visionModel, completionHandler: { (request, error) in
//                print("Results", request.results?.count as Any)
//                // 1. Cast the results to the correct type.
                guard let results = request.results as? [VNRecognizedObjectObservation] else {
                    print("no results")
                    return
                }
                
                // 2. Process these results on the main thread to update the UI.
                DispatchQueue.main.async { [weak self] in
                    print("drawing boxes")
                    // 3. Call a new function to draw the bounding boxes from these results.
                    self?.drawVisionRequestResults(results)
                }
            })
            objectRecognition.imageCropAndScaleOption = .scaleFill

            self.requests = [objectRecognition]
        } catch let error as NSError {
            print("Model loading went wrong: \(error)")
        }
    }
    
    // Add this function to your ViewController
    func drawVisionRequestResults(_ results: [VNRecognizedObjectObservation]) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            // 1. Clear any old bounding boxes.
            clearOldBoundingBoxes() // Assumes you have the function from our previous example.
            
            // 2. Loop through each observation from the model.
            for observation in results {
                print(observation.labels)
                
                // You can inspect the observation's label to see what was detected.
                // For example: if let label = observation.labels.first?.identifier { print(label) }
                
                // Filter out detections with low confidence to reduce noise.
                guard observation.confidence > 0.6 else { // 60% confidence threshold
                    continue
                }
//                
                // The boundingBox is in NORMALIZED coordinates (0.0 to 1.0).
                // You MUST convert it to the screen's coordinate space.
                let objectBounds = previewLayer.layerRectConverted(fromMetadataOutputRect: observation.boundingBox)
                
                // 3. Create a CAShapeLayer for the bounding box.
                let shapeLayer = self.createBoundingBoxLayer()
                shapeLayer.frame = objectBounds
                
                // 4. Add the layer to your view and keep a reference to it.
                videoPreviewView.layer.addSublayer(shapeLayer)
                boundingBoxLayers.append(shapeLayer)
            }
        }
    }

    private func setupCamera() {
        // 1. Set a high-quality session preset
        captureSession.sessionPreset = .hd1920x1080

        // 2. Get the default back camera
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            print("Error: Could not find a back camera.")
            return
        }

        // 3. Create an input from the camera device
        guard let deviceInput = try? AVCaptureDeviceInput(device: videoDevice) else {
            print("Error: Could not create device input.")
            return
        }
        
        if captureSession.canAddInput(deviceInput) {
            captureSession.addInput(deviceInput)
        }

        // 4. Create a video data output to process frames
        let videoOutput = AVCaptureVideoDataOutput()
        // Use a background queue to process frames to avoid blocking the UI
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        
        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        }

        // 5. Setup the preview layer to display the camera feed
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        videoPreviewView.layer.addSublayer(previewLayer)

        // 6. Start the capture session on a background thread
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession.startRunning()
        }
    }

    // MARK: - Drawing Logic
    
    /// This is the main drawing function called from the capture delegate.
    /// - Parameter detections: An array of CGRects representing detected players.
    private func drawPlayerBoxes(on detections: [CGRect]) {
        // Drawing must be done on the main thread.
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // 1. Clear any previously drawn boxes.
            self.clearOldBoundingBoxes()
            
            // 2. Create and add a new layer for each detection.
            for playerBox in detections {
                let shapeLayer = self.createBoundingBoxLayer()
                shapeLayer.frame = playerBox
                
                // Add the new layer and keep a reference to it for later removal.
                self.videoPreviewView.layer.addSublayer(shapeLayer)
                self.boundingBoxLayers.append(shapeLayer)
            }
        }
    }

    /// Creates a styled CAShapeLayer for a bounding box.
    private func createBoundingBoxLayer() -> CAShapeLayer {
        let shapeLayer = CAShapeLayer()
        // The path is a rectangle that fills the layer's frame.
        shapeLayer.path = UIBezierPath(rect: CGRect(x: 0, y: 0, width: 1, height: 1)).cgPath
        shapeLayer.strokeColor = UIColor.yellow.cgColor
        shapeLayer.lineWidth = 4.0
        shapeLayer.fillColor = UIColor.clear.cgColor
        // This makes the layer's frame size relative to its path
        shapeLayer.shouldRasterize = true
//        shapeLayer.rasterizationScale = UIScreen.main.scale
        shapeLayer.rasterizationScale = view.traitCollection.displayScale
        return shapeLayer
    }

    /// Removes all previously drawn bounding box layers.
    private func clearOldBoundingBoxes() {
        boundingBoxLayers.forEach { $0.removeFromSuperlayer() }
        boundingBoxLayers.removeAll()
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
extension ViewController: AVCaptureVideoDataOutputSampleBufferDelegate {

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // This method is called for every frame captured by the camera.
        // 1. Get the pixel buffer from the video frame.
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        // 2. Create a Vision image request handler for the current frame.
        // The orientation is important for the model to "see" the image correctly.
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .right, options: [:])
        
        do {
            // 3. Perform your configured Vision request.
            // This triggers the model inference. The completion handler in setupVision() will be called when it's done.
            try imageRequestHandler.perform(self.requests)
        } catch {
            print(error)
        }
        
        // ---- ⚽️ YOUR ON-DEVICE MODEL LOGIC GOES HERE ⚽️ ----
        // 1. Run your Core ML model on the `sampleBuffer` or its underlying `CVPixelBuffer`.
        // 2. Your model will return results (e.g., bounding boxes in normalized coordinates).
        
        // For this example, we'll just SIMULATE a detection result.
        // We'll pretend the model found one player in the center of the screen.
//        let simulatedNormalizedRect = CGRect(x: 0.25, y: 0.35, width: 0.5, height: 0.3)
//
//        // ---- COORDINATE CONVERSION (CRITICAL STEP) ----
//        // You MUST convert the model's normalized coordinates (0.0 to 1.0)
//        // into the coordinate system of the view where you are drawing.
//        // `AVCaptureVideoPreviewLayer` provides a helper function for this.
//        let playerBoundingBox = previewLayer.layerRectConverted(fromMetadataOutputRect: simulatedNormalizedRect)
//        
//        // Now that we have the box in screen coordinates, we can draw it.
//        drawPlayerBoxes(on: [playerBoundingBox])
    }
}
