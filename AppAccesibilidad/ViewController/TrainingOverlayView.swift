//
//  TrainingOverlayView.swift
//  AppAccesibilidad
//
//  Created by Azuany Mila Cerón on 11/6/25.
//


import UIKit

class TrainingOverlayView: UIView {

    // MARK: - UI Components
    
    // Dim the background to make text readable
    private let backgroundDimView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        return view
    }()

    // State 1: "Pre-Training"
    let startButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Start Calibration", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        button.backgroundColor = .systemBlue
        button.tintColor = .white
        button.layer.cornerRadius = 10
        button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        return button
    }()
    
    private let instructionLabel: UILabel = {
        let label = UILabel()
        label.text = "Point the camera at the game,\nensuring players are visible."
        label.textColor = .white
        label.font = .systemFont(ofSize: 16)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    // State 2: "Is Training"
    private let progressLabel: UILabel = {
        let label = UILabel()
        label.text = "Calibrating..."
        label.textColor = .white
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textAlignment = .center
        return label
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .white
        return indicator
    }()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupViews() {
        // Add all components
        addSubview(backgroundDimView)
        addSubview(startButton)
        addSubview(instructionLabel)
        addSubview(progressLabel)
        addSubview(activityIndicator)
        
        // --- Layout (Example using 'center' and 'frame') ---
        // You would use AutoLayout constraints
        backgroundDimView.frame = self.bounds
        
        // State 1
        instructionLabel.frame = CGRect(x: 0, y: 0, width: self.frame.width - 40, height: 50)
        instructionLabel.center = CGPoint(x: self.center.x, y: self.center.y - 60)
        
        startButton.frame = CGRect(x: 0, y: 0, width: 200, height: 50) // Size will be set by insets
        startButton.sizeToFit()
        startButton.center = self.center
        
        // State 2
        progressLabel.frame = CGRect(x: 0, y: 0, width: 200, height: 30)
        progressLabel.center = self.center
        
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        activityIndicator.center = CGPoint(x: self.center.x, y: self.center.y - 50)
        
        // Set the initial state
        showStartButton()
    }

    // MARK: - Public API (State Control)
    
    /// Configures the view for the `.preTraining` state.
    func showStartButton() {
        self.isHidden = false
        
        startButton.isHidden = false
        instructionLabel.isHidden = false
        
        progressLabel.isHidden = true
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
    
    /// Configures the view for the `.isTraining` state.
    func showTrainingProgress(secondsRemaining: Int) {
        self.isHidden = false
        
        startButton.isHidden = true
        instructionLabel.isHidden = true
        
        progressLabel.isHidden = false
        progressLabel.text = "Calibrating... \(secondsRemaining)s"
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    /// Configures the view for the `.isDetecting` state.
    func hide() {
        self.isHidden = true
        activityIndicator.stopAnimating()
    }
}
