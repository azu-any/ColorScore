//
//  OptionGlassCard.swift
//  AppAccesibilidad
//
//  Created by Maeva Mazadiego on 15/10/25.
//

import SwiftUI

@available(iOS 16.0, *)
struct OptionGlassCard: View {
    let title: String
    let systemIcon: String
    let tint: Color
    
    var body: some View {
        HStack(spacing: 10) {
            // Ícono en un círculo con glass effect
            ZStack {
                Circle()
                    .fill(tint.opacity(0.15))
                    .frame(width: 50, height: 50)
                
                Image(systemName: systemIcon)
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(tint)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.callout.weight(.semibold))
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.leading)
                
                Text("Toca para acceder")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption.weight(.bold))
                .foregroundStyle(.tertiary)
                .padding(8)
                .background(
                    Circle()
                        .fill(.ultraThinMaterial)
                )
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 82)
        .glassEffect(.regular.tint(tint.opacity(0.3)).interactive(), in: .rect(cornerRadius: 16))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(title)
        .accessibilityAddTraits(.isButton)
    }
}

// MARK: - Preview
@available(iOS 16.0, *)
#Preview {
    VStack(spacing: 16) {
        GlassEffectContainer(spacing: 30.0) {
            VStack(spacing: 12) {
                OptionGlassCard(
                    title: "Configuración del partido",
                    systemIcon: "gearshape.fill",
                    tint: .blue
                )
                Spacer()
                    .frame(height: 1)
                
                OptionGlassCard(
                    title: "Estadísticas del equipo",
                    systemIcon: "chart.bar.fill",
                    tint: .green
                )
            }
        }
    }
    .padding()
    .background(
        LinearGradient(
            colors: [
                Color(.systemBackground),
                Color(.systemGray6).opacity(0.3),
                Color(.systemBackground)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    )
}
