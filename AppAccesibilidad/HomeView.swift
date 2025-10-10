//
//  HomeView.swift
//  AppAccesibilidad
//
//  Created by Maeva Mazadiego on 10/10/25.
//

import SwiftUI

// MARK: - New Match View
@available(iOS 16.0, *)
struct NewMatchView: View {
    // Demo state (puedes enlazarlo a tu modelo)
    @State private var team1Name = String(localized: "Home.team1Name", defaultValue: "Paris Saint-Germain")
    @State private var team2Name = String(localized: "Home.team2Name", defaultValue: "Paris Saint-Germain")
    @State private var team1Color: Color = Color(.sRGB, red: 17/255, green: 54/255, blue: 92/255) // azul PSG
    @State private var team2Color: Color = Color(.sRGB, red: 17/255, green: 54/255, blue: 92/255)

    var body: some View {
        NavigationStack {
            ZStack {
                // Fondo con gradiente suave (claro/oscuro friendly)
                LinearGradient(
                    colors: [
                        Color(.systemBackground),
                        Color(.systemGray6).opacity(0.35),
                        Color(.systemBackground)
                    ],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {
                        // Header
                        VStack(alignment: .leading, spacing: 6) {
                            Text(String(localized: "Home.newMatchTitle", defaultValue: "Nuevo partido"))
                                .font(.largeTitle.bold())
                                .accessibilityAddTraits(.isHeader)

                            Text(String(localized: "Home.subtitle", defaultValue: "Subtitle"))
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.top, 12)
                        .padding(.horizontal, 20)

                        // TARJETA GRANDE #1
                        TeamGlassCard(
                            name: team1Name,
                            badgeName: "psg.badge",  // pon aquí el nombre del asset
                            baseColor: team1Color,
                            style: .large
                        )
                        .padding(.horizontal, 20)

                        // TARJETA GRANDE #2
                        TeamGlassCard(
                            name: team2Name,
                            badgeName: "psg.badge",
                            baseColor: team2Color,
                            style: .large
                        )
                        .padding(.horizontal, 20)

                        // GRID 2x (tarjetas chicas)
                        HStack(spacing: 18) {
                            TeamGlassCard(
                                name: team1Name,
                                badgeName: "psg.badge",
                                baseColor: team1Color,
                                style: .small
                            )

                            TeamGlassCard(
                                name: team2Name,
                                badgeName: "psg.badge",
                                baseColor: team2Color,
                                style: .small
                            )
                        }
                        .padding(.horizontal, 20)

                        // CTA inferior
                        Button {
                            // TODO: acción "Empezar partido"
                        } label: {
                            Text(String(localized: "Home.startMatch", defaultValue: "Empezar partido"))
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                        }
                        .buttonStyle(GlassCapsuleButton(tint: .red))
                        .padding(.horizontal, 24)
                        .padding(.top, 8)
                        .accessibilityLabel(String(localized: "A11y.startMatch", defaultValue: "Empezar partido"))

                        Spacer(minLength: 36)
                    }
                    .padding(.bottom, 24)
                }

                // Botón flotante de ajustes (arriba-derecha)
                VStack {
                    HStack {
                        Spacer()
                        Button {
                            // TODO: abrir ajustes
                        } label: {
                            Image(systemName: "gearshape.fill")
                                .font(.title3.weight(.semibold))
                                .padding(12)
                        }
                        .buttonStyle(GlassCircleButton())
                        .accessibilityLabel(String(localized: "A11y.settings", defaultValue: "Abrir ajustes"))
                        .padding(.trailing, 16)
                        .padding(.top, 10)
                    }
                    Spacer()
                }
            }
            .toolbar(.hidden, for: .navigationBar) // la UI ya trae su propio header
        }
    }
}

// MARK: - Team Card
@available(iOS 16.0, *)
struct TeamGlassCard: View {
    enum Style { case large, small }

    let name: String
    let badgeName: String // nombre del asset en Assets.xcassets
    let baseColor: Color
    let style: Style

    var body: some View {
        let corner: CGFloat = 18
        let height: CGFloat = style == .large ? 170 : 150

        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 16) {
                // Escudo (si no existe el asset, muestra un SF Symbol)
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(baseColor.opacity(0.18))

                    Group {
                        if UIImage(named: badgeName) != nil {
                            Image(badgeName)
                                .resizable()
                                .scaledToFit()
                                .padding(6)
                        } else {
                            Image(systemName: "shield.lefthalf.filled")
                                .font(.system(size: 34, weight: .semibold))
                                .foregroundStyle(.white)
                                .shadow(radius: 2)
                                .padding(10)
                        }
                    }
                }
                .frame(width: 64, height: 64)
                .glassify(tint: baseColor.opacity(0.35), shape: .rounded(corner))

                Spacer()
            }

            Spacer()

            Text(name)
                .font(.headline)
                .foregroundStyle(.white)
                .shadow(radius: 1)

        }
        .frame(maxWidth: .infinity)
        .frame(height: height)
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: corner, style: .continuous)
                .fill(baseColor) // color base del club
        )
        .overlay(
            RoundedRectangle(cornerRadius: corner, style: .continuous)
                .strokeBorder(.white.opacity(0.15), lineWidth: 1)
        )
        .glassOverlay(cornerRadius: corner) // capa “líquida” por encima
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("\(name)"))
    }
}

// MARK: - Glass Styles
@available(iOS 16.0, *)
struct GlassCapsuleButton: ButtonStyle {
    var tint: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(.white)
            .background(
                Capsule(style: .continuous)
                    .fill(tint.gradient)
            )
            .overlay(
                Capsule(style: .continuous)
                    .strokeBorder(.white.opacity(0.25), lineWidth: 1)
            )
            .glassOverlay(cornerRadius: 26)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeInOut(duration: 0.12), value: configuration.isPressed)
    }
}

@available(iOS 16.0, *)
struct GlassCircleButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(.primary)
            .background(
                Circle()
                    .fill(.ultraThinMaterial)
            )
            .overlay(
                Circle().strokeBorder(.white.opacity(0.25), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.12), radius: 8, x: 0, y: 6)
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.easeInOut(duration: 0.12), value: configuration.isPressed)
    }
}

// MARK: - Glass Helpers
@available(iOS 16.0, *)
extension View {
    /// Aplica un efecto vidrio/blur sobre una forma dada.
    func glassify(tint: Color = .white.opacity(0.2),
                  shape: GlassShape = .rounded(16)) -> some View {
        modifier(Glassify(tint: tint, shape: shape))
    }

    /// Capa brillante superior con highlights y blur para “liquid glass”.
    func glassOverlay(cornerRadius: CGFloat = 16) -> some View {
        overlay(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(Color.white.opacity(0.06))
                .blendMode(.screen)
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .strokeBorder(.white.opacity(0.18), lineWidth: 0.8)
                )
        )
    }
}

@available(iOS 16.0, *)
enum GlassShape {
    case rounded(CGFloat)
    case circle

    func path() -> AnyShape {
        switch self {
        case .rounded(let r): 
            AnyShape(RoundedRectangle(cornerRadius: r, style: .continuous))
        case .circle: 
            AnyShape(Circle())
        }
    }
}

@available(iOS 16.0, *)
struct Glassify: ViewModifier {
    var tint: Color
    var shape: GlassShape

    func body(content: Content) -> some View {
        content
            .background(
                shape.path()
                    .fill(.ultraThinMaterial)
                    .overlay(
                        shape.path().stroke(.white.opacity(0.25), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.12), radius: 10, x: 0, y: 8)
                    .background(shape.path().fill(tint.opacity(0.18)))
            )
    }
}

// MARK: - Preview
@available(iOS 16.0, *)
#Preview {
    NewMatchView()
        .environment(\.locale, .init(identifier: "es"))
}
