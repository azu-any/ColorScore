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
    @State private var hasStartedCalibration: Bool = false

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
            if !isCalibrating && !hasStartedCalibration {
                VStack(spacing: 20) {
                    // Icon above button (not tappable)
                    ZStack {
                        Circle()
                            .fill(.white.opacity(0.1))
                            .frame(width: 80, height: 80)
                        
                        Image(systemName: "figure.run.circle.fill")
                            .font(.system(size: 44, weight: .medium))
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(.black)
                    }
                    .shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: 6)
                    
                    // Button with just text
                    Button {
                        // Haptic feedback
                        let impact = UIImpactFeedbackGenerator(style: .medium)
                        impact.impactOccurred()
                        
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                            isCalibrating = true
                            hasStartedCalibration = true
                        }
                    } label: {
                        VStack(spacing: 8) {
                            Text("Empezar calibración")
                                .font(.system(.title2, design: .rounded, weight: .bold))
                            
                            Text("Apunta a los jugadores durante 10 segundos. Haz click aquí cuando estés listo.")
                                .font(.system(.subheadline, design: .rounded, weight: .medium))
                                .multilineTextAlignment(.center)
                                .opacity(0.9)
                        }
                        .padding(.vertical, 20)
                        .padding(.horizontal, 32)
                        .frame(maxWidth: 400)
                    }
                    .buttonStyle(TranslucentGlassButtonStyle())
                    .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
                }
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
//                .foregroundStyle(matchSettings.team1Color.color)
                
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
//                .foregroundStyle(matchSettings.team2Color.color)
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


// MARK: - Custom Button Style

/// Translucent glass button style with press animation
struct TranslucentGlassButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .opacity(configuration.isPressed ? 0.7 : 0.9)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .stroke(.white.opacity(0.2), lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
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
        
        // The new enhanced calibration layout
        VStack(spacing: 20) {
            // Icon above button (not tappable)
            ZStack {
                Circle()
                    .fill(.white.opacity(0.1))
                    .frame(width: 80, height: 80)
                
                Image(systemName: "figure.run.circle.fill")
                    .font(.system(size: 44, weight: .medium))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(.white.opacity(0.95))
            }
            .shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: 6)
            
            // Button with just text
            Button {
                // Preview action
            } label: {
                VStack(spacing: 8) {
                    Text("Empezar calibración")
                        .font(.system(.title2, design: .rounded, weight: .bold))
                    
                    Text("Apunta a los jugadores durante 10 segundos. Haz click aquí cuando estés listo.")
                        .font(.system(.subheadline, design: .rounded, weight: .medium))
                        .multilineTextAlignment(.center)
                        .opacity(0.9)
                }
                .padding(.vertical, 20)
                .padding(.horizontal, 32)
                .frame(maxWidth: 400)
            }
            .buttonStyle(TranslucentGlassButtonStyle())
            .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
        }
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
        
        VStack(spacing: 50) {
            // New translucent style
            VStack(spacing: 8) {
                VStack(spacing: 20) {
                    ZStack {
                        Circle()
                            .fill(.black.opacity(0.1))
                            .frame(width: 80, height: 80)
                        
                        Image(systemName: "figure.run.circle.fill")
                            .font(.system(size: 44, weight: .medium))
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(.black.opacity(0.95))
                    }
                    .shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: 6)
                    
                    Button {
                    } label: {
                        VStack(spacing: 8) {
                            Text("Empezar calibración")
                                .font(.system(.title2, design: .rounded, weight: .bold))
                            
                            Text("Apunta a los jugadores durante 10 segundos. Haz click aquí cuando estés listo.")
                                .font(.system(.subheadline, design: .rounded, weight: .medium))
                                .multilineTextAlignment(.center)
                                .opacity(0.9)
                        }
                        .padding(.vertical, 20)
                        .padding(.horizontal, 32)
                        .frame(maxWidth: 400)
                    }
                    .buttonStyle(TranslucentGlassButtonStyle())
                    .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
                }
                
                Text("Translucent Glass (Recommended)")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.7))
            }
            
            // Glass prominent for comparison
            VStack(spacing: 8) {
                VStack(spacing: 20) {
                    ZStack {
                        Circle()
                            .fill(.white.opacity(0.15))
                            .frame(width: 80, height: 80)
                        
                        Image(systemName: "figure.run.circle.fill")
                            .font(.system(size: 44, weight: .medium))
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(.white)
                    }
                    .shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: 6)
                    
                    Button {
                    } label: {
                        VStack(spacing: 8) {
                            Text("Empezar calibración")
                                .font(.system(.title2, design: .rounded, weight: .bold))
                            
                            Text("Apunta a los jugadores")
                                .font(.system(.subheadline, design: .rounded, weight: .medium))
                                .multilineTextAlignment(.center)
                                .opacity(0.9)
                        }
                        .padding(.vertical, 20)
                        .padding(.horizontal, 32)
                        .frame(maxWidth: 400)
                    }
                    .buttonStyle(.glassProminent)
                    .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
                }
                
                Text("Glass Prominent")
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
            previewButtonSeparated(
                icon: "figure.run.circle.fill",
                title: "Empezar calibración",
                subtitle: "Apunta a los jugadores durante 10 segundos. Haz click aquí cuando estés listo.",
                label: "Running Figure (Current)"
            )
            
            // Style 2: Camera scanning
            previewButtonSeparated(
                icon: "camera.metering.matrix",
                title: "Empezar calibración",
                subtitle: "Apunta a los jugadores durante 10 segundos. Haz click aquí cuando estés listo.",
                label: "Camera Matrix"
            )
            
            // Style 3: Viewfinder
            previewButtonSeparated(
                icon: "viewfinder.circle.fill",
                title: "Empezar calibración",
                subtitle: "Apunta a los jugadores durante 10 segundos. Haz click aquí cuando estés listo.",
                label: "Viewfinder"
            )
            
            // Style 4: Play circle
            previewButtonSeparated(
                icon: "play.circle.fill",
                title: "Empezar calibración",
                subtitle: "Apunta a los jugadores durante 10 segundos. Haz click aquí cuando estés listo.",
                label: "Play Button"
            )
            
            // Style 5: Waveform
            previewButtonSeparated(
                icon: "waveform.circle.fill",
                title: "Empezar calibración",
                subtitle: "Analizando movimiento en tiempo real",
                label: "Waveform (Analysis)"
            )
            
            // Style 6: Sparkles (AI/Processing)
            previewButtonSeparated(
                icon: "sparkles",
                title: "Empezar calibración",
                subtitle: "Detección inteligente de jugadores",
                label: "Sparkles (AI)"
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

// Helper function for separated preview
private func previewButtonSeparated(icon: String, title: String, subtitle: String, label: String) -> some View {
    VStack(spacing: 12) {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(.white.opacity(0.1))
                    .frame(width: 80, height: 80)
                
                Image(systemName: icon)
                    .font(.system(size: 44, weight: .medium))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(.white.opacity(0.95))
            }
            .shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: 6)
            
            Button {
            } label: {
                VStack(spacing: 8) {
                    Text(title)
                        .font(.system(.title2, design: .rounded, weight: .bold))
                    
                    Text(subtitle)
                        .font(.system(.subheadline, design: .rounded, weight: .medium))
                        .multilineTextAlignment(.center)
                        .opacity(0.9)
                }
                .padding(.vertical, 20)
                .padding(.horizontal, 32)
                .frame(maxWidth: 400)
            }
            .buttonStyle(TranslucentGlassButtonStyle())
            .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
        }
        
        Text(label)
            .font(.caption)
            .foregroundStyle(.white.opacity(0.7))
    }
}

//#Preview {
//    CameraButtonsView(teamSelectionManager: teamSelectionManager)
//        .preferredColorScheme(.light)
//}
