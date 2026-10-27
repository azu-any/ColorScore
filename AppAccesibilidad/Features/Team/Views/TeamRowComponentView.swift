//
//  TeamRowComponentView.swift
//  AppAccesibilidad
//
//  Created by Maeva Mazadiego on 17/10/25.
//

import SwiftUI

struct TeamRowComponentView: View {
    let teams: [Team]
    let sectionColor: Color
    var onTeamSelected: ((Team) -> Void)? = nil
    
    init(teams: [Team], sectionColor: Color = .primary, onTeamSelected: ((Team) -> Void)? = nil) {
        self.teams = teams
        self.sectionColor = sectionColor
        self.onTeamSelected = onTeamSelected
    }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(teams) { team in
                    Button(action: {
                        onTeamSelected?(team)
                    }) {
                        TeamCardView(team: team, sectionColor: sectionColor)
                    }
                    .buttonStyle(.plain)
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel(team.name)
                    .accessibilityHint("Toca dos veces para seleccionar este equipo")
                    .accessibilityAddTraits(.isButton)
                }
            }
            .padding(.horizontal)
        }
    }
}

struct TeamCardView: View {
    let team: Team
    let sectionColor: Color
    
    init(team: Team, sectionColor: Color = .primary) {
        self.team = team
        self.sectionColor = sectionColor
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // Team Logo Container with team color background
            ZStack {
                // Team color background
                RoundedRectangle(cornerRadius: 12)
                    .fill(teamColor)
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
                
                // Team Logo
                if UIImage(named: team.imageName) != nil {
                    Image(team.imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .shadow(color: Color.black.opacity(0.3), radius: 4, x: 0, y: 2)
                        .accessibilityHidden(true)
                } else {
                    // Fallback icon if image doesn't exist
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
            
            // Team Name
            Text(team.name)
                .font(.footnote.weight(.medium))
                .multilineTextAlignment(.center)
                .frame(width: 140)
                .lineLimit(2)
                .foregroundStyle(.primary)
        }
    }
    
    // Get the official team color
    private var teamColor: Color {
        return TeamColors.color(for: team.name)
    }
}

struct TeamRowComponentView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleTeams = [
            Team(name: "Paris Saint-Germain", imageName: "psg"),
            Team(name: "Tottenham Hotspur", imageName: "tottenham"),
            Team(name: "Bayern Munich", imageName: "bayern")
        ]
        
        TeamRowComponentView(teams: sampleTeams, sectionColor: .blue)
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
