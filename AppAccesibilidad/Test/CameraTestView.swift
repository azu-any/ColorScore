//
//  CameraTestView.swift
//  AppAccesibilidad
//
//  Created by Azuany Mila Cerón on 11/5/25.
//

import SwiftUI

struct CameraTestView: View {
    @StateObject private var trackingModel = TrackingModel()
    @State private var imageSize: CGSize = .zero
    @State private var sliderValue: Double = .zero

    private let boundingBoxPadding: CGFloat = 4.0
    private let asset = NSDataAsset(name: "humanWalking")
    
    @State private var showSetting: Bool = false

    
    var body: some View {
        
    HStack(spacing: 16) {
            if let image = trackingModel.previewImage?.image {
                image
                    .resizable()
                    .scaledToFit()
                    .overlay(content: {
                        GeometryReader { geometry in
                            DispatchQueue.main.async {
                                self.imageSize = geometry.size
                            }
                            return Color.clear
                        }
                    })
                    .overlay(content: {
                        if trackingModel.isTracking {
                            ForEach(trackingModel.trackedObjects) { object in
                                let rect = object.rect
                                if rect != .zero {
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(.black, style: .init(lineWidth: 1.0))
                                        .frame(width: rect.width + boundingBoxPadding*2, height: rect.height + boundingBoxPadding*2)
                                        .position(CGPoint(x: rect.midX, y: rect.midY))

                                }
                            }
                        }
                    })
            } else {
                Rectangle()
                    .fill(.black.opacity(0.8))
                    .aspectRatio(0.8, contentMode: .fill)
                    .padding()
            }
            
            Button(action: {
                trackingModel.isTracking.toggle()
            }, label: {
                Text("\(trackingModel.isTracking ? "Stop" : "Start") Tracking")
                    .foregroundStyle(.black)
                    .padding(.all)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(.black, lineWidth: 2.0))
            })

        }
        .ignoresSafeArea()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .contentShape(Rectangle())
        .padding(.all, 32)
//        .padding(.top, 16)
        .onTapGesture {
            showSetting = false
        }
        .task {
            await trackingModel.camera.start()
        }
        .onDisappear {
//            trackingModel.camera.isPreviewPaused = true
            trackingModel.isTracking = false
            trackingModel.camera.stop()
        }
        .onChange(of: imageSize, {
            trackingModel.setFrameSize(imageSize)
        })
    }
    
}

#Preview {
    CameraTestView()
}
