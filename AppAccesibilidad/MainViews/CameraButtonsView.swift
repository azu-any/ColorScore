import SwiftUI

/// Accessible camera overlay with zoom controls and score display
struct CameraButtonsView: View {
    // Zoom controls
    @State private var zoom: Double = 1.0
    @State private var showZoomSlider = false
    
    // Score tracking
    @State private var leftScore = 0
    @State private var rightScore = 0
    @State private var leftTeamName = "LFT"
    @State private var rightTeamName = "RGT"
    @State private var leftTeamColor: Color = .blue
    @State private var rightTeamColor: Color = .red

    var body: some View {
        ZStack {
            // Background with zoom
            Image("soccerPlayExample")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .scaleEffect(zoom)
                .clipped()
                .ignoresSafeArea()
            
            // Controls overlay
            VStack {
                // Top row
                HStack(alignment: .top, spacing: 16) {
                    configButton
                    scoreView
                    Spacer()
                }
                .padding(.leading, 16)
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
        }
    }
}

// MARK: - Components
private extension CameraButtonsView {
    var configButton: some View {
        Button("Config") {
            print("Config tapped")
        }
        .buttonStyle(CircularButtonStyle(icon: "gearshape"))
    }
    
    var scoreView: some View {
        HStack(spacing: 12) {
            teamShape(color: leftTeamColor, isCircle: false)
            
            HStack(spacing: 12) {
                teamInfo(name: leftTeamName, score: leftScore)
                Text("—").accessibilityHidden(true)
                teamInfo(name: rightTeamName, score: rightScore, alignment: .trailing)
            }
            
            teamShape(color: rightTeamColor, isCircle: true)
        }
        .font(.system(.title3, design: .rounded, weight: .semibold))
        .foregroundStyle(Color.black)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color.white.opacity(0.7), in: Capsule())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Score: \(leftTeamName) \(leftScore), \(rightTeamName) \(rightScore)")
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
            
            if showZoomSlider {
                zoomSlider
            }
        }
    }
    
    var zoomSlider: some View {
        Slider(value: $zoom, in: 1.0...5.0, step: 0.1) { _ in
            print("Zoom: \(zoom)")
        }
        .controlSize(.regular)
        .frame(maxWidth: 200)
        .tint(.white)
        .padding(.horizontal, 16)
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
    
    func teamInfo(name: String, score: Int, alignment: Alignment = .leading) -> some View {
        HStack(spacing: 6) {
            if alignment == .trailing { Spacer() }
            
            Text(name)
                .lineLimit(1)
                .frame(width: 56, alignment: alignment)
            
            Text("\(score)")
                .monospacedDigit()
                .fontWeight(.bold)
            
            if alignment == .leading { Spacer() }
        }
    }
}

// MARK: - Button Style
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

#Preview {
    CameraButtonsView()
        .preferredColorScheme(.light)
}
