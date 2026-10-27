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
        ZStack {
            // Use solid color background for all teams
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(overlayColor)
                .overlay(
                    // Add subtle gradient for depth
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
            
            VStack(alignment: .leading, spacing: 12) {
                // Logo placeholder en la esquina superior izquierda
                HStack {
                    // Logo o badge del equipo
                    if let badgeData = badgeData, let uiImage = UIImage(data: badgeData) {
                        // Custom team logo from data
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 65, height: 65)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .accessibilityHidden(true)
                    } else if !badge.isEmpty, UIImage(named: badge) != nil {
                        // Predefined team logo from assets
                        Image(badge)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 65, height: 65)
                            .accessibilityHidden(true)
                    } else {
                        // Placeholder icon if no image
                        Image(systemName: "shield.fill")
                            .font(.title2.weight(.medium))
                            .foregroundStyle(.white.opacity(0.9))
                            .accessibilityHidden(true)
                    }
                    
                    Spacer()
                    
                    // Indicador de navegación
                    Image(systemName: "chevron.right")
                        .font(.callout.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.8))
                        .padding(8)
                        .background(
                            Circle()
                                .fill(.ultraThinMaterial)
                        )
                        .accessibilityHidden(true)
                }
                
                Spacer(minLength: 8)
                
                // Información del equipo en la parte inferior
                VStack(alignment: .leading, spacing: 4) {
                    Text(teamTitle)
                        .font(.subheadline.bold())
                        .foregroundStyle(.white.opacity(0.9))
                    Text(teamName)
                        .font(.title3.bold())
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(20)
        }
        .frame(maxWidth: .infinity)
        .frame(minHeight: 170)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 24))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(teamTitle)
        .accessibilityValue(teamName == "Seleccionar equipo" ? "Sin seleccionar" : teamName)
        .accessibilityHint("Toca dos veces para seleccionar este equipo")
        .accessibilityAddTraits(.isButton)
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
