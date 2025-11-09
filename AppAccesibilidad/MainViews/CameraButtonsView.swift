import SwiftUI

/// Accessible camera overlay with zoom controls and score display
struct CameraButtonsView: View {
//    var onCalibrate: () -> Void
    
    // Zoom controls
    @State private var zoom: Double = 1.0
    @State private var showZoomSlider = false
    
    // Dismiss environment
    @Environment(\.dismiss) private var dismiss
    
    // Score tracking
    @State private var leftScore = 0
    @State private var rightScore = 0
    @State private var leftTeamName = "LFT"
    @State private var rightTeamName = "RGT"
    @State private var leftTeamColor: Color = .blue
    @State private var rightTeamColor: Color = .red
    @State private var showScoreControls = false
    
    var body: some View {
        ZStack {

            CameraView()
                .ignoresSafeArea(edges: .all)
            
            // Controls overlay
            VStack {
                // Top row
                HStack {
                    // Config button on the left
                    backButton
                    Spacer()
//                    calibrateButton
                }
                .padding(.horizontal, 16)
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
        }
//        .onAppear {
//            DispatchQueue.main.async {
//                AppDelegate.orientationLock = .landscapeRight
//                print("cambiando a landscape")
//            }
//        }
//        .onDisappear {
//            DispatchQueue.main.async {
//                AppDelegate.orientationLock = .portrait
//            }
//        }
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
    
//    var calibrateButton: some View {
//        Button("Calibrate") {
//            onCalibrate()
//        }
//        .buttonStyle(CircularButtonStyle(icon: "target"))
//    }
    
    var scoreView: some View {
        VStack(spacing: 8) {
            // Main score display - always visible
            HStack(spacing: 8) {
                teamShape(color: leftTeamColor, isCircle: false)
                
                Text(leftTeamName)
                    .lineLimit(1)
                    .frame(width: 40, alignment: .leading)
                
                Text("\(leftScore)")
                    .monospacedDigit()
                    .fontWeight(.bold)
                
                Text("—").accessibilityHidden(true)
                
                Text("\(rightScore)")
                    .monospacedDigit()
                    .fontWeight(.bold)
                
                Text(rightTeamName)
                    .lineLimit(1)
                    .frame(width: 40, alignment: .trailing)
                    
                teamShape(color: rightTeamColor, isCircle: true)
            }
            .font(.system(.title3, design: .rounded, weight: .semibold))
            .foregroundStyle(Color.black)
            
            // Score controls - only show when toggled
            if showScoreControls {
                HStack(spacing: 32) {
                    // Left team controls
                    HStack(spacing: 8) {
                        Button("-") {
                            if leftScore > 0 {
                                leftScore -= 1
                            }
                        }
                        .buttonStyle(LargeScoreButtonStyle(teamColor: leftTeamColor))
                        .accessibilityLabel("Decrease \(leftTeamName) score")
                        
                        Button("+") {
                            leftScore += 1
                        }
                        .buttonStyle(LargeScoreButtonStyle(teamColor: leftTeamColor))
                        .accessibilityLabel("Increase \(leftTeamName) score")
                    }
                    
                    Spacer()
                    
                    // Right team controls
                    HStack(spacing: 8) {
                        Button("-") {
                            if rightScore > 0 {
                                rightScore -= 1
                            }
                        }
                        .buttonStyle(LargeScoreButtonStyle(teamColor: rightTeamColor))
                        .accessibilityLabel("Decrease \(rightTeamName) score")
                        
                        Button("+") {
                            rightScore += 1
                        }
                        .buttonStyle(LargeScoreButtonStyle(teamColor: rightTeamColor))
                        .accessibilityLabel("Increase \(rightTeamName) score")
                    }
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(maxWidth: showScoreControls ? 300 : 300)
        .glassEffect(.regular.interactive(), in: .rect(cornerRadius: showScoreControls ? 12 : 22))
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.3)) {
                showScoreControls.toggle()
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Score: \(leftTeamName) \(leftScore), \(rightTeamName) \(rightScore). Tap to \(showScoreControls ? "hide" : "show") score controls.")
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
        Slider(value: $zoom, in: 1.0...5.0, step: 0.1) { _ in
            print("Zoom: \(zoom)")
        }
        .controlSize(.regular)
        .frame(maxWidth: 220)
        .tint(.white)
        .padding(.horizontal, 12)
        .frame(height: 44)
        .glassEffect(.regular.interactive(), in: .capsule)
        .accessibilityLabel("Zoom: \(zoom, specifier: "%.1f")x")
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

// MARK: - Button Styles
struct CircularButtonStyle: ButtonStyle {
    let icon: String
    let usesGlass: Bool
    
    init(icon: String, usesGlass: Bool = false) {
        self.icon = icon
        self.usesGlass = usesGlass
    }
    
    func makeBody(configuration: Configuration) -> some View {
        Image(systemName: icon)
            .font(.system(size: 20, weight: .semibold))
            .foregroundStyle(Color.black)
            .frame(width: 44, height: 44)
            .background {
                if usesGlass {
                    Circle().glassEffect(.regular.interactive())
                } else {
                    Circle().fill(.ultraThinMaterial)
                }
            }
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
            .accessibilityAddTraits(.isButton)
    }
}

struct ScoreButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(.caption, weight: .bold))
            .foregroundStyle(Color.black)
            .frame(width: 24, height: 24)
            .background {
                Circle()
                    .fill(Color.white.opacity(0.8))
                    .overlay {
                        Circle()
                            .strokeBorder(Color.black.opacity(0.2), lineWidth: 0.5)
                    }
            }
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct LargeScoreButtonStyle: ButtonStyle {
    let teamColor: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(.title2, weight: .bold))
            .foregroundStyle(Color.white)
            .frame(width: 40, height: 40)
            .background {
                Circle()
                    .fill(teamColor)
                    .overlay {
                        Circle()
                            .strokeBorder(Color.white.opacity(0.3), lineWidth: 1)
                    }
                    .shadow(color: teamColor.opacity(0.3), radius: 2, x: 0, y: 1)
            }
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

#Preview {
//    CameraButtonsView(onCalibrate: {})
//        .preferredColorScheme(.light)
}
