//
//  TutorialView.swift
//  AppAccesibilidad
//
//  Created by Azuany Mila Cerón on 26/10/26.
//

import SwiftUI

struct TutorialStep: Identifiable {
    let id = UUID()
    let stepNumber: Int
    let title: String
    let description: String
    let systemIcon: String
    let tint: Color
}

@available(iOS 16.0, *)
struct TutorialView: View {
    private let steps: [TutorialStep] = [
        TutorialStep(
            stepNumber: 1,
            title: "Selecciona los equipos",
            description: "En la pantalla principal, toca las tarjetas de Equipo 1 y Equipo 2 para elegir los clubes que se enfrentarán, o crea un equipo personalizado con tu propio escudo y color.",
            systemIcon: "shield.lefthalf.filled",
            tint: .blue
        ),
        TutorialStep(
            stepNumber: 2,
            title: "Inicia el partido",
            description: "Presiona el botón 'Empezar partido'. La aplicación cambiará automáticamente a orientación horizontal y activará la cámara trasera.",
            systemIcon: "play.circle.fill",
            tint: .green
        ),
        TutorialStep(
            stepNumber: 3,
            title: "Calibra la cámara",
            description: "Apunta hacia los jugadores en la cancha durante 10 segundos y presiona 'Empezar calibración'. El modelo entrenará automáticamente para distinguir los uniformes de cada equipo.",
            systemIcon: "camera.viewfinder",
            tint: .orange
        ),
        TutorialStep(
            stepNumber: 4,
            title: "Personaliza figuras y colores",
            description: "Toca el botón de configuración (engrane) durante el partido para elegir figuras geométricas y colores de alto contraste para los jugadores, porteros y el balón.",
            systemIcon: "slider.horizontal.3",
            tint: .purple
        ),
        TutorialStep(
            stepNumber: 5,
            title: "Marcador y zoom en vivo",
            description: "Toca el nombre o puntaje de cada equipo en el marcador superior para sumar o restar goles, y utiliza el control inferior izquierdo para ajustar el nivel de zoom.",
            systemIcon: "sportscourt.fill",
            tint: .teal
        )
    ]

    var body: some View {
        ZStack {
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
                VStack(alignment: .leading, spacing: 20) {
                    // Header Banner
                    headerCard

                    Text("Paso a paso")
                        .font(.title3.bold())
                        .foregroundStyle(.primary)
                        .padding(.horizontal, 4)
                        .accessibilityAddTraits(.isHeader)

                    // Steps List
                    VStack(spacing: 16) {
                        ForEach(steps) { step in
                            TutorialStepCard(step: step)
                        }
                    }

                    // Accessibility tip card
                    accessibilityTipCard
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
        }
        .navigationTitle("Tutorial")
        .navigationBarTitleDisplayMode(.large)
    }

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.15))
                        .frame(width: 56, height: 56)

                    Image(systemName: "figure.soccer")
                        .font(.title.weight(.bold))
                        .foregroundStyle(.blue)
                }
                .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 4) {
                    Text("¿Cómo usar la app?")
                        .font(.title3.bold())
                        .foregroundStyle(.primary)

                    Text("Sigue los partidos en tiempo real con asistencia visual de alto contraste.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassEffect(.regular.tint(.blue.opacity(0.15)), in: .rect(cornerRadius: 24))
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isHeader)
    }

    private var accessibilityTipCard: some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.indigo.opacity(0.15))
                    .frame(width: 48, height: 48)

                Image(systemName: "accessibility")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(.indigo)
            }
            .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 6) {
                Text("Diseñado para la accesibilidad")
                    .font(.headline)
                    .foregroundStyle(.primary)

                Text("Compatible con VoiceOver y pensado para personas con daltonismo o baja visión mediante indicadores geométricos personalizables.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassEffect(.regular.tint(.indigo.opacity(0.15)), in: .rect(cornerRadius: 20))
        .accessibilityElement(children: .combine)
    }
}

@available(iOS 16.0, *)
struct TutorialStepCard: View {
    let step: TutorialStep

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            ZStack {
                Circle()
                    .fill(step.tint.opacity(0.15))
                    .frame(width: 52, height: 52)

                Image(systemName: step.systemIcon)
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(step.tint)
            }
            .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 6) {
                Text("Paso \(step.stepNumber)")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(step.tint)
                    .textCase(.uppercase)

                Text(step.title)
                    .font(.headline.bold())
                    .foregroundStyle(.primary)

                Text(step.description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassEffect(.regular.tint(step.tint.opacity(0.12)), in: .rect(cornerRadius: 20))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Paso \(step.stepNumber): \(step.title). \(step.description)")
    }
}

@available(iOS 16.0, *)
#Preview {
    NavigationStack {
        TutorialView()
    }
}
