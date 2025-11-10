//
//  CameraView.swift
//  AppAccesibilidad
//
//  Created by Azuany Mila Cerón on 9/29/25.
//


import SwiftUI

struct CameraView: UIViewControllerRepresentable {
    
    var settings: MatchSettings
    var onCancel: () -> Void
    @Binding var isCalibrating: Bool
    
    // This function creates the initial view controller.
    // It's called only once.
    func makeUIViewController(context: Context) -> LiveAnalysisViewController { // ViewController {
        let viewController = LiveAnalysisViewController()
        viewController.settings = settings
        viewController.setZoom(factor: settings.zoom)
        viewController.coordinator = context.coordinator
        context.coordinator.viewController = viewController
        return viewController
    }
    
    // This function is for passing data from SwiftUI to the ViewController.
    // Since our camera view is self-contained, we can leave this empty.
    func updateUIViewController(_ uiViewController: LiveAnalysisViewController, context: Context) {
        uiViewController.settings = settings
        uiViewController.setZoom(factor: settings.zoom)
        
        if isCalibrating {
            uiViewController.presentCalibrationViewIfNeeded()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self,
                    onCancel: onCancel,
                    isCalibrating: $isCalibrating
        )
    }
    
    class Coordinator: NSObject, CalibrationViewControllerDelegate {
        var parent: CameraView
        var onCancel: () -> Void
        weak var viewController: VisionViewController?
        @Binding var isCalibrating: Bool
        
        init(
            parent: CameraView,
            onCancel: @escaping () -> Void,
            isCalibrating: Binding<Bool>
        ) {
            self.parent = parent
            self.onCancel = onCancel
            self._isCalibrating = isCalibrating
        }
        
        func calibrationDidFinish(with classifier: TeamClassifier) {
            DispatchQueue.main.async {
                if let liveVC = self.viewController as? LiveAnalysisViewController {
                    // 2. Set the 'classifier' property on that specific class
                    liveVC.classifier = classifier
                }
//                self.viewController?.teamClassifier = classifier
                
                // Dismiss the modal
                self.viewController?.dismiss(animated: true) {
                            
                    self.isCalibrating = false
                }
            }
        }
        
        func calibrationDidCancel() {
            DispatchQueue.main.async {
            
                self.viewController?.dismiss(animated: true) {
                    self.isCalibrating = false
                    self.onCancel()
                }
            }
        }
    }
}
