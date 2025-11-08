import SwiftUI

/// Accessible camera overlay with zoom controls and score display
struct CameraButtonsView: View {
    // Zoom controls
    @State private var zoom: Double = 1.0
    @State private var showZoomSlider = false
    
    // Dismiss environment
    @Environment(\.dismiss) private var dismiss
    
    // Score tracking
    @State private var leftScore = 0
    @State private var rightScore = 0
    @State private var leftTeamName = "México"
    @State private var rightTeamName = "Francia"
    @State private var leftTeamColor: Color = .blue
    @State private var rightTeamColor: Color = .red
    @State private var showScoreControls = false
    
    // Configuration
    @State private var showConfiguration = false
    
    // Team and goalkeeper customization
    @State private var team1Shape: PlayerShape = .circle
    @State private var team1Color: PlayerColor = .blue
    @State private var goalkeeper1Shape: PlayerShape = .square
    @State private var goalkeeper1Color: PlayerColor = .blue
    @State private var team2Shape: PlayerShape = .circle
    @State private var team2Color: PlayerColor = .red
    @State private var goalkeeper2Shape: PlayerShape = .square
    @State private var goalkeeper2Color: PlayerColor = .red

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
                HStack {
                    // Config button on the left
                    backButton
                    Spacer()
                    // Configuration button on the right
                    configButton
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
        }
        .sheet(isPresented: $showConfiguration) {
            configurationSheet
        }
    }
}

// MARK: - Components
private extension CameraButtonsView {
    var backButton: some View {
        Button("Back") {
            dismiss()
        }
        .buttonStyle(CircularButtonStyle(icon: "chevron.left"))
    }
    
    var configButton: some View {
        Button("Configuration") {
            showConfiguration = true
        }
        .buttonStyle(CircularButtonStyle(icon: "gearshape.fill", usesGlass: true))
    }
    
    var configurationSheet: some View {
        NavigationStack {
            Form {
                Section("Team 1") {
                    ShapeColorPicker(
                        title: "Players",
                        selectedShape: $team1Shape,
                        selectedColor: $team1Color
                    )
                    
                    ShapeColorPicker(
                        title: "Goalkeeper",
                        selectedShape: $goalkeeper1Shape,
                        selectedColor: $goalkeeper1Color
                    )
                }
                
                Section("Team 2") {
                    ShapeColorPicker(
                        title: "Players",
                        selectedShape: $team2Shape,
                        selectedColor: $team2Color
                    )
                    
                    ShapeColorPicker(
                        title: "Goalkeeper",
                        selectedShape: $goalkeeper2Shape,
                        selectedColor: $goalkeeper2Color
                    )
                }
            }
            .navigationTitle("Customize Players")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        showConfiguration = false
                    }
                }
            }
        }
    }
    
    var scoreView: some View {
        VStack(spacing: 10) {
            // Main score display - always visible
            HStack(spacing: 0) {
                // Left team
                HStack(spacing: 8) {
                    teamShape(color: leftTeamColor, isCircle: false)
                    
                    Text(leftTeamName)
                        .lineLimit(1)
                        .fixedSize(horizontal: true, vertical: false)
                        .font(.system(.callout, design: .rounded, weight: .semibold))
                }
                .foregroundStyle(leftTeamColor)
                
                Spacer()
                    .frame(width: 12)
                
                // Score display with emphasis
                HStack(spacing: 10) {
                    Text("\(leftScore)")
                        .monospacedDigit()
                        .font(.system(.title, design: .rounded, weight: .bold))
                        .foregroundStyle(leftTeamColor)
                        .frame(minWidth: 28)
                    
                    Text(":")
                        .font(.system(.title2, design: .rounded, weight: .medium))
                        .foregroundStyle(Color.primary.opacity(0.5))
                    
                    Text("\(rightScore)")
                        .monospacedDigit()
                        .font(.system(.title, design: .rounded, weight: .bold))
                        .foregroundStyle(rightTeamColor)
                        .frame(minWidth: 28)
                }
                
                Spacer()
                    .frame(width: 12)
                
                // Right team
                HStack(spacing: 8) {
                    Text(rightTeamName)
                        .lineLimit(1)
                        .fixedSize(horizontal: true, vertical: false)
                        .font(.system(.callout, design: .rounded, weight: .semibold))
                    
                    teamShape(color: rightTeamColor, isCircle: true)
                }
                .foregroundStyle(rightTeamColor)
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
                        .buttonStyle(ScoreControlButtonStyle(teamColor: leftTeamColor, enabled: leftScore > 0))
                        .disabled(leftScore == 0)
                        .accessibilityLabel("Decrease \(leftTeamName) score")
                        
                        Button {
                            leftScore += 1
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 26))
                        }
                        .buttonStyle(ScoreControlButtonStyle(teamColor: leftTeamColor, enabled: true))
                        .accessibilityLabel("Increase \(leftTeamName) score")
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
                        .buttonStyle(ScoreControlButtonStyle(teamColor: rightTeamColor, enabled: rightScore > 0))
                        .disabled(rightScore == 0)
                        .accessibilityLabel("Decrease \(rightTeamName) score")
                        
                        Button {
                            rightScore += 1
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 26))
                        }
                        .buttonStyle(ScoreControlButtonStyle(teamColor: rightTeamColor, enabled: true))
                        .accessibilityLabel("Increase \(rightTeamName) score")
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

struct ScoreControlButtonStyle: ButtonStyle {
    let teamColor: Color
    let enabled: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(enabled ? teamColor : teamColor.opacity(0.3))
            .scaleEffect(configuration.isPressed ? 0.85 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - Player Customization Types
enum PlayerShape: String, CaseIterable, Identifiable {
    case circle = "Circle"
    case square = "Square"
    case triangle = "Triangle"
    case diamond = "Diamond"
    case hexagon = "Hexagon"
    case star = "Star"
    
    var id: String { rawValue }
    
    @ViewBuilder
    func view(color: Color, size: CGFloat = 24) -> some View {
        switch self {
        case .circle:
            Circle()
                .fill(color)
                .frame(width: size, height: size)
        case .square:
            Rectangle()
                .fill(color)
                .frame(width: size, height: size)
        case .triangle:
            Triangle()
                .fill(color)
                .frame(width: size, height: size)
        case .diamond:
            Diamond()
                .fill(color)
                .frame(width: size, height: size)
        case .hexagon:
            Hexagon()
                .fill(color)
                .frame(width: size, height: size)
        case .star:
            Star()
                .fill(color)
                .frame(width: size, height: size)
        }
    }
}

enum PlayerColor: String, CaseIterable, Identifiable {
    case blue = "Blue"
    case red = "Red"
    case green = "Green"
    case orange = "Orange"
    case purple = "Purple"
    case yellow = "Yellow"
    case cyan = "Cyan"
    case pink = "Pink"
    
    var id: String { rawValue }
    
    var color: Color {
        switch self {
        case .blue: return Color(red: 0.0, green: 0.48, blue: 0.8)      // Colorblind-friendly blue
        case .red: return Color(red: 0.9, green: 0.27, blue: 0.23)      // Colorblind-friendly red
        case .green: return Color(red: 0.0, green: 0.62, blue: 0.45)    // Colorblind-friendly green
        case .orange: return Color(red: 0.9, green: 0.6, blue: 0.0)     // High contrast orange
        case .purple: return Color(red: 0.58, green: 0.4, blue: 0.74)   // Distinct purple
        case .yellow: return Color(red: 0.95, green: 0.9, blue: 0.25)   // High visibility yellow
        case .cyan: return Color(red: 0.2, green: 0.73, blue: 0.87)     // Light cyan
        case .pink: return Color(red: 0.96, green: 0.51, blue: 0.69)    // Distinct pink
        }
    }
}

// MARK: - Custom Shapes
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

struct Diamond: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.midY))
        path.closeSubpath()
        return path
    }
}

struct Hexagon: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        
        path.move(to: CGPoint(x: width * 0.5, y: 0))
        path.addLine(to: CGPoint(x: width, y: height * 0.25))
        path.addLine(to: CGPoint(x: width, y: height * 0.75))
        path.addLine(to: CGPoint(x: width * 0.5, y: height))
        path.addLine(to: CGPoint(x: 0, y: height * 0.75))
        path.addLine(to: CGPoint(x: 0, y: height * 0.25))
        path.closeSubpath()
        
        return path
    }
}

struct Star: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let outerRadius = min(rect.width, rect.height) / 2
        let innerRadius = outerRadius * 0.4
        let points = 5
        
        for i in 0..<points * 2 {
            let angle = (Double(i) * .pi / Double(points)) - .pi / 2
            let radius = i.isMultiple(of: 2) ? outerRadius : innerRadius
            let x = center.x + CGFloat(cos(angle)) * radius
            let y = center.y + CGFloat(sin(angle)) * radius
            
            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        path.closeSubpath()
        
        return path
    }
}

// MARK: - Shape Color Picker Component
struct ShapeColorPicker: View {
    let title: String
    @Binding var selectedShape: PlayerShape
    @Binding var selectedColor: PlayerColor
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
            
            // Shape picker
            VStack(alignment: .leading, spacing: 8) {
                Text("Shape")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(PlayerShape.allCases) { shape in
                            Button {
                                selectedShape = shape
                            } label: {
                                VStack(spacing: 6) {
                                    shape.view(color: selectedColor.color, size: 32)
                                        .frame(width: 60, height: 60)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(selectedShape == shape ? Color.accentColor.opacity(0.15) : Color.secondary.opacity(0.1))
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .strokeBorder(selectedShape == shape ? Color.accentColor : Color.clear, lineWidth: 2)
                                        )
                                    
                                    Text(shape.rawValue)
                                        .font(.caption2)
                                        .foregroundStyle(selectedShape == shape ? .primary : .secondary)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            
            // Color picker
            VStack(alignment: .leading, spacing: 8) {
                Text("Color")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 44))], spacing: 12) {
                    ForEach(PlayerColor.allCases) { colorOption in
                        Button {
                            selectedColor = colorOption
                        } label: {
                            Circle()
                                .fill(colorOption.color)
                                .frame(width: 44, height: 44)
                                .overlay(
                                    Circle()
                                        .strokeBorder(selectedColor == colorOption ? Color.primary : Color.clear, lineWidth: 3)
                                )
                                .overlay(
                                    Circle()
                                        .strokeBorder(Color.white, lineWidth: 1)
                                )
                                .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(colorOption.rawValue)
                    }
                }
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    CameraButtonsView()
        .preferredColorScheme(.light)
}
