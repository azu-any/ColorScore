//
//  CameraView.swift
//  AppAccesibilidad
//
//  Created by Azuany Mila Cerón on 9/29/25.
//


import SwiftUI

struct CameraView: UIViewControllerRepresentable {
    let calibrationTrigger: Int

    // This function creates the initial view controller.
    // It's called only once.
    func makeUIViewController(context: Context) -> VisionViewController { // ViewController {
        // Create an instance of your custom ViewController
        return VisionViewController()
    }
    
    // This function is for passing data from SwiftUI to the ViewController.
    // Since our camera view is self-contained, we can leave this empty.
    func updateUIViewController(_ uiViewController: VisionViewController, context: Context) {
        // No updates needed for this simple case.
        if self.calibrationTrigger > 0 {
            uiViewController.calibrateTeamsButtonPressed()
        }
    }
}
