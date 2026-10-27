//
//  CalibrationViewController.swift
//  TestModel Camera
//
//  Created by Azuany Mila Cerón on 11/8/25.
//


import UIKit
import AVFoundation
import Vision
import SwiftUI


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
    private var collectedCrops: [CIImage] = []
    
    var frameCount: Int = 0
    var frameSkip: Int = 10
    
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
        
        stopCaptureSession()
        
    }
    
    
    // MARK: - Vision Processing
    
    override func visionService(_ service: VisionProcessor, didFind results: [VNRecognizedObjectObservation], on buffer: CVPixelBuffer) {
        
        print("Frame processed. Detections found: \(results.count)")
        
        if frameCount == frameSkip  {
            frameCount = 0
            return
        } else if frameCount != 0  {
            frameCount += 1
            return
        }
        frameCount += 1
        
        super.visionService(service, didFind: results, on: buffer)
        
        // Check if we are in the collecting state
        guard isCollecting else { return }
        
        // Run the cropping logic on a background thread
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            let ciImage = CIImage(cvPixelBuffer: buffer)
            var newCrops: [CIImage] = []
            
            for observation in results {
                let boundingBox = observation.boundingBox
                
                let pixelRect = VNImageRectForNormalizedRect(boundingBox,
                                                             Int(self.bufferSize.width),
                                                             Int(self.bufferSize.height))
                
                let croppedCIImage = ciImage.cropped(to: pixelRect)
                newCrops.append(croppedCIImage)
            }
            
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
        timerLabel.accessibilityValue = "10 segundos restantes"
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
        
        // Show collecting UI
        showCollectingUI(true)
        startCaptureSession()
        
        // VoiceOver announcement
        UIAccessibility.post(
            notification: .announcement,
            argument: "Iniciando calibración de 10 segundos. Apunta la cámara a los jugadores."
        )
    }
    
    @objc private func updateTimer() {
        guard let startTime = startTime else { return }
        
        let elapsed = Date().timeIntervalSince(startTime)
        let remaining = calibrationDuration - elapsed
        
        if remaining > 0 {
            timerLabel.text = String(format: "%.1f", remaining)
            let wholeSeconds = Int(ceil(remaining))
            timerLabel.accessibilityValue = "\(wholeSeconds) segundos restantes"
        } else {
            // Time's up!
            timerLabel.text = "0.0"
            timerLabel.accessibilityValue = "0 segundos restantes"
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
        UIAccessibility.post(
            notification: .announcement,
            argument: "Analizando a los equipos. Por favor espera."
        )
        
        Task {
            do {
                let cropsToFit = self.collectedCrops
                
                guard !cropsToFit.isEmpty else {
                    print("No crops collected. Cancelling.")
                    throw TeamClassifier.ClassifierError.notEnoughData
                }
                
                // This runs on a background thread
                try await classifier.fit(on: cropsToFit)
                
                print("✅ Fitting complete.")
                UIAccessibility.post(
                    notification: .announcement,
                    argument: "Calibración completada con éxito."
                )
                self.delegate?.calibrationDidFinish(with: self.classifier)
                
            } catch {
                print("❌ Fitting failed: \(error.localizedDescription)")
                showErrorAlert(message: error.localizedDescription)
            }
        }
    }

    
    
    // MARK: - Capture & Cropping
    
    override func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        super.captureOutput(output, didOutput: sampleBuffer, from: connection)
    }

    // MARK: - UI & Actions
    
    @objc private func cancelButtonTapped() {
        instructionLabel.isHidden = true
        
        timer?.invalidate()
        timer = nil
        isCollecting = false
        
        delegate?.calibrationDidCancel()
    }
    
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error de calibración",
                                      message: "No se pudo analizar a los equipos. Asegúrate de apuntar hacia los jugadores en la cancha.",
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: { [weak self] _ in
            self?.delegate?.calibrationDidCancel()
        }))
        
        alert.addAction(UIAlertAction(title: "Intentar de nuevo", style: .default, handler: { [weak self] _ in
            self?.showLoadingUI(false)
            self?.startCalibration()
        }))
        
        self.present(alert, animated: true)
    }

    // MARK: - UI Setup
    
    private func setupUI() {
        // --- HUD Panel with Liquid Glass Effect ---
        let glassEffect = UIGlassEffect()
        let hudPanel = UIVisualEffectView(effect: glassEffect)
        hudPanel.translatesAutoresizingMaskIntoConstraints = false
        hudPanel.layer.cornerRadius = 24
        hudPanel.clipsToBounds = true
        hudPanel.layer.shadowColor = UIColor.black.cgColor
        hudPanel.layer.shadowOpacity = 0.1
        hudPanel.layer.shadowOffset = CGSize(width: 0, height: 4)
        hudPanel.layer.shadowRadius = 12
        hudPanel.layer.masksToBounds = false
        
        // Add shadow to container
        let hudContainer = UIView()
        hudContainer.translatesAutoresizingMaskIntoConstraints = false
        hudContainer.layer.shadowColor = UIColor.black.cgColor
        hudContainer.layer.shadowOpacity = 0.15
        hudContainer.layer.shadowOffset = CGSize(width: 0, height: 4)
        hudContainer.layer.shadowRadius = 12
        hudContainer.addSubview(hudPanel)
        view.addSubview(hudContainer)
        
        let contentView = hudPanel.contentView
        
        // --- Icon at the top ---
        let iconView = UIImageView(image: UIImage(systemName: "camera.viewfinder"))
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.tintColor = .systemBlue
        iconView.contentMode = .scaleAspectFit
        iconView.isAccessibilityElement = false
        contentView.addSubview(iconView)

        // --- Instructions ---
        instructionLabel.translatesAutoresizingMaskIntoConstraints = false
        instructionLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        instructionLabel.adjustsFontForContentSizeCategory = true
        instructionLabel.textColor = .label
        instructionLabel.textAlignment = .center
        instructionLabel.numberOfLines = 0
        instructionLabel.text = "Apunta la cámara a los jugadores para analizar a los equipos."
        contentView.addSubview(instructionLabel)
        
        // --- Timer ---
        timerLabel.translatesAutoresizingMaskIntoConstraints = false
        timerLabel.font = .monospacedDigitSystemFont(ofSize: 64, weight: .bold)
        timerLabel.textColor = .label
        timerLabel.textAlignment = .center
        timerLabel.accessibilityLabel = "Tiempo restante de calibración"
        timerLabel.accessibilityTraits = .updatesFrequently
        contentView.addSubview(timerLabel)
        
        // --- Cancel Button with Liquid Glass ---
        let cancelGlassEffect = UIGlassEffect()
        cancelGlassEffect.isInteractive = true
        let cancelGlassView = UIVisualEffectView(effect: cancelGlassEffect)
        cancelGlassView.translatesAutoresizingMaskIntoConstraints = false
        cancelGlassView.layer.cornerRadius = 16
        cancelGlassView.clipsToBounds = true
        
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.setTitle("Cancelar", for: .normal)
        cancelButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
        cancelButton.titleLabel?.adjustsFontForContentSizeCategory = true
        cancelButton.setTitleColor(.label, for: .normal)
        cancelButton.backgroundColor = .clear
        cancelButton.accessibilityLabel = "Cancelar calibración"
        cancelButton.accessibilityHint = "Detiene la calibración y regresa a la vista de cámara"
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        
        cancelGlassView.contentView.addSubview(cancelButton)
        view.addSubview(cancelGlassView)
        
        // --- Full-Screen Loading UI with Liquid Glass ---
        let loadingGlassEffect = UIGlassEffect()
        let loadingGlassView = UIVisualEffectView(effect: loadingGlassEffect)
        loadingGlassView.translatesAutoresizingMaskIntoConstraints = false
        
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.color = .white
        loadingIndicator.style = .large
        loadingIndicator.accessibilityLabel = "Cargando"
        
        loadingLabel.translatesAutoresizingMaskIntoConstraints = false
        loadingLabel.font = UIFont.preferredFont(forTextStyle: .title3)
        loadingLabel.adjustsFontForContentSizeCategory = true
        loadingLabel.textColor = .white
        loadingLabel.text = "Analizando a los equipos..."
        
        loadingGlassView.contentView.addSubview(loadingIndicator)
        loadingGlassView.contentView.addSubview(loadingLabel)
        
        loadingGlassView.tag = 100
        view.addSubview(loadingGlassView)
        
        // --- Layout ---
        NSLayoutConstraint.activate([
            // HUD Container
            hudContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            hudContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            hudContainer.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor, constant: -32),
            
            // HUD Panel fills container
            hudPanel.topAnchor.constraint(equalTo: hudContainer.topAnchor),
            hudPanel.leadingAnchor.constraint(equalTo: hudContainer.leadingAnchor),
            hudPanel.trailingAnchor.constraint(equalTo: hudContainer.trailingAnchor),
            hudPanel.bottomAnchor.constraint(equalTo: hudContainer.bottomAnchor),
            
            // Icon at top
            iconView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            iconView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 44),
            iconView.heightAnchor.constraint(equalToConstant: 44),
            
            // Instruction label
            instructionLabel.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 12),
            instructionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            instructionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            
            // Timer label
            timerLabel.topAnchor.constraint(equalTo: instructionLabel.bottomAnchor, constant: 16),
            timerLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            timerLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            
            // Cancel button glass container
            cancelGlassView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
            cancelGlassView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cancelGlassView.widthAnchor.constraint(greaterThanOrEqualToConstant: 160),
            cancelGlassView.heightAnchor.constraint(greaterThanOrEqualToConstant: 56),
            
            // Cancel button fills glass view
            cancelButton.topAnchor.constraint(equalTo: cancelGlassView.contentView.topAnchor),
            cancelButton.leadingAnchor.constraint(equalTo: cancelGlassView.contentView.leadingAnchor, constant: 16),
            cancelButton.trailingAnchor.constraint(equalTo: cancelGlassView.contentView.trailingAnchor, constant: -16),
            cancelButton.bottomAnchor.constraint(equalTo: cancelGlassView.contentView.bottomAnchor),
            
            // Full-screen loading UI
            loadingGlassView.topAnchor.constraint(equalTo: view.topAnchor),
            loadingGlassView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            loadingGlassView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingGlassView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: loadingGlassView.contentView.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: loadingGlassView.contentView.centerYAnchor, constant: -30),
            
            loadingLabel.topAnchor.constraint(equalTo: loadingIndicator.bottomAnchor, constant: 24),
            loadingLabel.centerXAnchor.constraint(equalTo: loadingGlassView.contentView.centerXAnchor)
        ])
        
        // Start with loading UI hidden
        showLoadingUI(false)
    }
    private func showCollectingUI(_ show: Bool) {
        view.subviews.forEach { subview in
            if let effectView = subview.subviews.first as? UIVisualEffectView,
               effectView.tag != 100 {
                subview.isHidden = !show
            }
        }
        
        view.subviews.forEach { subview in
            if let glassView = subview as? UIVisualEffectView,
               glassView.tag != 100,
               glassView.contentView.subviews.contains(cancelButton) {
                glassView.isHidden = !show
            }
        }
    }
    
    private func showLoadingUI(_ show: Bool) {
        showCollectingUI(false)
        
        guard let loadingView = view.viewWithTag(100) else { return }
            
        loadingView.isHidden = !show
        
        if show {
            loadingIndicator.startAnimating()
        } else {
            loadingIndicator.stopAnimating()
        }
    }
}

// MARK: - SwiftUI Preview

#if DEBUG

private class CalibrationUIPreviewController: UIViewController {
    private let instructionLabel = UILabel()
    private let timerLabel = UILabel()
    private let cancelButton = UIButton(type: .system)
    private let loadingIndicator = UIActivityIndicatorView(style: .large)
    private let loadingLabel = UILabel()
    
    var showLoadingState = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .darkGray
        setupUI()
        
        timerLabel.text = "10.0"
        
        if showLoadingState {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.showLoadingUI(true)
            }
        }
    }
    
    private func setupUI() {
        let glassEffect = UIGlassEffect()
        let hudPanel = UIVisualEffectView(effect: glassEffect)
        hudPanel.translatesAutoresizingMaskIntoConstraints = false
        hudPanel.layer.cornerRadius = 24
        hudPanel.clipsToBounds = true
        
        let hudContainer = UIView()
        hudContainer.translatesAutoresizingMaskIntoConstraints = false
        hudContainer.layer.shadowColor = UIColor.black.cgColor
        hudContainer.layer.shadowOpacity = 0.15
        hudContainer.layer.shadowOffset = CGSize(width: 0, height: 4)
        hudContainer.layer.shadowRadius = 12
        hudContainer.addSubview(hudPanel)
        view.addSubview(hudContainer)
        
        let contentView = hudPanel.contentView
        
        let iconView = UIImageView(image: UIImage(systemName: "camera.viewfinder"))
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.tintColor = .systemBlue
        iconView.contentMode = .scaleAspectFit
        contentView.addSubview(iconView)

        instructionLabel.translatesAutoresizingMaskIntoConstraints = false
        instructionLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        instructionLabel.textColor = .label
        instructionLabel.textAlignment = .center
        instructionLabel.numberOfLines = 0
        instructionLabel.text = "Apunta la cámara a los jugadores para analizar a los equipos."
        contentView.addSubview(instructionLabel)
        
        timerLabel.translatesAutoresizingMaskIntoConstraints = false
        timerLabel.font = .monospacedDigitSystemFont(ofSize: 64, weight: .bold)
        timerLabel.textColor = .label
        timerLabel.textAlignment = .center
        contentView.addSubview(timerLabel)
        
        let cancelGlassEffect = UIGlassEffect(style: .clear)
        cancelGlassEffect.isInteractive = true
        let cancelGlassView = UIVisualEffectView(effect: cancelGlassEffect)
        cancelGlassView.translatesAutoresizingMaskIntoConstraints = false
        cancelGlassView.layer.cornerRadius = 16
        cancelGlassView.clipsToBounds = true
        
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.setTitle("Cancelar", for: .normal)
        cancelButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
        cancelButton.setTitleColor(.label, for: .normal)
        cancelButton.backgroundColor = .clear
        
        cancelGlassView.contentView.addSubview(cancelButton)
        view.addSubview(cancelGlassView)
        
        let loadingGlassEffect = UIGlassEffect(style: .clear)
        let loadingGlassView = UIVisualEffectView(effect: loadingGlassEffect)
        loadingGlassView.translatesAutoresizingMaskIntoConstraints = false
        
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.color = .white
        
        loadingLabel.translatesAutoresizingMaskIntoConstraints = false
        loadingLabel.font = UIFont.preferredFont(forTextStyle: .title3)
        loadingLabel.textColor = .white
        loadingLabel.text = "Analizando a los equipos..."

        loadingGlassView.contentView.addSubview(loadingIndicator)
        loadingGlassView.contentView.addSubview(loadingLabel)
        
        loadingGlassView.tag = 100
        view.addSubview(loadingGlassView)
        
        NSLayoutConstraint.activate([
            hudContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            hudContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            hudContainer.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor, constant: -32),
            
            hudPanel.topAnchor.constraint(equalTo: hudContainer.topAnchor),
            hudPanel.leadingAnchor.constraint(equalTo: hudContainer.leadingAnchor),
            hudPanel.trailingAnchor.constraint(equalTo: hudContainer.trailingAnchor),
            hudPanel.bottomAnchor.constraint(equalTo: hudContainer.bottomAnchor),
            
            iconView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            iconView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 44),
            iconView.heightAnchor.constraint(equalToConstant: 44),
            
            instructionLabel.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 12),
            instructionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            instructionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            
            timerLabel.topAnchor.constraint(equalTo: instructionLabel.bottomAnchor, constant: 16),
            timerLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            timerLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            
            cancelGlassView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
            cancelGlassView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cancelGlassView.widthAnchor.constraint(equalToConstant: 160),
            cancelGlassView.heightAnchor.constraint(equalToConstant: 56),
            
            cancelButton.topAnchor.constraint(equalTo: cancelGlassView.contentView.topAnchor),
            cancelButton.leadingAnchor.constraint(equalTo: cancelGlassView.contentView.leadingAnchor),
            cancelButton.trailingAnchor.constraint(equalTo: cancelGlassView.contentView.trailingAnchor),
            cancelButton.bottomAnchor.constraint(equalTo: cancelGlassView.contentView.bottomAnchor),
            
            loadingGlassView.topAnchor.constraint(equalTo: view.topAnchor),
            loadingGlassView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            loadingGlassView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingGlassView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: loadingGlassView.contentView.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: loadingGlassView.contentView.centerYAnchor, constant: -30),
            
            loadingLabel.topAnchor.constraint(equalTo: loadingIndicator.bottomAnchor, constant: 24),
            loadingLabel.centerXAnchor.constraint(equalTo: loadingGlassView.contentView.centerXAnchor)
        ])
        
        showLoadingUI(false)
    }
    
    private func showLoadingUI(_ show: Bool) {
        guard let loadingView = view.viewWithTag(100) else { return }
        loadingView.isHidden = !show
        
        if show {
            loadingIndicator.startAnimating()
        } else {
            loadingIndicator.stopAnimating()
        }
    }
}

#Preview("Calibration UI - Collecting") {
    CalibrationUIPreviewController()
}

#Preview("Calibration UI - Loading") {
    let vc = CalibrationUIPreviewController()
    vc.showLoadingState = true
    return vc
}

#endif
