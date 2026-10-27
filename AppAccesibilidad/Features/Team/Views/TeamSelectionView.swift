//
//  TeamSelectionView.swift
//  AppAccesibilidad
//
//  Created by Maeva Mazadiego on 10/10/25.
//

import SwiftUI
import SwiftData

struct Team: Identifiable {
    let id = UUID()
    let name: String
    let imageName: String
}

struct TeamSelectionView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \CustomTeam.createdDate, order: .reverse) private var customTeams: [CustomTeam]
    @State private var showingNewTeamSheet = false
    
    var selectionManager: TeamSelectionManager
    var teamSlot: Int // 1 or 2
    
    // MARK: - América del Norte / Central
    let mexicoTeams = [
        Team(name: "Club América", imageName: "america"),
        Team(name: "Chivas de Guadalajara", imageName: "chivas"),
        Team(name: "Tigres UANL", imageName: "tigres"),
        Team(name: "Monterrey", imageName: "monterrey"),
        Team(name: "Cruz Azul", imageName: "cruzazul"),
        Team(name: "Pumas UNAM", imageName: "pumas"),
        Team(name: "Toluca", imageName: "toluca"),
        Team(name: "Santos Laguna", imageName: "santos"),
        Team(name: "León", imageName: "leon"),
        Team(name: "Atlas", imageName: "atlas")
    ]
    
    let mlsTeams = [
        Team(name: "Inter Miami CF", imageName: "intermiami"),
        Team(name: "LAFC", imageName: "lafc"),
        Team(name: "LA Galaxy", imageName: "lagalaxy"),
        Team(name: "New York City FC", imageName: "nycfc"),
        Team(name: "Atlanta United", imageName: "atlanta")
    ]
    
    let canadaTeams = [
        Team(name: "Toronto FC", imageName: "toronto"),
        Team(name: "CF Montréal", imageName: "montreal"),
        Team(name: "Vancouver Whitecaps", imageName: "vancouver"),
        Team(name: "Forge FC", imageName: "forge"),
        Team(name: "Pacific FC", imageName: "pacific")
    ]
    
    let costaRicaTeams = [
        Team(name: "Deportivo Saprissa", imageName: "saprissa"),
        Team(name: "Liga Deportiva Alajuelense", imageName: "alajuelense"),
        Team(name: "Club Sport Herediano", imageName: "herediano"),
        Team(name: "Cartaginés", imageName: "cartagines"),
        Team(name: "Pérez Zeledón", imageName: "perezZeledon")
    ]
    
    // MARK: - Europa
    let laLigaTeams = [
        Team(name: "Real Madrid CF", imageName: "realmadrid"),
        Team(name: "FC Barcelona", imageName: "barcelona"),
        Team(name: "Atlético de Madrid", imageName: "atletico"),
        Team(name: "Sevilla FC", imageName: "sevilla"),
        Team(name: "Real Sociedad", imageName: "realsociedad")
    ]
    
    let premierLeagueTeams = [
        Team(name: "Manchester City", imageName: "mancity"),
        Team(name: "Liverpool FC", imageName: "liverpool"),
        Team(name: "Arsenal FC", imageName: "arsenal"),
        Team(name: "Chelsea FC", imageName: "chelsea"),
        Team(name: "Manchester United", imageName: "manutd")
    ]
    
    let serieATeams = [
        Team(name: "Juventus", imageName: "juventus"),
        Team(name: "AC Milan", imageName: "acmilan"),
        Team(name: "Inter de Milán", imageName: "inter"),
        Team(name: "Napoli", imageName: "napoli"),
        Team(name: "AS Roma", imageName: "roma")
    ]
    
    let bundesligaTeams = [
        Team(name: "Bayern München", imageName: "bayern"),
        Team(name: "Borussia Dortmund", imageName: "dortmund"),
        Team(name: "RB Leipzig", imageName: "leipzig"),
        Team(name: "Bayer Leverkusen", imageName: "leverkusen"),
        Team(name: "Eintracht Frankfurt", imageName: "frankfurt")
    ]
    
    let ligue1Teams = [
        Team(name: "Paris Saint-Germain", imageName: "psg"),
        Team(name: "Olympique de Marseille", imageName: "marseille"),
        Team(name: "AS Monaco", imageName: "monaco"),
        Team(name: "Lyon", imageName: "lyon"),
        Team(name: "Lille", imageName: "lille")
    ]
    
    // MARK: - América del Sur
    let brasilTeams = [
        Team(name: "Flamengo", imageName: "flamengo"),
        Team(name: "Palmeiras", imageName: "palmeiras"),
        Team(name: "Corinthians", imageName: "corinthians"),
        Team(name: "São Paulo FC", imageName: "saopaulo"),
        Team(name: "Fluminense", imageName: "fluminense")
    ]
    
    let argentinaTeams = [
        Team(name: "Boca Juniors", imageName: "boca"),
        Team(name: "River Plate", imageName: "river"),
        Team(name: "Racing Club", imageName: "racing"),
        Team(name: "San Lorenzo", imageName: "sanlorenzo"),
        Team(name: "Independiente", imageName: "independiente")
    ]
    
    let colombiaTeams = [
        Team(name: "Atlético Nacional", imageName: "nacional"),
        Team(name: "Millonarios FC", imageName: "millonarios"),
        Team(name: "América de Cali", imageName: "americacali"),
        Team(name: "Deportivo Cali", imageName: "deportivocali"),
        Team(name: "Independiente Medellín", imageName: "medellin")
    ]
    
    let uruguayTeams = [
        Team(name: "Club Nacional de Football", imageName: "nacionaluy"),
        Team(name: "Peñarol", imageName: "penarol"),
        Team(name: "Defensor Sporting", imageName: "defensor"),
        Team(name: "Danubio FC", imageName: "danubio"),
        Team(name: "Liverpool Montevideo", imageName: "liverpooluy")
    ]
    
    let chileTeams = [
        Team(name: "Colo-Colo", imageName: "colocolo"),
        Team(name: "Universidad de Chile", imageName: "uchile"),
        Team(name: "Universidad Católica", imageName: "catolica"),
        Team(name: "Unión Española", imageName: "unionespanola"),
        Team(name: "Audax Italiano", imageName: "audax")
    ]
    
    // MARK: - Asia
    let j1LeagueTeams = [
        Team(name: "Kawasaki Frontale", imageName: "kawasaki"),
        Team(name: "Yokohama F. Marinos", imageName: "yokohama"),
        Team(name: "Urawa Red Diamonds", imageName: "urawa"),
        Team(name: "Kashima Antlers", imageName: "kashima"),
        Team(name: "FC Tokyo", imageName: "fctokyo")
    ]
    
    let saudiProLeagueTeams = [
        Team(name: "Al Hilal", imageName: "alhilal"),
        Team(name: "Al Nassr", imageName: "alnassr"),
        Team(name: "Al Ittihad", imageName: "alittihad"),
        Team(name: "Al Ahli", imageName: "alahli"),
        Team(name: "Al Shabab", imageName: "alshabab")
    ]
    
    let kLeagueTeams = [
        Team(name: "Jeonbuk Hyundai Motors", imageName: "jeonbuk"),
        Team(name: "Ulsan Hyundai", imageName: "ulsan"),
        Team(name: "Pohang Steelers", imageName: "pohang"),
        Team(name: "FC Seoul", imageName: "seoul"),
        Team(name: "Suwon Samsung Bluewings", imageName: "suwon")
    ]
    
    // MARK: - África
    let egyptTeams = [
        Team(name: "Al Ahly", imageName: "alahlyegypt"),
        Team(name: "Zamalek SC", imageName: "zamalek"),
        Team(name: "Pyramids FC", imageName: "pyramids"),
        Team(name: "Al Masry", imageName: "almasry"),
        Team(name: "Smouha SC", imageName: "smouha")
    ]
    
    let moroccoTeams = [
        Team(name: "Wydad Casablanca", imageName: "wydad"),
        Team(name: "Raja Casablanca", imageName: "raja"),
        Team(name: "FUS Rabat", imageName: "fus"),
        Team(name: "RS Berkane", imageName: "berkane"),
        Team(name: "AS FAR Rabat", imageName: "far")
    ]
    
    // MARK: - Oceanía
    let aLeagueTeams = [
        Team(name: "Sydney FC", imageName: "sydney"),
        Team(name: "Melbourne City", imageName: "melbournecity"),
        Team(name: "Melbourne Victory", imageName: "victory"),
        Team(name: "Brisbane Roar", imageName: "brisbane"),
        Team(name: "Perth Glory", imageName: "perth")
    ]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Selecciona tu equipo")
                        .font(.largeTitle.bold())
                        .accessibilityAddTraits(.isHeader)
                    
                    Text("Configura tu partido")
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal)
                .padding(.top, 16)
                
                // MARK: - Custom Teams Section
                if !customTeams.isEmpty {
                    customTeamsSection()
                }
                
                // MARK: - América del Norte / Central
                continentHeader("🌎 América del Norte / Central")
                
                leagueSection(title: "🇲🇽 México – Liga MX", teams: mexicoTeams, color: .green)
                leagueSection(title: "🇺🇸 Estados Unidos – MLS", teams: mlsTeams, color: .blue)
                leagueSection(title: "🇨🇦 Canadá", teams: canadaTeams, color: .red)
                leagueSection(title: "🇨🇷 Costa Rica – Primera División", teams: costaRicaTeams, color: .orange)
                
                // MARK: - Europa
                continentHeader("🌍 Europa")
                
                leagueSection(title: "🇪🇸 España – LaLiga", teams: laLigaTeams, color: .orange)
                leagueSection(title: "🏴 Inglaterra – Premier League", teams: premierLeagueTeams, color: .purple)
                leagueSection(title: "🇮🇹 Italia – Serie A", teams: serieATeams, color: .blue)
                leagueSection(title: "🇩🇪 Alemania – Bundesliga", teams: bundesligaTeams, color: .red)
                leagueSection(title: "🇫🇷 Francia – Ligue 1", teams: ligue1Teams, color: .blue)
                
                // MARK: - América del Sur
                continentHeader("🌎 América del Sur")
                
                leagueSection(title: "🇧🇷 Brasil – Serie A", teams: brasilTeams, color: .green)
                leagueSection(title: "🇦🇷 Argentina – Liga Profesional", teams: argentinaTeams, color: .cyan)
                leagueSection(title: "🇨🇴 Colombia – Primera A", teams: colombiaTeams, color: .yellow)
                leagueSection(title: "🇺🇾 Uruguay – Primera División", teams: uruguayTeams, color: .blue)
                leagueSection(title: "🇨🇱 Chile – Primera División", teams: chileTeams, color: .red)
                
                // MARK: - Asia
                continentHeader("🌏 Asia")
                
                leagueSection(title: "🇯🇵 Japón – J1 League", teams: j1LeagueTeams, color: .red)
                leagueSection(title: "🇸🇦 Arabia Saudita – Pro League", teams: saudiProLeagueTeams, color: .green)
                leagueSection(title: "🇰🇷 Corea del Sur – K League 1", teams: kLeagueTeams, color: .blue)
                
                // MARK: - África
                continentHeader("🌍 África")
                
                leagueSection(title: "🇪🇬 Egipto – Premier League", teams: egyptTeams, color: .red)
                leagueSection(title: "🇲🇦 Marruecos – Botola Pro", teams: moroccoTeams, color: .green)
                
                // MARK: - Oceanía
                continentHeader("🌏 Oceanía")
                
                leagueSection(title: "🇦🇺 Australia – A-League", teams: aLeagueTeams, color: .yellow)
            }
            .padding(.vertical)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showingNewTeamSheet = true
                }) {
                    Image(systemName: "plus")
                        .font(.title3.weight(.medium))
                        .foregroundStyle(.primary)
                        .frame(minWidth: 44, minHeight: 44)
                }
                .accessibilityLabel("Crear nuevo equipo")
                .accessibilityHint("Abre el formulario para personalizar y agregar un equipo")
            }
        }
        .sheet(isPresented: $showingNewTeamSheet) {
            NewTeamView()
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
    }
    
    // MARK: - Helper Views
    private func continentHeader(_ title: String) -> some View {
        Text(title)
            .font(.title.bold())
            .foregroundStyle(.primary)
            .padding(.horizontal)
            .padding(.top, 8)
            .accessibilityAddTraits(.isHeader)
    }
    
    private func leagueSection(title: String, teams: [Team], color: Color) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.title3.weight(.semibold))
                .foregroundStyle(.primary)
                .padding(.horizontal)
                .accessibilityAddTraits(.isHeader)
            
            TeamRowComponentView(teams: teams, sectionColor: color) { team in
                selectTeam(team)
            }
        }
    }
    
    // MARK: - Custom Teams Section
    @ViewBuilder
    private func customTeamsSection() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("⚽️ Mis Equipos Creados")
                    .font(.title.bold())
                    .foregroundStyle(.primary)
                    .accessibilityAddTraits(.isHeader)
                
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 8)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(customTeams) { team in
                        CustomTeamCard(team: team, modelContext: modelContext) {
                            selectCustomTeam(team)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    // MARK: - Selection Handlers
    private func selectTeam(_ team: Team) {
        let teamColor = TeamColors.color(for: team.name)
        let selectedTeam = SelectedTeamData(name: team.name, imageName: team.imageName, teamColor: teamColor)
        
        if teamSlot == 1 {
            selectionManager.team1 = selectedTeam
        } else {
            selectionManager.team2 = selectedTeam
        }
        
        dismiss()
    }
    
    private func selectCustomTeam(_ team: CustomTeam) {
        let selectedTeam = SelectedTeamData(customTeam: team)
        
        if teamSlot == 1 {
            selectionManager.team1 = selectedTeam
        } else {
            selectionManager.team2 = selectedTeam
        }
        
        dismiss()
    }
}

// MARK: - Custom Team Card
struct CustomTeamCard: View {
    let team: CustomTeam
    var modelContext: ModelContext
    var onTeamSelected: (() -> Void)? = nil
    @State private var showDeleteAlert = false
    
    var body: some View {
        VStack(spacing: 8) {
            Button(action: {
                onTeamSelected?()
            }) {
                VStack(spacing: 12) {
                    // Logo with color background
                    ZStack {
                        // Team color background
                        RoundedRectangle(cornerRadius: 12)
                            .fill(team.teamColor)
                            .frame(width: 140, height: 140)
                            .overlay(
                                // Subtle gradient for depth
                                LinearGradient(
                                    colors: [
                                        Color.black.opacity(0.1),
                                        Color.black.opacity(0.2)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                        
                        // Logo overlay
                        if let imageData = team.logoImageData,
                           let uiImage = UIImage(data: imageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                                .shadow(color: Color.black.opacity(0.3), radius: 4, x: 0, y: 2)
                                .accessibilityHidden(true)
                        } else {
                            Image(systemName: "shield.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 60, height: 60)
                                .foregroundColor(.white)
                                .shadow(color: Color.black.opacity(0.3), radius: 4, x: 0, y: 2)
                                .accessibilityHidden(true)
                        }
                    }
                    .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
                    
                    // Team Info
                    VStack(spacing: 4) {
                        Text(team.name)
                            .font(.footnote.weight(.medium))
                            .lineLimit(2)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.primary)
                        
                        HStack(spacing: 4) {
                            Text(team.country)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                            
                            Text("•")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                            
                            Text(team.division)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }
                    }
                    .frame(width: 140)
                }
            }
            .buttonStyle(.plain)
            
            // Delete button with 44x44 minimum touch target
            Button(action: {
                showDeleteAlert = true
            }) {
                Image(systemName: "trash")
                    .font(.subheadline)
                    .foregroundStyle(.red)
                    .frame(width: 36, height: 36)
                    .background(Color(uiColor: .systemGray6))
                    .clipShape(Circle())
                    .frame(minWidth: 44, minHeight: 44)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Eliminar \(team.name)")
            .accessibilityHint("Muestra una alerta para confirmar la eliminación del equipo")
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(team.name), \(team.country), \(team.division)")
        .accessibilityHint("Toca dos veces para seleccionar este equipo")
        .accessibilityAddTraits(.isButton)
        .accessibilityAction {
            onTeamSelected?()
        }
        .accessibilityAction(named: "Eliminar equipo") {
            showDeleteAlert = true
        }
        .alert("Eliminar equipo", isPresented: $showDeleteAlert) {
            Button("Cancelar", role: .cancel) { }
            Button("Eliminar", role: .destructive) {
                deleteTeam()
            }
        } message: {
            Text("¿Estás seguro de que quieres eliminar \(team.name)?")
        }
    }
    
    private func deleteTeam() {
        modelContext.delete(team)
        try? modelContext.save()
    }
}

struct TeamSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        TeamSelectionView(selectionManager: TeamSelectionManager(), teamSlot: 1)
    }
}
