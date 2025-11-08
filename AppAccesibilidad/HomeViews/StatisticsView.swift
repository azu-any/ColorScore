//
//  StatisticsView.swift
//  AppAccesibilidad
//
//  Created by Maeva Mazadiego on 07/11/25.
//

import SwiftUI
import Charts

struct MatchStatistic: Identifiable {
    let id = UUID()
    let teamLogo: String
    let teamName: String
    let teamScore: Int
    let opponentLogo: String
    let opponentName: String
    let opponentScore: Int
    let date: Date
    let location: String
    let goalScorers: [String]
    let assists: [String]
    var result: MatchResult {
        if teamScore > opponentScore { return .win }
        else if teamScore < opponentScore { return .loss }
        else { return .draw }
    }
}

enum MatchResult {
    case win, draw, loss
}

struct TeamStatistics: Identifiable {
    let id = UUID()
    let teamName: String
    let teamColor: Color
    let teamLogo: String
    let matches: [MatchStatistic]
    
    var totalMatches: Int { matches.count }
    var wins: Int { matches.filter { $0.result == .win }.count }
    var draws: Int { matches.filter { $0.result == .draw }.count }
    var losses: Int { matches.filter { $0.result == .loss }.count }
    var goalsScored: Int { matches.reduce(0) { $0 + $1.teamScore } }
    var goalsConceded: Int { matches.reduce(0) { $0 + $1.opponentScore } }
    var goalDifference: Int { goalsScored - goalsConceded }
    var points: Int { (wins * 3) + draws }
    var winPercentage: Double { totalMatches > 0 ? Double(wins) / Double(totalMatches) * 100 : 0 }
}

enum StatisticsFilter: String, CaseIterable {
    case all = "Todos"
    case last5 = "Últimos 5"
    case last10 = "Últimos 10"
    case home = "Local"
    case away = "Visitante"
}

enum StatisticsView: String, CaseIterable {
    case overview = "Resumen"
    case matches = "Partidos"
    case performance = "Rendimiento"
    case players = "Jugadores"
}

@available(iOS 16.0, *)
struct StatisticsMainView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedTeam: TeamStatistics?
    @State private var selectedFilter: StatisticsFilter = .all
    @State private var selectedView: StatisticsView = .overview
    @State private var showTeamSelector = false
    
    let teamStatistics: [TeamStatistics] = [
        TeamStatistics(
            teamName: "Real Madrid",
            teamColor: Color(red: 0.0, green: 0.2, blue: 0.5),
            teamLogo: "crown.fill",
            matches: [
                MatchStatistic(teamLogo: "crown.fill", teamName: "Real Madrid", teamScore: 3, opponentLogo: "shield.fill", opponentName: "Barcelona", opponentScore: 1, date: Date().addingTimeInterval(-86400 * 7), location: "Santiago Bernabéu", goalScorers: ["Benzema", "Vinicius Jr", "Modric"], assists: ["Kroos", "Vinicius Jr"]),
                MatchStatistic(teamLogo: "crown.fill", teamName: "Real Madrid", teamScore: 2, opponentLogo: "star.fill", opponentName: "Atlético", opponentScore: 2, date: Date().addingTimeInterval(-86400 * 14), location: "Wanda Metropolitano", goalScorers: ["Benzema", "Rodrygo"], assists: ["Modric", "Carvajal"]),
                MatchStatistic(teamLogo: "crown.fill", teamName: "Real Madrid", teamScore: 4, opponentLogo: "flag.fill", opponentName: "Sevilla", opponentScore: 0, date: Date().addingTimeInterval(-86400 * 21), location: "Santiago Bernabéu", goalScorers: ["Benzema (2)", "Vinicius Jr", "Asensio"], assists: ["Kroos", "Modric", "Rodrygo"]),
                MatchStatistic(teamLogo: "crown.fill", teamName: "Real Madrid", teamScore: 1, opponentLogo: "circle.fill", opponentName: "Valencia", opponentScore: 3, date: Date().addingTimeInterval(-86400 * 28), location: "Mestalla", goalScorers: ["Rodrygo"], assists: ["Benzema"]),
                MatchStatistic(teamLogo: "crown.fill", teamName: "Real Madrid", teamScore: 5, opponentLogo: "diamond.fill", opponentName: "Real Sociedad", opponentScore: 1, date: Date().addingTimeInterval(-86400 * 35), location: "Santiago Bernabéu", goalScorers: ["Benzema (2)", "Vinicius Jr (2)", "Modric"], assists: ["Kroos (2)", "Carvajal"])
            ]
        ),
        TeamStatistics(
            teamName: "Barcelona",
            teamColor: Color(red: 0.6, green: 0.1, blue: 0.2),
            teamLogo: "shield.fill",
            matches: [
                MatchStatistic(teamLogo: "shield.fill", teamName: "Barcelona", teamScore: 5, opponentLogo: "star.fill", opponentName: "Espanyol", opponentScore: 2, date: Date().addingTimeInterval(-86400 * 6), location: "Camp Nou", goalScorers: ["Lewandowski (3)", "Raphinha", "Gavi"], assists: ["Pedri (2)", "Dembélé"]),
                MatchStatistic(teamLogo: "shield.fill", teamName: "Barcelona", teamScore: 3, opponentLogo: "flag.fill", opponentName: "Villarreal", opponentScore: 3, date: Date().addingTimeInterval(-86400 * 13), location: "La Cerámica", goalScorers: ["Lewandowski (2)", "Raphinha"], assists: ["Pedri", "De Jong"]),
                MatchStatistic(teamLogo: "shield.fill", teamName: "Barcelona", teamScore: 2, opponentLogo: "crown.fill", opponentName: "Real Madrid", opponentScore: 1, date: Date().addingTimeInterval(-86400 * 20), location: "Camp Nou", goalScorers: ["Lewandowski", "Pedri"], assists: ["Raphinha", "Gavi"]),
                MatchStatistic(teamLogo: "shield.fill", teamName: "Barcelona", teamScore: 4, opponentLogo: "circle.fill", opponentName: "Getafe", opponentScore: 2, date: Date().addingTimeInterval(-86400 * 27), location: "Camp Nou", goalScorers: ["Lewandowski (2)", "Dembélé", "Ferran"], assists: ["Pedri", "Raphinha", "De Jong"])
            ]
        ),
        TeamStatistics(
            teamName: "Atlético Madrid",
            teamColor: Color(red: 0.8, green: 0.2, blue: 0.2),
            teamLogo: "star.fill",
            matches: [
                MatchStatistic(teamLogo: "star.fill", teamName: "Atlético", teamScore: 2, opponentLogo: "flag.fill", opponentName: "Betis", opponentScore: 0, date: Date().addingTimeInterval(-86400 * 5), location: "Wanda Metropolitano", goalScorers: ["Griezmann", "Morata"], assists: ["Koke", "Carrasco"]),
                MatchStatistic(teamLogo: "star.fill", teamName: "Atlético", teamScore: 1, opponentLogo: "crown.fill", opponentName: "Real Madrid", opponentScore: 1, date: Date().addingTimeInterval(-86400 * 12), location: "Wanda Metropolitano", goalScorers: ["Griezmann"], assists: ["Llorente"]),
                MatchStatistic(teamLogo: "star.fill", teamName: "Atlético", teamScore: 3, opponentLogo: "diamond.fill", opponentName: "Celta", opponentScore: 2, date: Date().addingTimeInterval(-86400 * 19), location: "Balaídos", goalScorers: ["Morata", "Griezmann", "Correa"], assists: ["Koke", "Carrasco"])
            ]
        )
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                // Liquid Glass background with gradient
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
                
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        Button(action: {
                            if selectedTeam != nil {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                    selectedTeam = nil
                                    selectedView = .overview
                                }
                            } else {
                                dismiss()
                            }
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.title3.bold())
                                .foregroundColor(.primary)
                                .padding(10)
                                .background(
                                    Circle()
                                        .fill(.ultraThinMaterial)
                                )
                                .overlay(
                                    Circle()
                                        .strokeBorder(.white.opacity(0.25), lineWidth: 1)
                                )
                                .shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 3)
                        }
                        
                        Spacer()
                        
                        if selectedTeam != nil {
                            Button(action: {
                                showTeamSelector.toggle()
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "line.3.horizontal.decrease.circle.fill")
                                        .font(.title3)
                                    Text("Filtros")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 18)
                                .padding(.vertical, 10)
                                .background(
                                    Capsule()
                                        .fill(selectedTeam?.teamColor ?? .blue)
                                )
                                .overlay(
                                    Capsule()
                                        .strokeBorder(.white.opacity(0.3), lineWidth: 1)
                                )
                                .shadow(color: (selectedTeam?.teamColor ?? .blue).opacity(0.3), radius: 8, x: 0, y: 4)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                    
                    // Title
                    HStack {
                        Text("Estadísticas")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.primary)
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    .padding(.bottom, 16)
                    
                    // Team Selector or Content
                    if selectedTeam == nil {
                        TeamSelectorView(teams: teamStatistics, selectedTeam: $selectedTeam)
                    } else {
                        VStack(spacing: 0) {
                            // View Tabs
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(StatisticsView.allCases, id: \.self) { view in
                                        Button(action: {
                                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                selectedView = view
                                            }
                                        }) {
                                            Text(view.rawValue)
                                                .font(.subheadline)
                                                .fontWeight(.semibold)
                                                .foregroundColor(selectedView == view ? .white : .primary)
                                                .padding(.horizontal, 20)
                                                .padding(.vertical, 10)
                                                .background(
                                                    Group {
                                                        if selectedView == view {
                                                            Capsule()
                                                                .fill(selectedTeam?.teamColor ?? .blue)
                                                        } else {
                                                            Capsule()
                                                                .fill(.ultraThinMaterial)
                                                        }
                                                    }
                                                )
                                                .overlay(
                                                    Capsule()
                                                        .strokeBorder(
                                                            selectedView == view ?
                                                                .white.opacity(0.3) : .white.opacity(0.15),
                                                            lineWidth: 1
                                                        )
                                                )
                                                .shadow(
                                                    color: selectedView == view ?
                                                        (selectedTeam?.teamColor ?? .blue).opacity(0.3) : .clear,
                                                    radius: 6,
                                                    x: 0,
                                                    y: 3
                                                )
                                        }
                                    }
                                }
                                .padding(.horizontal)
                                .padding(.vertical, 12)
                            }
                            
                            // Content based on selected view
                            ScrollView {
                                if let team = selectedTeam {
                                    switch selectedView {
                                    case .overview:
                                        OverviewView(team: team, filter: selectedFilter)
                                    case .matches:
                                        MatchesListView(team: team, filter: selectedFilter)
                                    case .performance:
                                        PerformanceView(team: team)
                                    case .players:
                                        PlayersStatsView(team: team)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showTeamSelector) {
            FilterSheet(selectedFilter: $selectedFilter, selectedTeam: $selectedTeam, teams: teamStatistics)
        }
    }
}

// MARK: - Liquid Glass Card Component
@available(iOS 18.0, *)
struct LiquidGlassCard<Content: View>: View {
    let content: Content
    let cornerRadius: CGFloat
    let tintColor: Color?
    
    init(cornerRadius: CGFloat = 20, tintColor: Color? = nil, @ViewBuilder content: () -> Content) {
        self.cornerRadius = cornerRadius
        self.tintColor = tintColor
        self.content = content()
    }
    
    var body: some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(.ultraThinMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(.white.opacity(0.25), lineWidth: 1)
            )
            .glassEffect(
                .regular
                    .tint(tintColor?.opacity(0.2) ?? .clear)
                    .interactive(),
                in: .rect(cornerRadius: cornerRadius)
            )
            .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 6)
    }
}

// MARK: - Fallback Glass Card for iOS 16-17
@available(iOS 16.0, *)
struct GlassCard<Content: View>: View {
    let content: Content
    let cornerRadius: CGFloat
    let tintColor: Color?
    
    init(cornerRadius: CGFloat = 20, tintColor: Color? = nil, @ViewBuilder content: () -> Content) {
        self.cornerRadius = cornerRadius
        self.tintColor = tintColor
        self.content = content()
    }
    
    var body: some View {
        if #available(iOS 18.0, *) {
            LiquidGlassCard(cornerRadius: cornerRadius, tintColor: tintColor) {
                content
            }
        } else {
            content
                .background(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                                .strokeBorder(.white.opacity(0.2), lineWidth: 1)
                        )
                        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
                )
        }
    }
}

// MARK: - Interactive Glass Button Style
@available(iOS 16.0, *)
struct GlassButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: - Team Selector View
struct TeamSelectorView: View {
    let teams: [TeamStatistics]
    @Binding var selectedTeam: TeamStatistics?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("Selecciona un equipo")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                    .padding(.top, 20)
                
                ForEach(teams) { team in
                    Button(action: {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            selectedTeam = team
                        }
                    }) {
                        GlassCard(cornerRadius: 20, tintColor: team.teamColor) {
                            HStack(spacing: 16) {
                                // Team Logo
                                ZStack {
                                    Circle()
                                        .fill(team.teamColor.opacity(0.15))
                                        .frame(width: 70, height: 70)
                                        .overlay(
                                            Circle()
                                                .stroke(team.teamColor.opacity(0.3), lineWidth: 2)
                                        )
                                    
                                    Image(systemName: team.teamLogo)
                                        .font(.system(size: 32))
                                        .foregroundColor(team.teamColor)
                                }
                                
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(team.teamName)
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.primary)
                                    
                                    HStack(spacing: 16) {
                                        Label("\(team.totalMatches) PJ", systemImage: "sportscourt.fill")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        
                                        Label("\(team.wins) G", systemImage: "checkmark.circle.fill")
                                            .font(.caption)
                                            .foregroundColor(.green)
                                        
                                        Label("\(team.points) Pts", systemImage: "star.fill")
                                            .font(.caption)
                                            .foregroundColor(.orange)
                                    }
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.secondary)
                                    .font(.title3)
                                    .padding(8)
                                    .background(
                                        Circle()
                                            .fill(.ultraThinMaterial)
                                    )
                                    .overlay(
                                        Circle()
                                            .strokeBorder(.white.opacity(0.2), lineWidth: 1)
                                    )
                            }
                            .padding(20)
                        }
                    }
                    .buttonStyle(GlassButtonStyle())
                }
            }
            .padding()
        }
    }
}

// MARK: - Overview View
struct OverviewView: View {
    let team: TeamStatistics
    let filter: StatisticsFilter
    
    var body: some View {
        VStack(spacing: 20) {
            // Team Header Card
            GlassCard(cornerRadius: 24, tintColor: team.teamColor) {
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(team.teamColor.opacity(0.15))
                            .frame(width: 100, height: 100)
                            .overlay(
                                Circle()
                                    .stroke(team.teamColor.opacity(0.3), lineWidth: 2)
                            )
                        
                        Image(systemName: team.teamLogo)
                            .font(.system(size: 48))
                            .foregroundColor(team.teamColor)
                    }
                    
                    Text(team.teamName)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    HStack(spacing: 32) {
                        VStack(spacing: 4) {
                            Text("\(team.totalMatches)")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            Text("Partidos")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        VStack(spacing: 4) {
                            Text("\(team.points)")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.orange)
                        Text("Puntos")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        VStack(spacing: 4) {
                            Text("\(team.wins)")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                            Text("Victorias")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 8)
                }
                .padding(24)
            }
            .padding(.horizontal)
            .padding(.top, 8)
            
            // Statistics Grid
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                GlassStatCard(
                    title: "Goles a favor",
                    value: "\(team.goalsScored)",
                    icon: "soccerball.circle.fill",
                    color: .green
                )
                GlassStatCard(
                    title: "Goles en contra",
                    value: "\(team.goalsConceded)",
                    icon: "hand.raised.circle.fill",
                    color: .red
                )
                GlassStatCard(
                    title: "Diferencia",
                    value: team.goalDifference >= 0 ? "+\(team.goalDifference)" : "\(team.goalDifference)",
                    icon: "arrow.up.arrow.down.circle.fill",
                    color: team.goalDifference >= 0 ? .green : .red
                )
                GlassStatCard(
                    title: "% Victorias",
                    value: String(format: "%.1f%%", team.winPercentage),
                    icon: "chart.line.uptrend.xyaxis.circle.fill",
                    color: .blue
                )
            }
            .padding(.horizontal)
            
            // Form Guide
            GlassCard(cornerRadius: 24, tintColor: team.teamColor) {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Últimos resultados")
                        .font(.headline)
                        .foregroundColor(.primary)
                        .padding(.horizontal)
                        .padding(.top)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(team.matches.suffix(5).reversed()) { match in
                                VStack(spacing: 8) {
                                    ZStack {
                                        Circle()
                                            .fill(resultColor(for: match.result).opacity(0.15))
                                            .frame(width: 50, height: 50)
                                            .overlay(
                                                Circle()
                                                    .stroke(resultColor(for: match.result).opacity(0.3), lineWidth: 2)
                                            )
                                        
                                        Text(resultLetter(for: match.result))
                                            .font(.headline)
                                            .fontWeight(.bold)
                                            .foregroundColor(resultColor(for: match.result))
                                    }
                                    
                                    Text("\(match.teamScore)-\(match.opponentScore)")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.primary)
                                    
                                    Text(match.opponentName)
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                        .lineLimit(1)
                                        .frame(width: 70)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom)
                }
            }
            .padding(.horizontal)
            
            // Win/Draw/Loss Distribution
            GlassCard(cornerRadius: 24, tintColor: team.teamColor) {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Distribución de resultados")
                        .font(.headline)
                        .foregroundColor(.primary)
                        .padding(.horizontal)
                        .padding(.top)
                    
                    HStack(spacing: 0) {
                        if team.wins > 0 {
                            Rectangle()
                                .fill(Color.green)
                                .frame(width: CGFloat(team.wins) / CGFloat(team.totalMatches) * (UIScreen.main.bounds.width - 96))
                        }
                        
                        if team.draws > 0 {
                            Rectangle()
                                .fill(Color.orange)
                                .frame(width: CGFloat(team.draws) / CGFloat(team.totalMatches) * (UIScreen.main.bounds.width - 96))
                        }
                        
                        if team.losses > 0 {
                            Rectangle()
                                .fill(Color.red)
                                .frame(width: CGFloat(team.losses) / CGFloat(team.totalMatches) * (UIScreen.main.bounds.width - 96))
                        }
                    }
                    .frame(height: 12)
                    .cornerRadius(6)
                    .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 8) {
                            Circle()
                                .fill(Color.green)
                                .frame(width: 12, height: 12)
                            Text("Victorias: \(team.wins)")
                                .font(.caption)
                                .foregroundColor(.primary)
                        }
                        
                        HStack(spacing: 8) {
                            Circle()
                                .fill(Color.orange)
                                .frame(width: 12, height: 12)
                            Text("Empates: \(team.draws)")
                                .font(.caption)
                                .foregroundColor(.primary)
                        }
                        
                        HStack(spacing: 8) {
                            Circle()
                                .fill(Color.red)
                                .frame(width: 12, height: 12)
                            Text("Derrotas: \(team.losses)")
                                .font(.caption)
                                .foregroundColor(.primary)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                }
            }
            .padding(.horizontal)
            
            Spacer(minLength: 20)
        }
        .padding(.vertical)
    }
    
    func resultColor(for result: MatchResult) -> Color {
        switch result {
        case .win: return .green
        case .draw: return .orange
        case .loss: return .red
        }
    }
    
    func resultLetter(for result: MatchResult) -> String {
        switch result {
        case .win: return "V"
        case .draw: return "E"
        case .loss: return "D"
        }
    }
}

// MARK: - Glass Stat Card
struct GlassStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        GlassCard(cornerRadius: 20, tintColor: color) {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: icon)
                        .font(.system(size: 24))
                        .foregroundColor(color)
                }
                
                Text(value)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(20)
        }
    }
}

// MARK: - Matches List View
struct MatchesListView: View {
    let team: TeamStatistics
    let filter: StatisticsFilter
    
    var body: some View {
        VStack(spacing: 16) {
            ForEach(team.matches) { match in
                GlassMatchDetailCard(match: match, teamColor: team.teamColor)
            }
        }
        .padding()
    }
}

struct GlassMatchDetailCard: View {
    let match: MatchStatistic
    let teamColor: Color
    
    var body: some View {
        GlassCard(cornerRadius: 24, tintColor: teamColor) {
            VStack(spacing: 0) {
                // Match Header with gradient
                ZStack {
                    teamColor.opacity(0.15)
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(match.location)
                                .font(.caption)
                                .foregroundColor(.primary)
                            
                            Text(match.date, style: .date)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        // Result badge
                        Text(match.result == .win ? "Victoria" : match.result == .draw ? "Empate" : "Derrota")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(match.result == .win ? Color.green : match.result == .draw ? Color.orange : Color.red)
                            )
                    }
                    .padding()
                }
                .cornerRadius(24, corners: [.topLeft, .topRight])
                
                // Score Section
                HStack(spacing: 20) {
                    // Home Team
                    VStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(Color.gray.opacity(0.1))
                                .frame(width: 60, height: 60)
                                .overlay(
                                    Circle()
                                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                )
                            
                            Image(systemName: match.teamLogo)
                                .font(.title2)
                                .foregroundColor(teamColor)
                        }
                        
                        Text(match.teamName)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                            .lineLimit(1)
                            .frame(width: 80)
                    }
                    
                    // Score
                    HStack(spacing: 12) {
                        Text("\(match.teamScore)")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Text("-")
                            .font(.title)
                            .foregroundColor(.secondary)
                        
                        Text("\(match.opponentScore)")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.primary)
                    }
                    
                    // Away Team
                    VStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(Color.gray.opacity(0.1))
                                .frame(width: 60, height: 60)
                                .overlay(
                                    Circle()
                                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                )
                            
                            Image(systemName: match.opponentLogo)
                                .font(.title2)
                                .foregroundColor(.secondary)
                        }
                        
                        Text(match.opponentName)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                            .lineLimit(1)
                            .frame(width: 80)
                    }
                }
                .padding(.vertical, 20)
                
                Divider()
                    .background(Color.gray.opacity(0.3))
                
                // Goal Scorers
                VStack(alignment: .leading, spacing: 8) {
                    if !match.goalScorers.isEmpty {
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "soccerball.circle.fill")
                                .foregroundColor(.green)
                                .font(.caption)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Goleadores:")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                
                                Text(match.goalScorers.joined(separator: ", "))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    if !match.assists.isEmpty {
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "figure.run.circle.fill")
                                .foregroundColor(.blue)
                                .font(.caption)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Asistencias:")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                
                                Text(match.assists.joined(separator: ", "))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            }
        }
    }
}

// MARK: - Performance View
struct PerformanceView: View {
    let team: TeamStatistics
    
    var body: some View {
        VStack(spacing: 20) {
            // Goals Chart
            GlassCard(cornerRadius: 24, tintColor: team.teamColor) {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Evolución de goles")
                        .font(.headline)
                        .foregroundColor(.primary)
                        .padding(.horizontal)
                        .padding(.top)
                    
                    Chart {
                        ForEach(Array(team.matches.enumerated()), id: \.element.id) { index, match in
                            LineMark(
                                x: .value("Partido", index + 1),
                                y: .value("Goles", match.teamScore)
                            )
                            .foregroundStyle(Color.green)
                            .symbol(.circle)
                            .lineStyle(StrokeStyle(lineWidth: 3))
                            
                            LineMark(
                                x: .value("Partido", index + 1),
                                y: .value("Goles en contra", match.opponentScore)
                            )
                            .foregroundStyle(Color.red)
                            .symbol(.circle)
                            .lineStyle(StrokeStyle(lineWidth: 3))
                        }
                    }
                    .chartXAxis {
                        AxisMarks(values: .automatic) { _ in
                            AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                                .foregroundStyle(Color.gray.opacity(0.2))
                            AxisValueLabel()
                                .foregroundStyle(Color.secondary)
                        }
                    }
                    .chartYAxis {
                        AxisMarks(values: .automatic) { _ in
                            AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                                .foregroundStyle(Color.gray.opacity(0.2))
                            AxisValueLabel()
                                .foregroundStyle(Color.secondary)
                        }
                    }
                    .frame(height: 200)
                    .padding()
                    
                    HStack(spacing: 24) {
                        HStack(spacing: 8) {
                            Circle()
                                .fill(Color.green)
                                .frame(width: 12, height: 12)
                            Text("Goles a favor")
                                .font(.caption)
                                .foregroundColor(.primary)
                        }
                        
                        HStack(spacing: 8) {
                            Circle()
                                .fill(Color.red)
                                .frame(width: 12, height: 12)
                            Text("Goles en contra")
                                .font(.caption)
                                .foregroundColor(.primary)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
            
            // Average Stats
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                GlassStatCard(
                    title: "Promedio goles favor",
                    value: String(format: "%.1f", Double(team.goalsScored) / Double(team.totalMatches)),
                    icon: "plus.circle.fill",
                    color: .green
                )
                
                GlassStatCard(
                    title: "Promedio goles contra",
                    value: String(format: "%.1f", Double(team.goalsConceded) / Double(team.totalMatches)),
                    icon: "minus.circle.fill",
                    color: .red
                )
                
                GlassStatCard(
                    title: "Puntos por partido",
                    value: String(format: "%.1f", Double(team.points) / Double(team.totalMatches)),
                    icon: "star.circle.fill",
                    color: .orange
                )
                
                GlassStatCard(
                    title: "Racha actual",
                    value: getCurrentStreak(matches: team.matches),
                    icon: "flame.fill",
                    color: .purple
                )
            }
            .padding(.horizontal)
            
            Spacer(minLength: 20)
        }
        .padding(.vertical)
    }
    
    func getCurrentStreak(matches: [MatchStatistic]) -> String {
        guard let lastMatch = matches.last else { return "0" }
        
        var streak = 0
        let lastResult = lastMatch.result
        
        for match in matches.reversed() {
            if match.result == lastResult {
                streak += 1
            } else {
                break
            }
        }
        
        let letter = lastResult == .win ? "V" : lastResult == .draw ? "E" : "D"
        return "\(streak)\(letter)"
    }
}

// MARK: - Players Stats View
struct PlayersStatsView: View {
    let team: TeamStatistics
    
    var topScorers: [(name: String, goals: Int)] {
        var scorerCounts: [String: Int] = [:]
        
        for match in team.matches {
            for scorer in match.goalScorers {
                let cleanName = scorer.replacingOccurrences(of: " (2)", with: "")
                    .replacingOccurrences(of: " (3)", with: "")
                
                if scorer.contains("(2)") {
                    scorerCounts[cleanName, default: 0] += 2
                } else if scorer.contains("(3)") {
                    scorerCounts[cleanName, default: 0] += 3
                } else {
                    scorerCounts[cleanName, default: 0] += 1
                }
            }
        }
        
        return scorerCounts.map { (name: $0.key, goals: $0.value) }
            .sorted { $0.goals > $1.goals }
            .prefix(10)
            .map { $0 }
    }
    
    var topAssisters: [(name: String, assists: Int)] {
        var assistCounts: [String: Int] = [:]
        
        for match in team.matches {
            for assister in match.assists {
                let cleanName = assister.replacingOccurrences(of: " (2)", with: "")
                
                if assister.contains("(2)") {
                    assistCounts[cleanName, default: 0] += 2
                } else {
                    assistCounts[cleanName, default: 0] += 1
                }
            }
        }
        
        return assistCounts.map { (name: $0.key, assists: $0.value) }
            .sorted { $0.assists > $1.assists }
            .prefix(10)
            .map { $0 }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Top Scorers
            GlassCard(cornerRadius: 24, tintColor: team.teamColor) {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "soccerball.circle.fill")
                            .foregroundColor(.green)
                            .font(.title3)
                        
                        Text("Máximos goleadores")
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    
                    ForEach(Array(topScorers.enumerated()), id: \.element.name) { index, scorer in
                        HStack {
                            ZStack {
                                Circle()
                                    .fill(index < 3 ? Color.yellow.opacity(0.2) : Color.gray.opacity(0.1))
                                    .frame(width: 32, height: 32)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                    )
                                
                                Text("\(index + 1)")
                                    .font(.headline)
                                    .foregroundColor(index < 3 ? Color.orange : .primary)
                            }
                            
                            Text(scorer.name)
                                .font(.body)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            HStack(spacing: 6) {
                                Image(systemName: "soccerball")
                                    .font(.caption)
                                    .foregroundColor(.green)
                                
                                Text("\(scorer.goals)")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        
                        if index < topScorers.count - 1 {
                            Divider()
                                .background(Color.gray.opacity(0.3))
                                .padding(.horizontal)
                        }
                    }
                    
                    .padding(.bottom)
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
            
            // Top Assisters
            GlassCard(cornerRadius: 24, tintColor: team.teamColor) {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "figure.run.circle.fill")
                            .foregroundColor(.blue)
                            .font(.title3)
                        
                        Text("Máximos asistentes")
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    
                    ForEach(Array(topAssisters.enumerated()), id: \.element.name) { index, assister in
                        HStack {
                            ZStack {
                                Circle()
                                    .fill(index < 3 ? Color.blue.opacity(0.15) : Color.gray.opacity(0.1))
                                    .frame(width: 32, height: 32)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                    )
                                
                                Text("\(index + 1)")
                                    .font(.headline)
                                    .foregroundColor(index < 3 ? Color.blue : .primary)
                            }
                            
                            Text(assister.name)
                                .font(.body)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            HStack(spacing: 6) {
                                Image(systemName: "arrow.right.circle.fill")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                                
                                Text("\(assister.assists)")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        
                        if index < topAssisters.count - 1 {
                            Divider()
                                .background(Color.gray.opacity(0.3))
                                .padding(.horizontal)
                        }
                    }
                    
                    .padding(.bottom)
                }
            }
            .padding(.horizontal)
            
            Spacer(minLength: 20)
        }
        .padding(.vertical)
    }
}

// MARK: - Filter Sheet
struct FilterSheet: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedFilter: StatisticsFilter
    @Binding var selectedTeam: TeamStatistics?
    let teams: [TeamStatistics]
    
    var body: some View {
        NavigationView {
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
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Filter Options
                        GlassCard(cornerRadius: 20) {
                            VStack(alignment: .leading, spacing: 0) {
                                Text("Filtrar partidos")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                    .padding()
                                
                                ForEach(StatisticsFilter.allCases, id: \.self) { filter in
                                    Button(action: {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                            selectedFilter = filter
                                        }
                                    }) {
                                        HStack {
                                            Text(filter.rawValue)
                                                .foregroundColor(.primary)
                                            
                                            Spacer()
                                            
                                            if selectedFilter == filter {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .foregroundColor(.blue)
                                                    .font(.title3)
                                            }
                                        }
                                        .padding()
                                        .background(
                                            selectedFilter == filter ?
                                            Color.blue.opacity(0.08) : Color.clear
                                        )
                                    }
                                    .buttonStyle(.plain)
                                    
                                    if filter != StatisticsFilter.allCases.last {
                                        Divider()
                                            .background(Color.gray.opacity(0.2))
                                            .padding(.leading)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top)
                        
                        // Change Team
                        GlassCard(cornerRadius: 20) {
                            VStack(alignment: .leading, spacing: 0) {
                                Text("Cambiar equipo")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                    .padding()
                                
                                ForEach(teams) { team in
                                    Button(action: {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                            selectedTeam = team
                                            dismiss()
                                        }
                                    }) {
                                        HStack(spacing: 12) {
                                            ZStack {
                                                Circle()
                                                    .fill(team.teamColor.opacity(0.15))
                                                    .frame(width: 40, height: 40)
                                                
                                                Image(systemName: team.teamLogo)
                                                    .font(.system(size: 20))
                                                    .foregroundColor(team.teamColor)
                                            }
                                            
                                            Text(team.teamName)
                                                .foregroundColor(.primary)
                                            
                                            Spacer()
                                            
                                            if selectedTeam?.id == team.id {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .foregroundColor(.blue)
                                                    .font(.title3)
                                            }
                                        }
                                        .padding()
                                        .background(
                                            selectedTeam?.id == team.id ?
                                            team.teamColor.opacity(0.05) : Color.clear
                                        )
                                    }
                                    .buttonStyle(.plain)
                                    
                                    if team.id != teams.last?.id {
                                        Divider()
                                            .background(Color.gray.opacity(0.2))
                                            .padding(.leading)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        Spacer(minLength: 20)
                    }
                }
            }
            .navigationTitle("Filtros")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cerrar") {
                        dismiss()
                    }
                    .foregroundColor(.blue)
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

// Helper extension for rounded corners on specific sides
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

@available(iOS 16.0, *)
struct StatisticsView_Previews: PreviewProvider {
    static var previews: some View {
        StatisticsMainView()
    }
}
