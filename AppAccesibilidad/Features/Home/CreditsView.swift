//
//  CreditsView.swift
//  AppAccesibilidad
//
//  Created by Azuany Mila Cerón on 26/10/26.
//

import SwiftUI

struct CreditSocial: Identifiable {
    let id = UUID()
    let platform: String
    let handle: String
    var systemIcon: String = "link"
    var icon: String? = nil
    var url: String? = nil
}

struct CreditPerson: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let profileImage: String?
    let socials: [CreditSocial]
}

struct CreditTech: Identifiable {
    let id = UUID()
    let name: String
    let detail: String
    let systemIcon: String
    let tint: Color
}

@available(iOS 16.0, *)
struct CreditsView: View {
    private let teamMembers: [CreditPerson] = [
        CreditPerson(
            name: "Azuany Mila Ceron",
            description: "Desarrolladora de software apasionada por crear herramientas tecnológicas accesibles e inclusivas.",
            profileImage: "Azu",
            socials: [
                CreditSocial(platform: "GitHub", handle: "@azu-any", icon: "github", url: "https://github.com/azu-any"),
                CreditSocial(platform: "LinkedIn", handle: "Azuany Mila Ceron", icon: "linkedin", url: "https://www.linkedin.com/in/azuany-mila"),
                CreditSocial(platform: "Correo", handle: "azuany.mila@gmail.com", systemIcon: "envelope.fill")
            ]
        ),
        CreditPerson(
            name: "Nina Maeva Mazadiego Cortés",
            description: "Desarrolladora de software apasionada por crear herramientas tecnológicas accesibles e inclusivas.",
            profileImage: nil,
            socials: [
                CreditSocial(platform: "GitHub", handle: "@maeva-mazadiego", icon: "github"),
                CreditSocial(platform: "LinkedIn", handle: "Nina Maeva Mazadiego Cortés", icon: "linkedin"),
            ]
        ),
        CreditPerson(
            name: "Daniela Renée Ramírez Gutiérrez",
            description: "Desarrolladora de software apasionada por crear herramientas tecnológicas accesibles e inclusivas.",
            profileImage: nil,
            socials: [
                CreditSocial(platform: "GitHub", handle: "@daniela-ramirez", icon: "github", url: "https://github.com/danielarenee"),
                CreditSocial(platform: "LinkedIn", handle: "Daniela Renée Ramírez Gutiérrez", icon: "linkedin", url: "https://github.com/MaeMazcort"),
            ]
        ),
        CreditPerson(
            name: "Goben Diego Constantino Aguirre",
            description: "Desarrollador de software apasionado por crear herramientas tecnológicas accesibles e inclusivas.",
            profileImage: nil,
            socials: [
                CreditSocial(platform: "GitHub", handle: "@goben-constantino", icon: "github", url: "https://github.com/PocketNugget"),
                CreditSocial(platform: "LinkedIn", handle: "Goben Diego Constantino Aguirre", icon: "linkedin"),
            ]
        )
    ]

    private let technologies: [CreditTech] = [
        CreditTech(
            name: "Vision & CoreML",
            detail: "Detección de jugadores, porteros y balón en tiempo real.",
            systemIcon: "eye.fill",
            tint: .orange
        ),
        CreditTech(
            name: "Accelerate & K-Means",
            detail: "Clasificación automática de equipos según el color del uniforme.",
            systemIcon: "cpu.fill",
            tint: .green
        ),
        CreditTech(
            name: "SwiftUI & Liquid Glass",
            detail: "Interfaz moderna de alto contraste con soporte completo para VoiceOver.",
            systemIcon: "sparkles",
            tint: .cyan
        ),
        CreditTech(
            name: "SwiftData",
            detail: "Almacenamiento local de equipos personalizados.",
            systemIcon: "externaldrive.fill",
            tint: .indigo
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
                VStack(alignment: .leading, spacing: 24) {
                    // App Info Header
                    appHeaderCard

                    // Developers Section
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Equipo de desarrollo")
                            .font(.title3.bold())
                            .foregroundStyle(.primary)
                            .padding(.horizontal, 4)
                            .accessibilityAddTraits(.isHeader)

                        ForEach(teamMembers) { member in
                            NavigationLink(destination: CreditPersonProfileView(person: member)) {
                                memberCard(member)
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    // Technologies Section
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Tecnologías")
                            .font(.title3.bold())
                            .foregroundStyle(.primary)
                            .padding(.horizontal, 4)
                            .accessibilityAddTraits(.isHeader)

                        ForEach(technologies) { tech in
                            techCard(tech)
                        }
                    }

                    // Footer
                    Text("Hecho con ❤️ para hacer el fútbol más accesible para todas las personas.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 8)
                        .padding(.bottom, 16)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
        }
        .navigationTitle("Créditos")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var appHeaderCard: some View {
        VStack(spacing: 14) {
            ZStack {
                Image("AppLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 150)
            }
            .accessibilityHidden(true)

            VStack(spacing: 6) {
                Text("ColorScore")
                    .font(.title2.bold())
                    .foregroundStyle(.primary)

                Text("Asistencia visual en tiempo real para disfrutar partidos de fútbol con figuras y colores personalizados de alto contraste.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                
                
                HStack {
                    Image(systemName: "laurel.leading")
                        .font(.title)
                        .foregroundStyle(.tint)
                    
                    Text("1er Lugar")
                        .font(.headline)
                    
                    Image(systemName: "laurel.trailing")
                        .font(.title)
                        .foregroundStyle(.tint)

                }
                .padding(.top, 12)
                
                Text("Community Social Changemakers 2025")
                    .font(.headline)
//                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                
                Text("Categoría: Accessibilidad")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isHeader)
    }

    private func memberCard(_ member: CreditPerson) -> some View {
        HStack(spacing: 16) {
            ZStack {
                
                if let image = member.profileImage {
                    
                    Image(image)
                        .resizable()
                        .scaledToFit()
                        .clipShape(
                            Circle()
                        )
                        .frame(width: 52, height: 52)

                } else {
                    Circle()
                        .fill(.primary.opacity(0.15))
                        .frame(width: 52, height: 52)
                    
                    Image(systemName: "person.crop.circle.fill")
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(.primary)
                }
            }
            .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 4) {
                Text(member.name)
                    .font(.headline.bold())
                    .foregroundStyle(.primary)
            }

            Spacer(minLength: 0)
            
            Image(systemName: "chevron.right")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassEffect(.regular, in: .rect(cornerRadius: 20))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(member.name)")
        .accessibilityHint("Toca dos veces para ver el perfil de \(member.name).")
        .accessibilityAddTraits(.isButton)
    }

    private func techCard(_ tech: CreditTech) -> some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(tech.tint.opacity(0.15))
                    .frame(width: 48, height: 48)

                Image(systemName: tech.systemIcon)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(tech.tint)
            }
            .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 4) {
                Text(tech.name)
                    .font(.subheadline.bold())
                    .foregroundStyle(.primary)

                Text(tech.detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassEffect(.regular.tint(tech.tint.opacity(0.1)), in: .rect(cornerRadius: 18))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(tech.name): \(tech.detail)")
    }
}

@available(iOS 16.0, *)
struct CreditPersonProfileView: View {
    let person: CreditPerson

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
                VStack(alignment: .leading, spacing: 24) {
                    // Profile Header
                    profileHeader

                    // Socials Section
                    if !person.socials.isEmpty {
                        VStack(alignment: .leading, spacing: 14) {
                            Text("Redes sociales")
                                .font(.title3.bold())
                                .foregroundStyle(.primary)
                                .padding(.horizontal, 4)
                                .accessibilityAddTraits(.isHeader)

                            ForEach(person.socials) { social in
                                if let urlString = social.url, let url = URL(string: urlString) {
                                    Link(destination: url) {
                                        socialCard(social, isLink: true)
                                    }
                                    .buttonStyle(.plain)
                                } else {
                                    socialCard(social, isLink: false)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
        }
        .navigationTitle("Perfil")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var profileHeader: some View {
        VStack(spacing: 14) {
            ZStack {
                if let image = person.profileImage {
                    Image(image)
                        .resizable()
                        .scaledToFit()
                        .clipShape(Circle())
                        .frame(maxWidth: 150)
                } else {
                    ZStack {
                        Circle()
                            .fill(.primary.opacity(0.15))

                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .padding(24)
                            .foregroundStyle(.primary)
                    }
                    .frame(maxWidth: 150, maxHeight: 150)
                }
            }
            .accessibilityHidden(true)

            VStack(spacing: 6) {
                Text(person.name)
                    .font(.title2.bold())
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)

                Text(person.description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isHeader)
    }

    private func socialCard(_ social: CreditSocial, isLink: Bool) -> some View {
        HStack(spacing: 16) {
            ZStack {
                
                if let icon = social.icon {
                    Image(icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 48, height: 48)
                    
                } else {
                    Circle()
                        .fill(.primary.opacity(0.15))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: social.systemIcon)
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(.primary)
                }
            }
            .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 4) {
                Text(social.platform)
                    .font(.subheadline.bold())
                    .foregroundStyle(.primary)

                Text(social.handle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)

            if isLink {
                Image(systemName: "arrow.up.right")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassEffect(.regular.tint(.primary.opacity(0.1)), in: .rect(cornerRadius: 18))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(social.platform): \(social.handle)")
    }
}

@available(iOS 16.0, *)
#Preview {
    NavigationStack {
        CreditsView()
    }
}
