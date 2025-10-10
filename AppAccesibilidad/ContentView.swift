//
//  ContentView 2.swift
//  AppAccesibilidad
//
//  Created by Azuany Mila Cerón on 9/29/25.
//


import SwiftUI

struct ContentView: View {
    @State private var calibrationTrigger = 0

    var body: some View {
        // Tabs for testing
        ZStack {
            
            CameraView(calibrationTrigger: self.calibrationTrigger)
                .ignoresSafeArea(edges: .all)
            
//            VStack {
//                Spacer() // Pushes the button to the bottom
//                
//                Button(action: {
//                    // 3. The button's only job is to change the trigger's value.
//                    print("Calibrate button tapped!")
//                    self.calibrationTrigger += 1
//                }) {
//                    Text("Calibrate Teams")
//                        .font(.headline)
//                        .fontWeight(.bold)
//                        .padding()
//                        .background(Color.blue)
//                        .foregroundColor(.white)
//                        .cornerRadius(10)
//                }
//                .padding(.bottom, 30) // Add some padding from the bottom edge
//            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
