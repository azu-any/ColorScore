import SwiftUI

/// Accessible camera overlay with zoom controls and score display
struct CameraButtonsView: View {
    // Zoom controls
    @State private var showZoomSlider = false
    
    // Dismiss environment
    @Environment(\.dismiss) private var dismiss
    
    // Score tracking
    @State private var leftScore = 0
    @State private var rightScore = 0
    @State private var showScoreControls = false
    
    // Configuration
    @State private var showConfiguration = false
    
    // Team and goalkeeper customization
    @Binding var teamSelectionManager: TeamSelectionManager
    @State var matchSettings = MatchSettings()
    @State var isCalibrating: Bool = false

    var body: some View {
        ZStack {
            CameraView(
                settings: matchSettings,
                onCancel: {
                    DispatchQueue.main.async {
                        AppDelegate.orientationLock = .portrait
                    }
                    dismiss()
                },
                isCalibrating: $isCalibrating
            )
                .edgesIgnoringSafeArea(.all)
            
            // Enhanced calibration button
            if !isCalibrating {
                Button {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                        isCalibrating = true
                    }
                } label: {
                    VStack(spacing: 16) {
                        // Icon with animated gradient background
                        ZStack {
                            Circle()
                                .fill(.white.opacity(0.15))
                                .frame(width: 80, height: 80)
                            
                            Image(systemName: "figure.run.circle.fill")
                                .font(.system(size: 44, weight: .medium))
                                .symbolRenderingMode(.hierarchical)
                                .foregroundStyle(.white)
                        }
                        
                        VStack(spacing: 8) {
                            Text("Empezar calibración")
                                .font(.system(.title2, design: .rounded, weight: .bold))
                            
                            Text("Apunta a los jugadores durante 10 segundos")
                                .font(.system(.subheadline, design: .rounded, weight: .medium))
                                .multilineTextAlignment(.center)
                                .opacity(0.9)
                        }
                    }
                    .padding(.vertical, 32)
                    .padding(.horizontal, 40)
                    .frame(maxWidth: 400)
                }
                .buttonStyle(.glassProminent)
                .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
                .transition(.scale(scale: 0.8).combined(with: .opacity))
            }
            
            // Controls overlay
            VStack {
                // Top row
                HStack(alignment: .top) {
                    // Config button on the left
                    backButton
                    Spacer()
                    // Configuration button on the right
                    VStack(alignment: .trailing, spacing: 8) {
                        Button("Configuration") {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                showConfiguration.toggle()
                            }
                        }
                        .buttonStyle(CircularButtonStyle(icon: showConfiguration ? "xmark" : "gearshape.fill", usesGlass: true))
                        
                        if showConfiguration { configurationPanel }
                    }
                    .frame(maxWidth: showConfiguration ? 440 : 44, alignment: .trailing)
                }
                .padding(.leading, 16)
                .padding(.trailing, 16)
                .padding(.top, 24)
                
                Spacer()
                
                // Bottom left zoom control
                HStack {
                    zoomControl
                    Spacer()
                }
                .padding(.leading, 16)
                .padding(.bottom, 24)
            }
            
            // Score view centered at top
            VStack {
                scoreView
                    .padding(.top, 24)
                Spacer()
            }
            .zIndex(1)
        }
    }
}

// MARK: - Components
private extension CameraButtonsView {
    var backButton: some View {
        Button("Back") {
            DispatchQueue.main.async {
                AppDelegate.orientationLock = .portrait
            }
            dismiss()
        }
        .buttonStyle(CircularButtonStyle(icon: "chevron.left"))
    }
    
    var configurationPanel: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                Text("Personalizar Jugadores")
                    .font(.system(.headline, design: .rounded, weight: .bold))
                    .foregroundStyle(.primary)
                Spacer()
            }
            .padding(.bottom, 4)
            
            ScrollView {
                VStack(spacing: 24) {
                    // Team 1
                    VStack(alignment: .leading, spacing: 12) {
                        Text(teamSelectionManager.team1?.name ?? "Equipo 1")
                            .font(.system(.subheadline, design: .rounded, weight: .semibold))
                            .foregroundStyle(.secondary)
                        
                        CompactShapeColorPicker(
                            title: "Jugadores",
                            selectedShape: $matchSettings.team1Shape,
                            selectedColor: $matchSettings.team1Color
                        )
                        
                        CompactShapeColorPicker(
                            title: "Portero",
                            selectedShape: $matchSettings.goalkeeper1Shape,
                            selectedColor: $matchSettings.goalkeeper1Color
                        )
                    }
                    
                    Divider()
                        .background(Color.primary.opacity(0.15))
                    
                    // Team 2
                    VStack(alignment: .leading, spacing: 12) {
                        Text(teamSelectionManager.team2?.name ?? "Equipo 2")
                            .font(.system(.subheadline, design: .rounded, weight: .semibold))
                            .foregroundStyle(.secondary)
                        
                        CompactShapeColorPicker(
                            title: "Jugadores",
                            selectedShape: $matchSettings.team2Shape,
                            selectedColor: $matchSettings.team2Color
                        )
                        
                        CompactShapeColorPicker(
                            title: "Portero",
                            selectedShape: $matchSettings.goalkeeper2Shape,
                            selectedColor: $matchSettings.goalkeeper2Color
                        )
                    }
                    
                    Divider()
                        .background(Color.primary.opacity(0.15))
                    
                    // Ball
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Balón")
                            .font(.system(.subheadline, design: .rounded, weight: .semibold))
                            .foregroundStyle(.secondary)
                        
                        CompactShapeColorPicker(
                            title: "Balón",
                            selectedShape: $matchSettings.ballShape,
                            selectedColor: $matchSettings.ballColor
                        )
                    }
                }
                .padding(.vertical, 4)
                .padding(.bottom, 20)
            }
            .frame(maxHeight: 500)
        }
        .padding(24)
        .frame(width: 440)
        .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 24))
        .shadow(color: Color.black.opacity(0.15), radius: 20, x: 0, y: 10)
        .transition(.scale(scale: 0, anchor: .topTrailing).combined(with: .opacity))
    }
    
    var scoreView: some View {
        VStack(spacing: 10) {
            // Main score display - always visible
            HStack(spacing: 0) {
                // Left team
                HStack(spacing: 8) {
                    matchSettings.team1Shape.view(color: matchSettings.team1Color.color, size: 16)
                    
                    Text(teamSelectionManager.team1?.name ?? "Equipo 1")
                        .lineLimit(1)
                        .fixedSize(horizontal: true, vertical: false)
                        .font(.system(.callout, design: .rounded, weight: .semibold))
                }
                .foregroundStyle(matchSettings.team1Color.color)
                
                Spacer()
                    .frame(width: 12)
                
                // Score display with emphasis
                HStack(spacing: 10) {
                    Text("\(leftScore)")
                        .monospacedDigit()
                        .font(.system(.title, design: .rounded, weight: .bold))
                        .foregroundStyle(matchSettings.team1Color.color)
                        .frame(minWidth: 28)
                    
                    Text(":")
                        .font(.system(.title2, design: .rounded, weight: .medium))
                        .foregroundStyle(Color.primary.opacity(0.5))
                    
                    Text("\(rightScore)")
                        .monospacedDigit()
                        .font(.system(.title, design: .rounded, weight: .bold))
                        .foregroundStyle(matchSettings.team2Color.color)
                        .frame(minWidth: 28)
                }
                
                Spacer()
                    .frame(width: 12)
                
                // Right team
                HStack(spacing: 8) {
                    Text(teamSelectionManager.team2?.name ?? "Equipo 2")
                        .lineLimit(1)
                        .fixedSize(horizontal: true, vertical: false)
                        .font(.system(.callout, design: .rounded, weight: .semibold))
                    
                    matchSettings.team2Shape.view(color: matchSettings.team2Color.color, size: 16)
                }
                .foregroundStyle(matchSettings.team2Color.color)
            }
            
            // Score controls - only show when toggled
            if showScoreControls {
                Divider()
                    .background(Color.primary.opacity(0.15))
                    .padding(.horizontal, -4)
                
                HStack(spacing: 0) {
                    // Left team controls
                    HStack(spacing: 10) {
                        Button {
                            if leftScore > 0 {
                                leftScore -= 1
                            }
                        } label: {
                            Image(systemName: "minus.circle.fill")
                                .font(.system(size: 26))
                        }
                        .buttonStyle(ScoreControlButtonStyle(teamColor: matchSettings.team1Color.color, enabled: leftScore > 0))
                        .disabled(leftScore == 0)
                        .accessibilityLabel("Decrease \(teamSelectionManager.team1?.name ?? "Equipo 1") score")
                        
                        Button {
                            leftScore += 1
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 26))
                        }
                        .buttonStyle(ScoreControlButtonStyle(teamColor: matchSettings.team1Color.color, enabled: true))
                        .accessibilityLabel("Increase \(teamSelectionManager.team1?.name ?? "Equipo 1") score")
                    }
                    
                    Spacer()
                    
                    // Right team controls
                    HStack(spacing: 10) {
                        Button {
                            if rightScore > 0 {
                                rightScore -= 1
                            }
                        } label: {
                            Image(systemName: "minus.circle.fill")
                                .font(.system(size: 26))
                        }
                        .buttonStyle(ScoreControlButtonStyle(teamColor: matchSettings.team2Color.color, enabled: rightScore > 0))
                        .disabled(rightScore == 0)
                        .accessibilityLabel("Decrease \(teamSelectionManager.team2?.name ?? "Equipo 2") score")
                        
                        Button {
                            rightScore += 1
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 26))
                        }
                        .buttonStyle(ScoreControlButtonStyle(teamColor: matchSettings.team2Color.color, enabled: true))
                        .accessibilityLabel("Increase \(teamSelectionManager.team2?.name ?? "Equipo 2") score")
                    }
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .fixedSize(horizontal: !showScoreControls, vertical: false)
        .frame(maxWidth: showScoreControls ? 380 : nil)
        .glassEffect(.regular.interactive(), in: .rect(cornerRadius: showScoreControls ? 20 : 28))
        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
        .onTapGesture {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                showScoreControls.toggle()
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Score: \(teamSelectionManager.team1?.name ?? "Equipo 1") \(leftScore), \(teamSelectionManager.team2?.name ?? "Equipo 2") \(rightScore). Tap to \(showScoreControls ? "hide" : "show") score controls.")
        .accessibilityAddTraits(.isButton)
    }
    
    var zoomControl: some View {
        HStack(spacing: 8) {
            Button("Zoom") {
                withAnimation(.easeInOut(duration: 0.3)) {
                    showZoomSlider.toggle()
                }
            }
            .buttonStyle(CircularButtonStyle(
                icon: showZoomSlider ? "minus.circle" : "plus.magnifyingglass",
                usesGlass: true
            ))
            
            if showZoomSlider { zoomSlider }
        }
    }
    
    var zoomSlider: some View {
        Slider(value: $matchSettings.zoom, in: 1.0...5.0, step: 0.1) { _ in
            print("Zoom: \(matchSettings.zoom)")
        }
        .controlSize(.regular)
        .frame(maxWidth: 220)
        .tint(.white)
        .padding(.horizontal, 12)
        .frame(height: 44)
        .glassEffect(.regular.interactive(), in: .capsule)
        .accessibilityLabel("Zoom: \(matchSettings.zoom, specifier: "%.1f")x")
        .transition(.scale(scale: 0, anchor: .leading).combined(with: .opacity))
    }
    
    func teamShape(color: Color, isCircle: Bool) -> some View {
        Group {
            if isCircle {
                Circle()
                    .fill(color)
                    .overlay {
                        Circle()
                            .strokeBorder(Color.black.opacity(0.35), lineWidth: 1)
                    }
            } else {
                Rectangle()
                    .fill(color)
                    .overlay {
                        Rectangle()
                            .strokeBorder(Color.black.opacity(0.35), lineWidth: 1)
                    }
            }
        }
        .frame(width: 16, height: 16)
        .accessibilityHidden(true)
    }
    
    func teamInfo(name: String, score: Int, alignment: Alignment = .leading, scoreFirst: Bool = false) -> some View {
        HStack(spacing: 4) {
            if alignment == .trailing { Spacer() }
            
            if scoreFirst {
                // For right team: score first, then name
                Text("\(score)")
                    .monospacedDigit()
                    .fontWeight(.bold)
                
                Text(name)
                    .lineLimit(1)
                    .frame(width: 40, alignment: alignment)
            } else {
                // For left team: name first, then score
                Text(name)
                    .lineLimit(1)
                    .frame(width: 40, alignment: alignment)
                
                Text("\(score)")
                    .monospacedDigit()
                    .fontWeight(.bold)
            }
            
            if alignment == .leading { Spacer() }
        }
    }
}


// MARK: - Previews

#Preview("Enhanced Calibration Button") {
    ZStack {
        // Simulate camera background with gradient
        LinearGradient(
            colors: [.gray.opacity(0.8), .gray],
            startPoint: .top,
            endPoint: .bottom
        )
        .edgesIgnoringSafeArea(.all)
        
        // The new enhanced calibration button
        Button {
            // Preview action
        } label: {
            VStack(spacing: 16) {
                // Icon with background circle
                ZStack {
                    Circle()
                        .fill(.white.opacity(0.15))
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: "figure.run.circle.fill")
                        .font(.system(size: 44, weight: .medium))
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(.white)
                }
                
                VStack(spacing: 8) {
                    Text("Empezar calibración")
                        .font(.system(.title2, design: .rounded, weight: .bold))
                    
                    Text("Apunta a los jugadores durante 10 segundos")
                        .font(.system(.subheadline, design: .rounded, weight: .medium))
                        .multilineTextAlignment(.center)
                        .opacity(0.9)
                }
            }
            .padding(.vertical, 32)
            .padding(.horizontal, 40)
            .frame(maxWidth: 400)
        }
        .buttonStyle(.glassProminent)
        .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
    }
}

#Preview("Button Style Comparison") {
    ZStack {
        LinearGradient(
            colors: [.gray.opacity(0.8), .gray],
            startPoint: .top,
            endPoint: .bottom
        )
        .edgesIgnoringSafeArea(.all)
        
        VStack(spacing: 40) {
            // New prominent style
            VStack(spacing: 8) {
                Button {
                } label: {
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(.white.opacity(0.15))
                                .frame(width: 80, height: 80)
                            
                            Image(systemName: "figure.run.circle.fill")
                                .font(.system(size: 44, weight: .medium))
                                .symbolRenderingMode(.hierarchical)
                                .foregroundStyle(.white)
                        }
                        
                        VStack(spacing: 8) {
                            Text("Empezar calibración")
                                .font(.system(.title2, design: .rounded, weight: .bold))
                            
                            Text("Apunta a los jugadores durante 10 segundos")
                                .font(.system(.subheadline, design: .rounded, weight: .medium))
                                .multilineTextAlignment(.center)
                                .opacity(0.9)
                        }
                    }
                    .padding(.vertical, 32)
                    .padding(.horizontal, 40)
                    .frame(maxWidth: 400)
                }
                .buttonStyle(.glassProminent)
                .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
                
                Text("Prominent Glass (Recommended)")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.7))
            }
            
            // Regular glass style
            VStack(spacing: 8) {
                Button {
                } label: {
                    VStack(spacing: 16) {
                        Image(systemName: "figure.run.circle.fill")
                            .font(.system(size: 40))
                            .symbolRenderingMode(.hierarchical)
                        
                        VStack(spacing: 6) {
                            Text("Empezar calibración")
                                .font(.system(.title3, design: .rounded, weight: .semibold))
                            
                            Text("Apunta a los jugadores")
                                .font(.system(.caption, design: .rounded))
                                .opacity(0.8)
                        }
                    }
                    .padding(.vertical, 24)
                    .padding(.horizontal, 32)
                }
                .buttonStyle(.glass)
                
                Text("Regular Glass")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.7))
            }
        }
    }
}

#Preview("Alternative Icon Styles") {
    ScrollView {
        VStack(spacing: 40) {
            // Style 1: Running figure (current)
            previewButton(
                icon: "figure.run.circle.fill",
                title: "Empezar calibración",
                subtitle: "Apunta a los jugadores durante 10 segundos",
                label: "Running Figure"
            )
            
            // Style 2: Camera scanning
            previewButton(
                icon: "camera.metering.matrix",
                title: "Empezar calibración",
                subtitle: "Apunta a los jugadores durante 10 segundos",
                label: "Camera Matrix"
            )
            
            // Style 3: Viewfinder
            previewButton(
                icon: "viewfinder.circle.fill",
                title: "Empezar calibración",
                subtitle: "Apunta a los jugadores durante 10 segundos",
                label: "Viewfinder"
            )
            
            // Style 4: Play circle
            previewButton(
                icon: "play.circle.fill",
                title: "Empezar calibración",
                subtitle: "Apunta a los jugadores durante 10 segundos",
                label: "Play Button"
            )
            
            // Style 5: Waveform
            previewButton(
                icon: "waveform.circle.fill",
                title: "Empezar calibración",
                subtitle: "Analizando movimiento",
                label: "Waveform (Analysis)"
            )
        }
        .padding(40)
    }
    .background(
        LinearGradient(
            colors: [.gray.opacity(0.8), .gray],
            startPoint: .top,
            endPoint: .bottom
        )
    )
}

// Helper function for preview
private func previewButton(icon: String, title: String, subtitle: String, label: String) -> some View {
    VStack(spacing: 12) {
        Button {
        } label: {
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(.white.opacity(0.15))
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: icon)
                        .font(.system(size: 44, weight: .medium))
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(.white)
                }
                
                VStack(spacing: 8) {
                    Text(title)
                        .font(.system(.title2, design: .rounded, weight: .bold))
                    
                    Text(subtitle)
                        .font(.system(.subheadline, design: .rounded, weight: .medium))
                        .multilineTextAlignment(.center)
                        .opacity(0.9)
                }
            }
            .padding(.vertical, 32)
            .padding(.horizontal, 40)
            .frame(maxWidth: 400)
        }
        .buttonStyle(.glassProminent)
        .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
        
        Text(label)
            .font(.caption)
            .foregroundStyle(.white.opacity(0.7))
    }
}

//#Preview {
//    CameraButtonsView(teamSelectionManager: teamSelectionManager)
//        .preferredColorScheme(.light)
//}
