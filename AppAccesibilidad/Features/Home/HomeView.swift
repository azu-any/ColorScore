//
//  HomeView.swift
//  AppAccesibilidad
//
//  Created by Maeva Mazadiego on 10/10/25.
//

import SwiftUI

@available(iOS 16.0, *)
struct HomeView: View {
    @State private var showingCamera = false
    @State private var isTransitioningToCamera = false
    @State private var teamSelectionManager = TeamSelectionManager()
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Fondo sutil con gradiente
                LinearGradient(
                    colors: [
                        Color(.systemBackground),
                        Color(.systemGray6).opacity(0.3),
                        Color(.systemBackground)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {

                        // MARK: - Team 1 Card
                        NavigationLink(destination: TeamSelectionView(
                            selectionManager: teamSelectionManager,
                            teamSlot: 1
                        )) {
                            TeamGlassLargeCard(
                                teamTitle: "Equipo 1",
                                teamName: teamSelectionManager.team1?.name ?? "Seleccionar equipo",
                                badge: teamSelectionManager.team1?.imageName ?? "",
                                badgeData: teamSelectionManager.team1?.imageData,
                                overlayColor: teamSelectionManager.team1?.teamColor ?? .blue
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.horizontal, 20)
                        // MARK: - Accesibilidad
                        .accessibilityElement(children: .ignore) // Ignora los textos internos
                        .accessibilityLabel("Equipo 1") // Etiqueta principal
                        .accessibilityValue(teamSelectionManager.team1?.name ?? "Sin seleccionar") // Valor (estado)
                        .accessibilityHint("Toca dos veces para seleccionar el equipo 1.") // Acción
                        .accessibilityAddTraits(.isButton) // Trátalo como un botón
                        .accessibilitySortPriority(9)
                        
                        
                        // MARK: - Team 2 Card
                        NavigationLink(destination: TeamSelectionView(
                            selectionManager: teamSelectionManager,
                            teamSlot: 2
                        )) {
                            TeamGlassLargeCard(
                                teamTitle: "Equipo 2",
                                teamName: teamSelectionManager.team2?.name ?? "Seleccionar equipo",
                                badge: teamSelectionManager.team2?.imageName ?? "",
                                badgeData: teamSelectionManager.team2?.imageData,
                                overlayColor: teamSelectionManager.team2?.teamColor ?? .green
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.horizontal, 20)
                        // MARK: - Accesibilidad
                        .accessibilityElement(children: .ignore) // Ignora los textos internos
                        .accessibilityLabel("Equipo 2") // Etiqueta principal
                        .accessibilityValue(teamSelectionManager.team2?.name ?? "Sin seleccionar") // Valor (estado)
                        .accessibilityHint("Toca dos veces para seleccionar el equipo 2.") // Acción
                        .accessibilityAddTraits(.isButton) // Trátalo como un botón
                        .accessibilitySortPriority(8)

                        
                    }
                }

                
                
                if isTransitioningToCamera {
                    Color.black
                        .ignoresSafeArea()
                        .transition(.opacity)
                        .zIndex(10)
                }
            }
            .navigationTitle("Nuevo partido")
            .toolbar {
                // MARK: - Botón de créditos
                ToolbarItem(placement: .topBarLeading) {
                    NavigationLink(destination: CreditsView()) {
                        Image(systemName: "info.circle")
                            .font(.title3.bold())
                    }
                    .accessibilityLabel("Créditos")
                    .accessibilityHint("Muestra la información y los créditos de desarrollo de la aplicación.")
                    .accessibilityAddTraits(.isButton)
                    .accessibilitySortPriority(5)
                }
                
                // MARK: - Botón de tutorial / ayuda
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(destination: TutorialView()) {
                        Image(systemName: "questionmark.circle")
                            .font(.title3.bold())
                    }
                    .accessibilityLabel("Ayuda y tutorial")
                    .accessibilityHint("Abre el tutorial paso a paso sobre cómo configurar e iniciar el partido.")
                    .accessibilityAddTraits(.isButton)
                    .accessibilitySortPriority(5)
                }
                
            }
            .overlay(alignment: .bottom) {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isTransitioningToCamera = true
                    }
                    AppDelegate.orientationLock = .landscapeRight
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.28) {
                        var transaction = Transaction()
                        transaction.disablesAnimations = false
                        withTransaction(transaction) {
                            showingCamera = true
                        }
                    }
                }) {
                    Text("Empezar partido")
                        .font(.headline.bold())
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(GlassCapsuleButton(tint: .blue, prominent: true))
                .padding(.horizontal, 24)
                .padding(.top, 8)
                .padding(.bottom, 30)
                .accessibilityLabel("Empezar partido")
                .accessibilityHint("Inicia el partido y abre la cámara en modo horizontal.")
                .accessibilityAddTraits(.isButton)
                .accessibilitySortPriority(6)
            }
            .fullScreenCover(isPresented: $showingCamera, onDismiss: {
                AppDelegate.orientationLock = .portrait
                withAnimation(.easeOut(duration: 0.25)) {
                    isTransitioningToCamera = false
                }
            }) {
                CameraButtonsView(teamSelectionManager: $teamSelectionManager)
            }
        }
    }
}





// MARK: - Estilos Liquid Glass reutilizados
@available(iOS 16.0, *)
struct GlassCapsuleButton: ButtonStyle {
    var tint: Color
    var prominent: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(prominent ? .white : .primary)
            .padding(.horizontal, 24)
            .padding(.vertical, 18)
            .background {
                if prominent {
                    Capsule()
                        .fill(tint)
                } else {
                    Capsule()
                        .fill(.ultraThinMaterial)
                }
            }
            .overlay(
                Capsule(style: .continuous)
                    .strokeBorder(.white.opacity(prominent ? 0.3 : 0.2), lineWidth: 1)
            )
            .glassEffect(.regular.tint(prominent ? .clear : tint).interactive(), in: .capsule)
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}



@available(iOS 16.0, *)
struct GlassCircleButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(.primary)
            .background(
                Circle().fill(.ultraThinMaterial)
            )
            .overlay(
                Circle().strokeBorder(.white.opacity(0.25), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 6)
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}



@available(iOS 16.0, *)
#Preview {
    HomeView()
        .environment(\.locale, .init(identifier: "es"))
}
