//
//  TeamGlassLargeCard.swift
//  AppAccesibilidad
//
//  Created by Maeva Mazadiego on 10/15/25.
//

import SwiftUI

@available(iOS 16.0, *)
struct TeamGlassLargeCard: View {
    let teamTitle: String
    let teamName: String
    let badge: String
    var badgeData: Data? = nil // Optional badge data for custom teams
    let overlayColor: Color

    var body: some View {
        ZStack(alignment: .topLeading) {
            // 1. Fondo base sólido con gradiente y borde
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(overlayColor)
                .overlay(
                    LinearGradient(
                        colors: [
                            Color.black.opacity(0.2),
                            Color.black.opacity(0.45)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .strokeBorder(.white.opacity(0.25), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: 8)

            // 2. Marca de agua decorativa de fondo (no desplaza el contenido)
            HStack {
                Spacer()
                badgeImageView
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .rotationEffect(.degrees(17))
                    .opacity(0.1)
                    .offset(x: 40, y: 25)
                    .accessibilityHidden(true)
            }
            .allowsHitTesting(false)

            // 3. Contenido interactivo principal
            VStack(alignment: .leading, spacing: 0) {
                // Fila superior: Logo del equipo en la esquina superior izquierda y chevron
                HStack(alignment: .top) {
                    badgeImageView
                        .scaledToFit()
                        .frame(width: 65, height: 65)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        .accessibilityHidden(true)

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.callout.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.8))
                        .padding(8)
                        .background(
                            Circle()
                                .fill(overlayColor)
                        )
                        .accessibilityHidden(true)
                }

                Spacer(minLength: 8)

                // Información del equipo en la parte inferior
                VStack(alignment: .leading, spacing: 4) {
                    Text(teamTitle)
                        .font(.subheadline.bold())
                        .foregroundStyle(.white.opacity(0.85))
                        .lineLimit(1)

                    Text(teamName)
                        .font(.title3.bold())
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(25)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 200)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 24))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(teamTitle)
        .accessibilityValue(teamName == "Seleccionar equipo" ? "Sin seleccionar" : teamName)
        .accessibilityHint("Toca dos veces para seleccionar este equipo")
        .accessibilityAddTraits(.isButton)
    }

    // Helper view para evitar duplicar la lógica de resolución de imágenes
    @ViewBuilder
    private var badgeImageView: some View {
        if let badgeData = badgeData, let uiImage = UIImage(data: badgeData) {
            Image(uiImage: uiImage)
                .resizable()
        } else if !badge.isEmpty, UIImage(named: badge) != nil {
            Image(badge)
                .resizable()
        } else {
            Image(systemName: "shield.fill")
                .resizable()
                .foregroundStyle(.white.opacity(0.9))
        }
    }
}


// MARK: - Preview
@available(iOS 16.0, *)
#Preview {
    TeamGlassLargeCard(
        teamTitle: "Equipo 2",
        teamName: "Selección Mexicana",
        badge: "mexicoLogo",
        overlayColor: .green
    )
    .padding()
    .background(Color(.systemGroupedBackground))
}
