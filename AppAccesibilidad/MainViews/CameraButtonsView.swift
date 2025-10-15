//
//  CameraButtonsView.swift
//  AppAccesibilidad
//
//  Created by Daniela Renee on 03/10/25.
//

import SwiftUI

/// An accessible overlay you can place on top of a camera preview, optimized for horizontal (landscape) use.
/// - Top middle (overlay, .top): players' score with team shape + short name + score
/// - Left edge top: configuration button
/// - Left edge bottom: zoom control
///
/// This version uses @State so it runs standalone in previews.
/// Later, you can replace these with @Binding to connect to your camera/score logic.
struct CameraButtonsView: View {

    @State private var zoom: Double = 1.0
    private let minZoom: Double = 1.0
    private let maxZoom: Double = 5.0
    private let zoomStep: Double = 0.1

    @State private var leftScore: Int = 0
    @State private var rightScore: Int = 0

    // Team identifiers (short names) and their shapes
    @State private var leftTeamShortName: String = "LFT"
    @State private var rightTeamShortName: String = "RGT"

    // Team colors for the end shapes
    @State private var leftTeamColor: Color = .blue
    @State private var rightTeamColor: Color = .red

    var body: some View {
        ZStack {
            // Background photo with zoom
            Image("soccerPlayExample")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .scaleEffect(zoom)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()
                .ignoresSafeArea()
            
            HStack {
                VStack(alignment: .leading, spacing: 0) {
                    configButton
                    Spacer()
                    zoomControl
                }
                .padding(.top, 8)
                .padding(.bottom, 8)
                .padding(.leading, 16)

                Spacer()
            }
        }
        .overlay(alignment: .top) {
            scoreView
                .padding(.top, 8)
        }
        .overlay(alignment: .topTrailing) {
            eyeButton
                .padding(.top, 8)
                .padding(.trailing, 16)
        }
        .tint(.primary)
    }
}

// MARK: - Subviews
private extension CameraButtonsView {

    var configButton: some View {
        Button {
            print("Config tapped")
        } label: {
            Image(systemName: "gearshape")
                .font(.system(size: 20, weight: .semibold))
                .frame(width: 44, height: 44)
                .background(.ultraThinMaterial, in: Circle())
        }
        .accessibilityLabel("Open settings")
        .accessibilityHint("Opens configuration options")
        .accessibilityAddTraits(.isButton)
    }

    var eyeButton: some View {
        Button {
            print("Eye tapped")
        } label: {
            Image(systemName: "eye")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(.black)
                .frame(width: 44, height: 44)
                .background(Color.white.opacity(0.7), in: Circle())
        }
        .accessibilityLabel("Toggle visibility")
        .accessibilityHint("Shows or hides elements")
        .accessibilityAddTraits(.isButton)
    }

    var scoreView: some View {
        let nameWidth: CGFloat = 56

        let leftShape = Rectangle()
            .fill(leftTeamColor)
            .frame(width: 16, height: 16)
            .overlay(
                Rectangle()
                    .strokeBorder(.black.opacity(0.35), lineWidth: 1)
            )
            .accessibilityHidden(true)

        let rightShape = Circle()
            .fill(rightTeamColor)
            .frame(width: 16, height: 16)
            .overlay(
                Circle()
                    .strokeBorder(.black.opacity(0.35), lineWidth: 1)
            )
            .accessibilityHidden(true)

        let leftHalf = HStack(spacing: 6) {
            Text(leftTeamShortName)
                .fontWeight(.semibold)
                .lineLimit(1)
                .truncationMode(.tail)
                .frame(width: nameWidth, alignment: .leading)

            Text("\(leftScore)")
                .monospacedDigit()
                .fontWeight(.bold)

            Color.clear
                .frame(width: nameWidth)
        }

        let rightHalf = HStack(spacing: 6) {
            Color.clear
                .frame(width: nameWidth)

            Text("\(rightScore)")
                .monospacedDigit()
                .fontWeight(.bold)

            Text(rightTeamShortName)
                .fontWeight(.semibold)
                .lineLimit(1)
                .truncationMode(.tail)
                .frame(width: nameWidth, alignment: .trailing)
        }

        return HStack(spacing: 12) {
            leftShape

            HStack(spacing: 12) {
                leftHalf
                Text("—")
                    .accessibilityHidden(true)
                rightHalf
            }
            .fixedSize()

            rightShape
        }
        .font(.system(.title3, design: .rounded))
        .foregroundStyle(.black) 
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color.white.opacity(0.7), in: Capsule())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Score")
        .accessibilityValue("\(leftTeamShortName) \(leftScore), \(rightTeamShortName) \(rightScore)")
    }

    var zoomControl: some View {
        HStack(spacing: 8) {
            Slider(
                value: $zoom,
                in: minZoom...maxZoom,
                step: 0.1,
                onEditingChanged: { editing in
                    print("Zoom: \(zoom)")
                }
            )
            .controlSize(.regular)
            .frame(maxWidth: 200)
            .tint(.black)

            Text("\(zoom, specifier: "%.1f")×")
                .font(.caption.monospacedDigit())
                .fontWeight(.semibold)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.white.opacity(0.8), in: Capsule())
                .foregroundStyle(.black)
        }
        .padding(8)
        .background(Color.white.opacity(0.7), in: RoundedRectangle(cornerRadius: 15, style: .continuous))
        .accessibilityLabel("Zoom")
        .accessibilityValue("\(zoom, specifier: "%.1f") times")
    }
}

// MARK: - Helpers
private extension CameraButtonsView {
    func incrementZoom() {
        let next = (zoom + zoomStep)
        zoom = min(maxZoom, round(next * 10) / 10)
    }

    func decrementZoom() {
        let next = (zoom - zoomStep)
        zoom = max(minZoom, round(next * 10) / 10)
    }
}

#Preview {
    ZStack {
        // Background for testing
        Rectangle()
            .fill(.black.opacity(0.1))
            .ignoresSafeArea()
        
        CameraButtonsView()
    }
    .preferredColorScheme(.light)
}
