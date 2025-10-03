//
//  ContentView 2.swift
//  AppAccesibilidad
//
//  Created by Azuany Mila Cerón on 9/29/25.
//


import SwiftUI

struct ContentView: View {
    var body: some View {
        // Tabs for testing
        CameraView()
            .ignoresSafeArea(edges: .all)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
