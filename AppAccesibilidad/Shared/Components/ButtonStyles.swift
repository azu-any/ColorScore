//
//  CircularButtonStyle.swift
//  AppAccesibilidad
//
//  Created by Azuany Mila Cerón on 11/8/25.
//
import SwiftUI

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
            .foregroundStyle(.primary)
            .contentTransition(.symbolEffect(.replace))
            .frame(minWidth: 44, minHeight: 44)
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
            .frame(minWidth: 44, minHeight: 44)
            .background {
                Circle()
                    .fill(Color.white.opacity(0.8))
                    .frame(width: 28, height: 28)
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
            .frame(minWidth: 44, minHeight: 44)
            .background {
                Circle()
                    .fill(teamColor)
                    .frame(width: 40, height: 40)
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
//            .foregroundStyle(.primary)
            .frame(minWidth: 32, minHeight: 32)
            .contentShape(Rectangle())
            .scaleEffect(configuration.isPressed ? 0.85 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}
