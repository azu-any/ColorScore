//
//  ContentView 2.swift
//  AppAccesibilidad
//
//  Created by Azuany Mila Cerón on 9/29/25.
//


import SwiftUI

struct ContentView: View {
    var body: some View {
        // Use your representable view here
        CameraView()
//            .ignoresSafeArea() // Makes the camera view fill the entire screen
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
