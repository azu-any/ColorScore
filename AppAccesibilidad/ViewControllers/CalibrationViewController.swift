//
//  CalibrationViewController.swift
//  TestModel Camera
//
//  Created by Azuany Mila Cerón on 11/8/25.
//


import UIKit
import AVFoundation
import Vision


protocol CalibrationViewControllerDelegate: AnyObject {
    
    /// Called when the classifier has been successfully fitted.
    /// - Parameter classifier: The newly fitted TeamClassifier instance.
    func calibrationDidFinish(with classifier: TeamClassifier)
    
    /// Called if the user cancels the calibration or if it fails.
    func calibrationDidCancel()
}


class CalibrationViewController: VisionViewController {
    
    // MARK: - Delegate
    weak var delegate: CalibrationViewControllerDelegate?
    
    // MARK: - Properties
    private let classifier = TeamClassifier()
    private var collectedCrops: [CGImage] = []
    private let context = CIContext()
//    private var requests = [VNRequest]()
    
    // --- State & Timer ---
    private let calibrationDuration: TimeInterval = 10.0
    private var timer: Timer?
    private var startTime: Date?
    private var isCollecting = false
    
    // --- UI Elements ---
    private let instructionLabel = UILabel()
    private let timerLabel = UILabel()
    private let cancelButton = UIButton(type: .system)
    private let loadingIndicator = UIActivityIndicatorView(style: .large)
    private let loadingLabel = UILabel()

    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        // We call super.setupAVCapture() which calls setupVision()
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startCalibration()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Clean up the timer
        timer?.invalidate()
        timer = nil
    }
    
    
    // MARK: - Vision Processing
    
    override func visionService(_ service: VisionProcessor, didFind results: [VNRecognizedObjectObservation], on buffer: CVPixelBuffer) {
        
        // --- 1. Call super (This fixes "I cannot see the detections") ---
        // This calls the parent's implementation, which calls `drawVisionRequestResults`.
        
        print("Frame processed. Detections found: \(results.count)")
        
        super.visionService(service, didFind: results, on: buffer)
        
        // --- 2. Check if we are in the collecting state ---
        guard isCollecting else { return }
        
        // --- 3. Run the cropping logic (This fixes "Collected 0 crops") ---
        // We do this on a background thread to avoid blocking the main thread
        // with CIContext image creation.
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            let ciImage = CIImage(cvPixelBuffer: buffer)
            var newCrops: [CGImage] = []
            
            for observation in results {
                // Get the bounding box from the observation
                let boundingBox = observation.boundingBox
                
                // Use the bufferSize property from the base class for accuracy
                let pixelRect = VNImageRectForNormalizedRect(boundingBox,
                                                             Int(self.bufferSize.width),
                                                             Int(self.bufferSize.height))
                
                // Crop the CIImage
                let croppedCIImage = ciImage.cropped(to: pixelRect)
                
                // Convert to CGImage
                if let cgImage = self.context.createCGImage(croppedCIImage, from: croppedCIImage.extent) {
                    newCrops.append(cgImage)
                }
            }
            
            // Add new crops to the main array (on the main thread)
            if !newCrops.isEmpty {
                DispatchQueue.main.async {
                    self.collectedCrops.append(contentsOf: newCrops)
                }
            }
        }
    }

    // MARK: - Core Logic
    
    private func startCalibration() {
        print("Starting calibration...")
        // Reset state
        isCollecting = true
        collectedCrops.removeAll()
        startTime = Date()
        
        // Setup timer
        timerLabel.text = String(format: "%.1f", calibrationDuration)
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
        
        // Show collecting UI
        showCollectingUI(true)
        startCaptureSession()
    }
    
    @objc private func updateTimer() {
        guard let startTime = startTime else { return }
        
        let elapsed = Date().timeIntervalSince(startTime)
        let remaining = calibrationDuration - elapsed
        
        if remaining > 0 {
            timerLabel.text = String(format: "%.1f", remaining)
        } else {
            // Time's up!
            timerLabel.text = "0.0"
            timer?.invalidate()
            timer = nil
            
            // Move to the next state
            startFitting()
        }
    }
    
    private func startFitting() {
        print("Calibration time finished. Collected \(collectedCrops.count) crops.")
        isCollecting = false
        
        showLoadingUI(true)
        
        Task {
            do {
                // Copy crops to avoid thread issues, though main thread is safe
                let cropsToFit = self.collectedCrops
                
                guard !cropsToFit.isEmpty else {
                    print("No crops collected. Cancelling.")
                    throw TeamClassifier.ClassifierError.notEnoughData
                }
                
                // This runs on a background thread
                try await classifier.fit(on: cropsToFit)
                
                print("✅ Fitting complete.")
                self.delegate?.calibrationDidFinish(with: self.classifier)
                
            } catch {
                print("❌ Fitting failed: \(error.localizedDescription)")
                showErrorAlert(message: error.localizedDescription)
            }
        }
    }
    
    // MARK: - Capture & Cropping
    
    /// We override the base class's captureOutput to ADD cropping logic.
//    override func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
//         // This synchronously performs the request and calls the completion handler
//        // which will (on the main thread) call `drawVisionRequestResults`
//        super.captureOutput(output, didOutput: sampleBuffer, from: connection)
//        
//        guard isCollecting else { return }
//        
//        // Get the results that the `super.captureOutput` just populated
//        guard let results = self.visionProcessor.requests.first?.results as? [VNRecognizedObjectObservation],
//              !results.isEmpty,
//              let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
//        else {
//            return
//        }
//        
//        // Background thread to avoid blocking the main thread with CIContext image creation
//        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
//            let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
//            let context = CIContext()
//            
//            var newCrops: [CGImage] = []
//            
//            for observation in results {
//                // Convert bounding box to pixel coordinates
//                let boundingBox = observation.boundingBox
//                let imageSize = ciImage.extent.size
//                
//                guard let bufferSize = self?.bufferSize else { continue }
//                
//                let pixelRect = VNImageRectForNormalizedRect(boundingBox,
//                                                             Int(bufferSize.width),
//                                                             Int(bufferSize.height))
//                
//                let croppedCIImage = ciImage.cropped(to: pixelRect)
//                if let cgImage = context.createCGImage(croppedCIImage, from: croppedCIImage.extent) {
//                    newCrops.append(cgImage)
//                }
//            }
//            
//            // Add new crops to the main array on the main thread
//            DispatchQueue.main.async {
//                self?.collectedCrops.append(contentsOf: newCrops)
//            }
//        }
//    }

    // MARK: - UI & Actions
    
    @objc private func cancelButtonTapped() {
        // Stop everything and tell the delegate we're cancelled.
        timer?.invalidate()
        timer = nil
        isCollecting = false
        
        delegate?.calibrationDidCancel()
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Calibration Failed",
                                      message: "Could not analyze teams. \(message)",
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { [weak self] _ in
            self?.delegate?.calibrationDidCancel()
        }))
        
        alert.addAction(UIAlertAction(title: "Try Again", style: .default, handler: { [weak self] _ in
            // Reset UI and start over
            self?.showLoadingUI(false)
            self?.startCalibration()
        }))
        
        self.present(alert, animated: true)
    }

    // MARK: - UI Setup
    
    private func setupUI() {
        // --- HUD Panel for Collections ---
        let blurEffect = UIBlurEffect(style: .dark)
        let hudPanel = UIVisualEffectView(effect: blurEffect)
        hudPanel.translatesAutoresizingMaskIntoConstraints = false
        hudPanel.layer.cornerRadius = 22
        hudPanel.clipsToBounds = true
        
        // We will add labels to the panel's contentView
        let contentView = hudPanel.contentView
        view.addSubview(hudPanel)

        // --- Instructions ---
        instructionLabel.translatesAutoresizingMaskIntoConstraints = false
        instructionLabel.font = .systemFont(ofSize: 18, weight: .medium)
        instructionLabel.textColor = .white
        instructionLabel.textAlignment = .center
        instructionLabel.numberOfLines = 0
        instructionLabel.text = "Point camera at players to analyze teams."
        contentView.addSubview(instructionLabel) // <-- Add to contentView
        
        // --- Timer ---
        timerLabel.translatesAutoresizingMaskIntoConstraints = false
        timerLabel.font = .monospacedDigitSystemFont(ofSize: 52, weight: .bold)
        timerLabel.textColor = .white
        timerLabel.textAlignment = .center
        contentView.addSubview(timerLabel) // <-- Add to contentView
        
        // --- Cancel Button ---
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.titleLabel?.font = .systemFont(ofSize: 18)
        cancelButton.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        cancelButton.layer.cornerRadius = 15
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        view.addSubview(cancelButton) // <-- Add to main view
        
        // --- Full-Screen Loading UI (for fitting) ---
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.color = .white
        
        loadingLabel.translatesAutoresizingMaskIntoConstraints = false
        loadingLabel.font = .systemFont(ofSize: 20, weight: .medium)
        loadingLabel.textColor = .white
        loadingLabel.text = "Analyzing teams..."

        // Add loading UI to a full-screen blur view that is initially hidden
        let loadingBlurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        loadingBlurView.translatesAutoresizingMaskIntoConstraints = false
        loadingBlurView.contentView.addSubview(loadingIndicator)
        loadingBlurView.contentView.addSubview(loadingLabel)
        
        // Keep a reference to it so we can hide/show it
        loadingBlurView.tag = 100 // Tag to find it later
        view.addSubview(loadingBlurView)
        
        // --- Layout ---
        NSLayoutConstraint.activate([
            // HUD Panel at the top
            hudPanel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            hudPanel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            hudPanel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            
            // Instruction label inside HUD
            instructionLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            instructionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            instructionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Timer label inside HUD
            timerLabel.topAnchor.constraint(equalTo: instructionLabel.bottomAnchor, constant: 10),
            timerLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            timerLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16), // Pin bottom
            
            // Cancel button at the bottom
            cancelButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            cancelButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cancelButton.widthAnchor.constraint(equalToConstant: 120),
            cancelButton.heightAnchor.constraint(equalToConstant: 50),
            
            // Full-screen loading UI (hidden by default)
            loadingBlurView.topAnchor.constraint(equalTo: view.topAnchor),
            loadingBlurView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            loadingBlurView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingBlurView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: loadingBlurView.contentView.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: loadingBlurView.contentView.centerYAnchor, constant: -20),
            
            loadingLabel.topAnchor.constraint(equalTo: loadingIndicator.bottomAnchor, constant: 20),
            loadingLabel.centerXAnchor.constraint(equalTo: loadingBlurView.contentView.centerXAnchor)
        ])
        
        // Start with loading UI hidden
        showLoadingUI(false)
    }
    private func showCollectingUI(_ show: Bool) {
        view.subviews.first(where: { $0 is UIVisualEffectView && $0.tag != 100 })?.isHidden = !show
        cancelButton.isHidden = !show
    }
    
    private func showLoadingUI(_ show: Bool) {
        // Hide collecting UI
        showCollectingUI(false)
        
        guard let loadingView = view.viewWithTag(100) else { return }
            
        // Show/hide loading UI
        loadingView.isHidden = !show
        
        if show {
            loadingIndicator.startAnimating()
        } else {
            loadingIndicator.stopAnimating()
        }
    }
}
