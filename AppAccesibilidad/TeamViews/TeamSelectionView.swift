//
//  TeamSelectionView.swift
//  AppAccesibilidad
//
//  Created by Maeva Mazadiego on 10/10/25.
//

import SwiftUI

// MARK: - MODELOS DE DEMO
struct Team: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let badge: String     // nombre del asset en Assets.xcassets
    let color: Color
}

struct TeamSection: Identifiable {
    let id = UUID()
    let title: String     // ya viene localizado en este demo
    let teams: [Team]
}

// MARK: - VISTA PRINCIPAL
@available(iOS 16.0, *)
struct NewMatchCatalogView: View {

    // Demo: reemplaza por tu data real
    private let sections: [TeamSection] = [
        .init(
            title: String(localized: "NewMatch.section.libertadores", defaultValue: "Copa Libertadores"),
            teams: [
                .init(name: "Boca Juniors", badge: "boca.badge",
                      color: Color(red: 0/255, green: 52/255, blue: 148/255)),
                .init(name: "River Plate", badge: "river.badge",
                      color: Color(red: 227/255, green: 6/255, blue: 19/255)),
                .init(name: "Flamengo", badge: "flamengo.badge",
                      color: Color(red: 227/255, green: 6/255, blue: 19/255)),
                .init(name: "Palmeiras", badge: "palmeiras.badge",
                      color: Color(red: 0/255, green: 122/255, blue: 51/255)),
                .init(name: "São Paulo", badge: "saopaulo.badge",
                      color: Color(red: 227/255, green: 6/255, blue: 19/255)),
                .init(name: "Santos", badge: "santos.badge",
                      color: Color(red: 255/255, green: 255/255, blue: 255/255)),
                .init(name: "Peñarol", badge: "penarol.badge",
                      color: Color(red: 255/255, green: 193/255, blue: 7/255)),
                .init(name: "Nacional", badge: "nacional.badge",
                      color: Color(red: 0/255, green: 82/255, blue: 155/255)),
                .init(name: "Colo-Colo", badge: "colocolo.badge",
                      color: Color(red: 255/255, green: 255/255, blue: 255/255))
            ]
        ),
        .init(
            title: String(localized: "NewMatch.section.mexico", defaultValue: "Liga MX"),
            teams: [
                .init(name: "Club América", badge: "america.badge",
                      color: Color(red: 255/255, green: 223/255, blue: 0/255)),
                .init(name: "Chivas", badge: "chivas.badge",
                      color: Color(red: 227/255, green: 6/255, blue: 19/255)),
                .init(name: "Cruz Azul", badge: "cruzazul.badge",
                      color: Color(red: 0/255, green: 82/255, blue: 155/255)),
                .init(name: "Pumas", badge: "pumas.badge",
                      color: Color(red: 0/255, green: 52/255, blue: 113/255)),
                .init(name: "Tigres", badge: "tigres.badge",
                      color: Color(red: 255/255, green: 193/255, blue: 7/255)),
                .init(name: "Monterrey", badge: "monterrey.badge",
                      color: Color(red: 0/255, green: 82/255, blue: 155/255)),
                .init(name: "Santos Laguna", badge: "santoslaguna.badge",
                      color: Color(red: 0/255, green: 122/255, blue: 51/255)),
                .init(name: "León", badge: "leon.badge",
                      color: Color(red: 0/255, green: 122/255, blue: 51/255)),
                .init(name: "Atlético San Luis", badge: "sanluis.badge",
                      color: Color(red: 227/255, green: 6/255, blue: 19/255))
            ]
        ),
        .init(
            title: String(localized: "NewMatch.section.europe", defaultValue: "Europa"),
            teams: [
                .init(name: "Real Madrid", badge: "realmadrid.badge",
                      color: Color(red: 255/255, green: 255/255, blue: 255/255)),
                .init(name: "FC Barcelona", badge: "barcelona.badge",
                      color: Color(red: 165/255, green: 39/255, blue: 52/255)),
                .init(name: "Manchester United", badge: "manutd.badge",
                      color: Color(red: 227/255, green: 6/255, blue: 19/255)),
                .init(name: "Liverpool", badge: "liverpool.badge",
                      color: Color(red: 200/255, green: 16/255, blue: 46/255)),
                .init(name: "Paris Saint-Germain", badge: "psg.badge",
                      color: Color(red: 17/255, green: 54/255, blue: 92/255)),
                .init(name: "Bayern München", badge: "bayern.badge",
                      color: Color(red: 213/255, green: 39/255, blue: 39/255)),
                .init(name: "Juventus", badge: "juventus.badge",
                      color: Color(red: 255/255, green: 255/255, blue: 255/255)),
                .init(name: "AC Milan", badge: "milan.badge",
                      color: Color(red: 227/255, green: 6/255, blue: 19/255)),
                .init(name: "Chelsea", badge: "chelsea.badge",
                      color: Color(red: 3/255, green: 70/255, blue: 148/255)),
                .init(name: "Arsenal", badge: "arsenal.badge",
                      color: Color(red: 239/255, green: 1/255, blue: 7/255)),
                .init(name: "Tottenham", badge: "tottenham.badge",
                      color: Color(red: 19/255, green: 34/255, blue: 87/255)),
                .init(name: "Inter Milan", badge: "inter.badge",
                      color: Color(red: 0/255, green: 82/255, blue: 155/255))
            ]
        )
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemBackground).ignoresSafeArea()

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 18) {

                        // TÍTULO Y SUBTÍTULO
                        VStack(alignment: .leading, spacing: 8) {
                            Text(String(localized: "NewMatch.title", defaultValue: "Nuevo partido"))
                                .font(.largeTitle.bold())
                                .accessibilityAddTraits(.isHeader)

                            Text(String(localized: "NewMatch.configure", defaultValue: "Configura tu partido"))
                                .font(.title3.weight(.semibold))
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 12)

                        // SECCIONES CON SCROLL HORIZONTAL
                        ForEach(sections.prefix(2)) { section in // Solo las primeras 2 secciones
                            VStack(alignment: .leading, spacing: 12) {
                                Text(section.title)
                                    .font(.headline)
                                    .padding(.horizontal, 20)

                                ScrollView(.horizontal, showsIndicators: false) {
                                    LazyHStack(spacing: 16) {
                                        ForEach(section.teams) { team in
                                            VStack(spacing: 8) {
                                                TeamSquareCard(
                                                    badgeName: team.badge,
                                                    background: team.color
                                                )
                                                .frame(width: 100) // ancho fijo para consistencia
                                                
                                                Text(team.name)
                                                    .font(.caption.weight(.semibold))
                                                    .multilineTextAlignment(.center)
                                                    .lineLimit(2)
                                                    .minimumScaleFactor(0.8)
                                                    .frame(width: 100, height: 28)
                                                    .accessibilityLabel(Text(team.name))
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 20)
                                }
                                .scrollTargetBehavior(.viewAligned) // iOS 17+ smooth scrolling
                            }
                        }

                        Divider()
                            .padding(.horizontal, 20)
                            .padding(.top, 6)

                        Spacer(minLength: 24)
                    }
                    .padding(.bottom, 24)
                }

                // Botón flotante (arriba-derecha)
                VStack {
                    HStack {
                        Spacer()
                        Button {
                            // TODO: acción (p.ej. pantalla de selección múltiple)
                        } label: {
                            Image(systemName: "rectangle.dashed") // ícono de tu mock
                                .font(.title3.weight(.semibold))
                                .padding(10)
                        }
                        .buttonStyle(FloatingGlassCircle())
                        .accessibilityLabel(Text(String(localized: "A11y.multiSelect", defaultValue: "Seleccionar varios")))
                        .padding(.trailing, 12)
                        .padding(.top, 6)
                    }
                    Spacer()
                }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }
}

// MARK: - TARJETA CUADRADA (logo + fondo y borde)
@available(iOS 16.0, *)
struct TeamSquareCard: View {
    let badgeName: String
    let background: Color

    var body: some View {
        let corner: CGFloat = 18
        ZStack {
            RoundedRectangle(cornerRadius: corner, style: .continuous)
                .fill(background)
                .overlay(
                    RoundedRectangle(cornerRadius: corner, style: .continuous)
                        .strokeBorder(Color.primary.opacity(0.12), lineWidth: 1)
                )

            Group {
                if UIImage(named: badgeName) != nil {
                    Image(badgeName)
                        .resizable()
                        .scaledToFit()
                        .padding(12)
                } else {
                    // Fallback si no existe el asset
                    Image(systemName: "sportscourt.fill")
                        .font(.system(size: 36, weight: .semibold))
                        .foregroundStyle(.secondary)
                }
            }
        }
        .frame(height: 100)             // altura más compacta para scroll horizontal
        .accessibilityHidden(true)
    }
}

// MARK: - ESTILO DEL BOTÓN FLOTANTE
@available(iOS 16.0, *)
struct FloatingGlassCircle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(.primary)
            .background(
                Circle().fill(.ultraThinMaterial)
            )
            .overlay(
                Circle().strokeBorder(.white.opacity(0.25), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.12), radius: 8, x: 0, y: 6)
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.easeInOut(duration: 0.12), value: configuration.isPressed)
    }
}

// MARK: - PREVIEW
@available(iOS 16.0, *)
#Preview {
    NewMatchCatalogView()
        .environment(\.locale, .init(identifier: "es"))
}
