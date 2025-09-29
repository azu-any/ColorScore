//
//  CameraView.swift
//  AppAccesibilidad
//
//  Created by Azuany Mila Cerón on 9/29/25.
//


import SwiftUI

struct CameraView: UIViewControllerRepresentable {
    
    // This function creates the initial view controller.
    // It's called only once.
    func makeUIViewController(context: Context) -> ViewController {
        // Create an instance of your custom ViewController
        return ViewController()
    }
    
    // This function is for passing data from SwiftUI to the ViewController.
    // Since our camera view is self-contained, we can leave this empty.
    func updateUIViewController(_ uiViewController: ViewController, context: Context) {
        // No updates needed for this simple case.
    }
}