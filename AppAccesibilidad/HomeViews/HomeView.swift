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
    @State private var showingHelp = false
    
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

                        // MARK: - Header
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Nuevo partido")
                                .font(.largeTitle.bold())
                                .accessibilityAddTraits(.isHeader) // MARK: - Accesibilidad

                            Text("Configura tu partido")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .accessibilityElement(children: .combine) // MARK: - Accesibilidad
                        .padding(.horizontal, 20)
                        .padding(.top, 16)

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
                        .accessibilityValue(teamSelectionManager.team1?.name ?? "Seleccionar equipo") // Valor (estado)
                        .accessibilityHint("Toca para seleccionar el equipo 1.") // Acción
                        .accessibilityAddTraits(.isButton) // Trátalo como un botón
                        
                        
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
                        .accessibilityValue(teamSelectionManager.team2?.name ?? "Seleccionar equipo") // Valor (estado)
                        .accessibilityHint("Toca para seleccionar el equipo 2.") // Acción
                        .accessibilityAddTraits(.isButton) // Trátalo como un botón

                        // MARK: - Grid inferior
                        VStack(spacing: 18) {
//                            OptionGlassCard(
//                                title: "Configuración del partido",
//                                systemIcon: "gearshape.fill",
//                                tint: .gray
//                            )
                            NavigationLink(destination: StatisticsMainView()
                                .navigationBarBackButtonHidden(true)) {
                                OptionGlassCard(
                                    title: "Estadísticas de equipos",
                                    systemIcon: "chart.bar.fill",
                                    tint: .orange
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .padding(.horizontal, 20)

                        // MARK: - CTA Inferior
                        Button(action: {
                            DispatchQueue.main.async {
                                AppDelegate.orientationLock = .landscapeRight
                                print("cambiando a landscape")
                                showingCamera = true
                            }
                            // TODO: acción “Empezar partido”
                        }) {
                            Text("Empezar partido")
                                .font(.headline.bold())
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(GlassCapsuleButton(tint: .blue, prominent: true))
                        .padding(.horizontal, 24)
                        .padding(.bottom, 30)
                    }
                }

                // MARK: - Botón de ayuda flotante
                VStack {
                    HStack {
                        Spacer()
                        Button {
                            showingHelp = true
                        } label: {
                            Image(systemName: "questionmark.circle")
                                .font(.title3.bold())
                                .padding(10)
                        }
                        .buttonStyle(GlassCircleButton())
                        .padding(.trailing, 16)
                        .padding(.top, 12)
                    }
                    Spacer()
                }
                .alert("Ayuda", isPresented: $showingHelp) {
                    Button("Entendido", role: .cancel) { }
                } message: {
                    Text("Selecciona los equipos que participarán en el partido. Luego presiona 'Empezar partido' para comenzar el seguimiento en tiempo real con reconocimiento de gestos y estadísticas accesibles.")
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .fullScreenCover(isPresented: $showingCamera) {
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
