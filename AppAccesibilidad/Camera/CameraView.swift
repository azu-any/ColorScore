//
//  CameraView.swift
//  AppAccesibilidad
//
//  Created by Azuany Mila Cerón on 9/29/25.
//


import SwiftUI

struct CameraView: UIViewControllerRepresentable {
    
    var settings: MatchSettings

    // This function creates the initial view controller.
    // It's called only once.
    func makeUIViewController(context: Context) -> LiveAnalysisViewController { // ViewController {
        let viewController = LiveAnalysisViewController()
        viewController.settings = settings
        viewController.setZoom(factor: settings.zoom)
        return viewController
    }
    
    // This function is for passing data from SwiftUI to the ViewController.
    // Since our camera view is self-contained, we can leave this empty.
    func updateUIViewController(_ uiViewController: LiveAnalysisViewController, context: Context) {
        uiViewController.settings = settings
        uiViewController.setZoom(factor: settings.zoom)
    }
}
