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
    let background: String
    let overlayColor: Color

    var body: some View {
        ZStack {
            // Imagen de fondo con esquinas redondeadas
            Image(background)
                .resizable()
                .scaledToFill()
                .frame(height: 170)
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                .overlay(overlayColor.opacity(0.50))
                .overlay(Color.black.opacity(0.35))
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .strokeBorder(.white.opacity(0.25), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: 8)
            
            // Logo placeholder en la esquina superior izquierda
            VStack {
                HStack {
                    // Logo o badge del equipo
                    if UIImage(named: badge) != nil {
                        Image(badge)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 65, height: 65)
                    } else {
                        // Placeholder icon si no hay imagen
                        Image(systemName: "shield.fill")
                            .font(.system(size: 24, weight: .medium))
                            .foregroundStyle(.white.opacity(0.9))
                    }
                    
                    Spacer()
                    
                    // Indicador de navegación
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.8))
                        .padding(8)
                        .background(
                            Circle()
                                .fill(.ultraThinMaterial)
                        )
                }
                .padding([.top, .horizontal], 20)
                
                Spacer()
            }
            
            // Información del equipo en la parte inferior
            VStack {
                Spacer()
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(teamTitle)
                            .font(.subheadline.bold())
                            .foregroundStyle(.white.opacity(0.85))
                        Text(teamName)
                            .font(.title3.bold())
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.leading)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 170)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 24))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(teamTitle): \(teamName)")
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
        background: "mexicoTeam",
        overlayColor: .green
    )
    .padding()
    .background(Color(.systemGroupedBackground))
}
