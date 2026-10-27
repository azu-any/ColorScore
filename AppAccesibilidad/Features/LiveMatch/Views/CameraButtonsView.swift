import SwiftUI

/// Accessible camera overlay with zoom controls, Magnifier-style daltonism filters, and score display
struct CameraButtonsView: View {
    // Zoom & Filter controls
    @State private var showZoomSlider = false
    @State private var showFilterStrip = false
    
    // Dismiss environment
    @Environment(\.dismiss) private var dismiss
    
    // Score tracking (independent toggle per team)
    @State private var leftScore = 0
    @State private var rightScore = 0
    @State private var activeTeamScoreControl: Int? = nil // nil = closed, 1 = left team, 2 = right team
    
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
            .accessibilityHidden(true)
            
            // Enhanced calibration card & glass action button
            if !isCalibrating && !hasStartedCalibration {
                VStack(spacing: 16) {
                    // Colored instructional banner card with camera viewfinder icon
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(.white.opacity(0.2))
                                .frame(width: 68, height: 68)
                            
                            Image(systemName: "camera.viewfinder")
                                .font(.system(size: 34, weight: .semibold))
                                .symbolRenderingMode(.hierarchical)
                                .foregroundStyle(.white)
                        }
                        .accessibilityHidden(true)
                        .padding(.top, -6)
                        
                        VStack(spacing: 6) {
                            Text("Calibración de cámara")
                                .font(.system(.title3, design: .rounded, weight: .bold))
                                .foregroundStyle(.white)
                            
                            Text("Apunta la cámara hacia los jugadores en la cancha durante 10 segundos. El modelo se entrenará prar detectar automáticamente a cada equipo")
                                .font(.system(.subheadline, design: .rounded, weight: .medium))
                                .foregroundStyle(.white.opacity(0.92))
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 28)
                    .frame(maxWidth: 500)
                    .background(
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color("CalibrationBannerStart").opacity(0.92),
                                        Color("CalibrationBannerEnd").opacity(0.95)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .strokeBorder(.white.opacity(0.3), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.25), radius: 16, x: 0, y: 8)
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Calibración de cámara. Apunta la cámara hacia los jugadores en la cancha durante 10 segundos para detectar automáticamente a cada equipo.")
                    
                    // Interactive Liquid Glass CTA button
                    Button {
                        let impact = UIImpactFeedbackGenerator(style: .medium)
                        impact.impactOccurred()
                        
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                            isCalibrating = true
                            hasStartedCalibration = true
                        }
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "camera.metering.center.weighted")
                                .font(.system(.headline, weight: .bold))
                            
                            Text("Empezar calibración")
                                .font(.system(.headline, design: .rounded, weight: .bold))
                        }
                        .foregroundStyle(.primary)
                        .padding(.vertical, 18)
                        .padding(.horizontal, 32)
                        .frame(maxWidth:500, minHeight: 54)
                        .contentShape(Capsule())
                    }
                    .buttonStyle(.plain)
                    .glassEffect(.regular.interactive(), in: .capsule)
                    .shadow(color: .black.opacity(0.2), radius: 16, x: 0, y: 8)
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Empezar calibración")
                    .accessibilityHint("Toca dos veces para iniciar el conteo de 10 segundos")
                    .accessibilityAddTraits(.isButton)
                }
                .padding(.top, 36)
                .transition(.scale(scale: 0.9).combined(with: .opacity))
            }
            
            // Controls overlay
            VStack {
                // Top row
                HStack(alignment: .top) {
                    // Back button on the left
                    backButton
                    Spacer()
                    // Configuration button on the right
                    VStack(alignment: .trailing, spacing: 8) {
                        Button {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                showConfiguration.toggle()
                            }
                        } label: {
                            Text(showConfiguration ? "Cerrar personalización" : "Personalizar jugadores")
                        }
                        .buttonStyle(CircularButtonStyle(icon: showConfiguration ? "xmark" : "gearshape.fill", usesGlass: true))
                        .accessibilityLabel(showConfiguration ? "Cerrar personalización" : "Personalizar jugadores")
                        .accessibilityHint("Configura los filtros de cámara, figuras y colores de los equipos, porteros y el balón")
                        
                    }
                    .frame(maxWidth: showConfiguration ? 440 : 44, alignment: .trailing)
                }
                .padding(.leading, 20)
                .padding(.trailing, 20)
                .padding(.top, 20)
                
                Spacer()
                
                // Bottom row: Zoom control on left, Magnifier-style Filter control on right
                HStack(alignment: .bottom, spacing: 12) {
                    zoomControl
                    Spacer(minLength: 8)
                    filterControl
                }
                .padding(.leading, 20)
                .padding(.trailing, 20)
                .padding(.bottom, 20)
            }
            
            // Score view centered at top
            VStack {
                scoreView
                    .padding(.top, 20)
                Spacer()
            }
            .zIndex(1)
            
            if showConfiguration {
                configurationPanel
                    .zIndex(4)
            }
        }
        .edgesIgnoringSafeArea(.all)

    }
}

// MARK: - Components
private extension CameraButtonsView {
    var team1DisplayName: String {
        teamSelectionManager.team1?.name ?? "Equipo 1"
    }
    
    var team2DisplayName: String {
        teamSelectionManager.team2?.name ?? "Equipo 2"
    }
    
    var backButton: some View {
        Button {
            DispatchQueue.main.async {
                AppDelegate.orientationLock = .portrait
            }
            dismiss()
        } label: {
            Text("Regresar")
        }
        .buttonStyle(CircularButtonStyle(icon: "chevron.left"))
        .accessibilityLabel("Salir de la cámara")
        .accessibilityHint("Regresa a la pantalla de inicio del partido")
    }
    
    var configurationPanel: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                Text("Personalizar Vista y Jugadores")
                    .font(.system(.headline, design: .rounded, weight: .bold))
                    .foregroundStyle(.primary)
                    .accessibilityAddTraits(.isHeader)
                Spacer()
            }
            .padding(.bottom, 4)
            
            ScrollView {
                VStack(spacing: 24) {
                    // Camera Filter (Magnifier / Daltonism)
//                    VStack(alignment: .leading, spacing: 12) {
//                        Text("Filtros de Cámara (Daltonismo y Lupa)")
//                            .font(.system(.subheadline, design: .rounded, weight: .semibold))
//                            .foregroundStyle(.secondary)
//                            .accessibilityAddTraits(.isHeader)
//                        
//                        CompactCameraFilterPicker(selectedFilter: $matchSettings.cameraFilter)
//                    }
//                    
//                    Divider()
//                        .background(Color.primary.opacity(0.15))
//                    
                    // Team 1
                    VStack(alignment: .leading, spacing: 12) {
                        Text(team1DisplayName)
                            .font(.system(.subheadline, design: .rounded, weight: .semibold))
                            .foregroundStyle(.secondary)
                            .accessibilityAddTraits(.isHeader)
                        
                        CompactShapeColorPicker(
                            title: "Jugadores de \(team1DisplayName)",
                            selectedShape: $matchSettings.team1Shape,
                            selectedColor: $matchSettings.team1Color
                        )
                        
                        CompactShapeColorPicker(
                            title: "Portero de \(team1DisplayName)",
                            selectedShape: $matchSettings.goalkeeper1Shape,
                            selectedColor: $matchSettings.goalkeeper1Color
                        )
                    }
                    
                    Divider()
                        .background(Color.primary.opacity(0.15))
                    
                    // Team 2
                    VStack(alignment: .leading, spacing: 12) {
                        Text(team2DisplayName)
                            .font(.system(.subheadline, design: .rounded, weight: .semibold))
                            .foregroundStyle(.secondary)
                            .accessibilityAddTraits(.isHeader)
                        
                        CompactShapeColorPicker(
                            title: "Jugadores de \(team2DisplayName)",
                            selectedShape: $matchSettings.team2Shape,
                            selectedColor: $matchSettings.team2Color
                        )
                        
                        CompactShapeColorPicker(
                            title: "Portero de \(team2DisplayName)",
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
                            .accessibilityAddTraits(.isHeader)
                        
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
            .frame(maxHeight: 400)
        }
        .padding(24)
        .frame(width: 550)
        .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 24))
        .shadow(color: Color.black.opacity(0.15), radius: 20, x: 0, y: 10)
        .transition(.scale(scale: 0, anchor: .topTrailing).combined(with: .opacity))
        .accessibilityElement(children: .contain)
        .zIndex(2.0)
    }
    
    // MARK: - Broadcast Soccer Scoreboard
    var scoreView: some View {
        HStack(spacing: 10) {
            // MARK: Left Team Wing (Badge + Color Bar + Name)
            Button {
                toggleTeamScoreControl(for: 1)
            } label: {
                HStack(spacing: 8) {
                    teamBadgeView(
                        team: teamSelectionManager.team1,
                        fallbackShape: matchSettings.team1Shape,
                        fallbackColor: matchSettings.team1Color.color
                    )

                    
                    Text(team1DisplayName)
                        .lineLimit(1)
                        .font(.system(.subheadline, design: .rounded, weight: .bold))
                        .foregroundStyle(.primary)
                }
                .padding(.leading, 8)
                .padding(.trailing, 4)
                .frame(minHeight: 44)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("\(team1DisplayName), \(leftScore) goles")
            .accessibilityHint(activeTeamScoreControl == 1 ? "Toca dos veces para ocultar los botones de goles de \(team1DisplayName)" : "Toca dos veces para ajustar los goles de \(team1DisplayName)")
            .accessibilityAddTraits(.isButton)
            
            // MARK: Center Broadcast Score Box with Inline Team Controls Around Number
            HStack(spacing: 6) {
                // Left Team Score & Inline Controls Around the Number
                HStack(spacing: 4) {
                    if activeTeamScoreControl == 1 {
                        Button {
                            if leftScore > 0 {
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                leftScore -= 1
                            }
                        } label: {
                            Image(systemName: "minus")
                                .font(.system(size: 24, weight: .bold))
                        }
                        .buttonStyle(ScoreControlButtonStyle(teamColor: matchSettings.team1Color.color, enabled: leftScore > 0))
                        .disabled(leftScore == 0)
                        .accessibilityLabel("Disminuir goles de \(team1DisplayName)")
                        .accessibilityValue("\(leftScore) goles")
                        .transition(.scale.combined(with: .opacity))
                    }
                    
                    Button {
                        toggleTeamScoreControl(for: 1)
                    } label: {
                        Text("\(leftScore)")
                            .monospacedDigit()
                            .font(.system(.title3, design: .rounded, weight: .heavy))
                            .foregroundStyle(.white)
                            .frame(minWidth: 34, minHeight: 36)
                            .padding(.horizontal, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(Color.black.opacity(0.65))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .strokeBorder(
                                        activeTeamScoreControl == 1
                                            ? Color.white.opacity(0.8)
                                            : matchSettings.team1Color.color.opacity(0.7),
                                        lineWidth: 1.5
                                    )
                            )
                    }
                    .buttonStyle(.plain)
                    .frame(minWidth: 40, minHeight: 44)
                    .contentShape(Rectangle())
                    .accessibilityLabel("Marcador de \(team1DisplayName): \(leftScore)")
                    .accessibilityHint(activeTeamScoreControl == 1 ? "Toca dos veces para cerrar controles" : "Toca dos veces para mostrar botones más y menos alrededor del marcador")
                    
                    if activeTeamScoreControl == 1 {
                        Button {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            leftScore += 1
                        } label: {
                            Image(systemName: "plus")
                                .font(.system(size: 24, weight: .bold))
                        }
                        .buttonStyle(ScoreControlButtonStyle(teamColor: matchSettings.team1Color.color, enabled: true))
                        .accessibilityLabel("Aumentar goles de \(team1DisplayName)")
                        .accessibilityValue("\(leftScore) goles")
                        .transition(.scale.combined(with: .opacity))
                    }
                }
                .background(
                    activeTeamScoreControl == 1 ? RoundedRectangle(cornerRadius: 10) : nil
                )
                
                // Center Soccer Divider
                Image(systemName: "soccerball")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 2)
                    .accessibilityHidden(true)
                
                // Right Team Score & Inline Controls Around the Number
                HStack(spacing: 4) {
                    if activeTeamScoreControl == 2 {
                        Button {
                            if rightScore > 0 {
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                rightScore -= 1
                            }
                        } label: {
                            Image(systemName: "minus")
                                .font(.system(size: 24, weight: .bold))
                        }
                        .buttonStyle(ScoreControlButtonStyle(teamColor: matchSettings.team2Color.color, enabled: rightScore > 0))
                        .disabled(rightScore == 0)
                        .accessibilityLabel("Disminuir goles de \(team2DisplayName)")
                        .accessibilityValue("\(rightScore) goles")
                        .transition(.scale.combined(with: .opacity))
                    }
                    
                    Button {
                        toggleTeamScoreControl(for: 2)
                    } label: {
                        Text("\(rightScore)")
                            .monospacedDigit()
                            .font(.system(.title3, design: .rounded, weight: .heavy))
                            .foregroundStyle(.white)
                            .frame(minWidth: 34, minHeight: 36)
                            .padding(.horizontal, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(Color.black.opacity(0.65))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .strokeBorder(
                                        activeTeamScoreControl == 2
                                            ? Color.white.opacity(0.8)
                                            : matchSettings.team2Color.color.opacity(0.7),
                                        lineWidth: 1.5
                                    )
                            )
                    }
                    .buttonStyle(.plain)
                    .frame(minWidth: 40, minHeight: 44)
                    .contentShape(Rectangle())
                    .accessibilityLabel("Marcador de \(team2DisplayName): \(rightScore)")
                    .accessibilityHint(activeTeamScoreControl == 2 ? "Toca dos veces para cerrar controles" : "Toca dos veces para mostrar botones más y menos alrededor del marcador")
                    
                    if activeTeamScoreControl == 2 {
                        Button {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            rightScore += 1
                        } label: {
                            Image(systemName: "plus")
                                .font(.system(size: 24, weight: .bold))
                        }
                        .buttonStyle(ScoreControlButtonStyle(teamColor: matchSettings.team2Color.color, enabled: true))
                        .accessibilityLabel("Aumentar goles de \(team2DisplayName)")
                        .accessibilityValue("\(rightScore) goles")
                        .transition(.scale.combined(with: .opacity))
                    }
                }
                .background(
                    activeTeamScoreControl == 2 ? RoundedRectangle(cornerRadius: 10) : nil
                )
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 4)
            
            
            // MARK: Right Team Wing (Name + Badge)
            Button {
                toggleTeamScoreControl(for: 2)
            } label: {
                HStack(spacing: 8) {
                    Text(team2DisplayName)
                        .lineLimit(1)
                        .font(.system(.subheadline, design: .rounded, weight: .bold))
                        .foregroundStyle(.primary)
                    
                    teamBadgeView(
                        team: teamSelectionManager.team2,
                        fallbackShape: matchSettings.team2Shape,
                        fallbackColor: matchSettings.team2Color.color
                    )
                }
                .padding(.leading, 4)
                .padding(.trailing, 8)
                .frame(minHeight: 44)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("\(team2DisplayName), \(rightScore) goles")
            .accessibilityHint(activeTeamScoreControl == 2 ? "Toca dos veces para ocultar los botones de goles de \(team2DisplayName)" : "Toca dos veces para ajustar los goles de \(team2DisplayName)")
            .accessibilityAddTraits(.isButton)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .glassEffect(.regular.interactive(), in: .capsule)
        .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 4)
        .accessibilityElement(children: .contain)
    }
    
    private func toggleTeamScoreControl(for team: Int) {
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
            if activeTeamScoreControl == team {
                activeTeamScoreControl = nil
            } else {
                activeTeamScoreControl = team
            }
        }
    }
    
    @ViewBuilder
    private func teamBadgeView(team: SelectedTeamData?, fallbackShape: PlayerShape, fallbackColor: Color) -> some View {
        if let imageData = team?.imageData, let uiImage = UIImage(data: imageData) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
                .clipShape(Circle())
                .accessibilityHidden(true)
        } else if let imageName = team?.imageName, !imageName.isEmpty, let uiImage = UIImage(named: imageName) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
                .accessibilityHidden(true)
        } else {
            fallbackShape.view(color: fallbackColor, size: 18)
                .accessibilityHidden(true)
        }
    }
    
    // MARK: - Zoom Control
    var zoomControl: some View {
        HStack(spacing: 8) {
            Button {
                UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                withAnimation(.spring(response: 0.4, dampingFraction: 0.78)) {
                    showZoomSlider.toggle()
                    if showZoomSlider {
                        showFilterStrip = false
                    }
                }
            } label: {
                Text("Zoom")
            }
            .buttonStyle(CircularButtonStyle(
                icon: "plus.magnifyingglass",
                usesGlass: true
            ))
            .accessibilityLabel(showZoomSlider ? "Ocultar control de zoom" : "Mostrar control de zoom")
            .accessibilityValue("\(matchSettings.zoom, specifier: "%.1f")x")
            
            if showZoomSlider { zoomSlider }
        }
    }
    
    var zoomSlider: some View {
        Slider(value: $matchSettings.zoom, in: 1.0...5.0, step: 0.1) {
            Text("Zoom")
        } minimumValueLabel: {
            Image(systemName: "minus")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(.primary)
        } maximumValueLabel: {
            Image(systemName: "plus")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(.primary)
        } onEditingChanged: { _ in
            print("Zoom: \(matchSettings.zoom)")
        }
        .controlSize(.regular)
        .frame(maxWidth: 220)
        .tint(.white)
        .padding(.horizontal, 12)
        .frame(height: 44)
        .glassEffect(.regular.interactive(), in: .capsule)
        .accessibilityLabel("Nivel de zoom")
        .accessibilityValue("\(matchSettings.zoom, specifier: "%.1f")x")
        .transition(.scale(scale: 0, anchor: .leading).combined(with: .opacity))
    }
    
    // MARK: - Magnifier-Style Camera Filter Control
    var filterControl: some View {
        VStack(spacing: 8) {
            if showFilterStrip {
                filterStrip
            }
            
            Button {
                UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                withAnimation(.spring(response: 0.4, dampingFraction: 0.78)) {
                    showFilterStrip.toggle()
                    if showFilterStrip {
                        showZoomSlider = false
                    }
                }
            } label: {
                Text("Filtros de cámara")
            }
            .buttonStyle(CircularButtonStyle(
                icon: showFilterStrip ? "xmark" : "camera.filters",
                usesGlass: true
            ))
            .overlay(alignment: .topTrailing) {
                if matchSettings.cameraFilter != .none && !showFilterStrip {
                    matchSettings.cameraFilter.swatchView(size: 14)
                        .offset(x: 2, y: -2)
                }
            }
            .accessibilityLabel(showFilterStrip ? "Ocultar filtros de cámara" : "Filtros de cámara estilo Lupa")
            .accessibilityValue(matchSettings.cameraFilter.localizedName)
            .accessibilityHint("Selecciona un filtro de color para daltonismo o alto contraste")
        }
    }
    
    var filterStrip: some View {
        ScrollViewReader { proxy in
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(CameraFilter.allCases) { filter in
                        let isSelected = (matchSettings.cameraFilter == filter)
                        Button {
                            UISelectionFeedbackGenerator().selectionChanged()
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                                matchSettings.cameraFilter = filter
                            }
                        } label: {
                            HStack(spacing: 6) {
                                filter.swatchView(size: 20)
                                
                                Text(filter.localizedName)
                                    .font(.system(.subheadline, design: .rounded, weight: isSelected ? .bold : .medium))
                                    .foregroundStyle(.primary)
                                    .lineLimit(1)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .frame(minHeight: 36)
                            .background(
                                Capsule(style: .continuous)
                                    .fill(isSelected ? Color.white.opacity(0.28) : Color.clear)
                            )
                            .overlay(
                                Capsule(style: .continuous)
                                    .strokeBorder(isSelected ? Color.white.opacity(0.85) : Color.white.opacity(0.15), lineWidth: isSelected ? 1.5 : 0.8)
                            )
                            .contentShape(Capsule())
                        }
                        .id(filter.id)
                        .buttonStyle(.plain)
                        .accessibilityElement(children: .ignore)
                        .accessibilityLabel("Filtro \(filter.localizedName)")
                        .accessibilityHint(filter.localizedDescription)
                        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
                    }
                }
                .padding(.horizontal, 0)
                .padding(.vertical, 8)
            }
            .frame(maxWidth: 200, maxHeight: 250)
            .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 12))
            .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 4)
            .transition(.scale(scale: 0, anchor: .trailing).combined(with: .opacity))
            .onAppear {
                proxy.scrollTo(matchSettings.cameraFilter.id, anchor: .center)
            }
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

#Preview("Enhanced Calibration & Soccer Scoreboard") {
    ZStack {
        // Simulate camera background with gradient
        LinearGradient(
            colors: [.gray.opacity(0.8), .gray],
            startPoint: .top,
            endPoint: .bottom
        )
        .edgesIgnoringSafeArea(.all)
        
        CameraButtonsView(teamSelectionManager: .constant(TeamSelectionManager()))
    }
}
