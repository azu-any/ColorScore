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
    
    init(teams: [Team], sectionColor: Color = .primary) {
        self.teams = teams
        self.sectionColor = sectionColor
    }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(teams) { team in
                    TeamCardView(team: team, sectionColor: sectionColor)
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
            // Team Logo Container
            RoundedRectangle(cornerRadius: 12)
                .fill(backgroundColor)
                .frame(width: 140, height: 140)
                .overlay(
                    Image(systemName: logoSystemImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .foregroundColor(logoColor)
                )
            
            // Team Name
            Text(team.name)
                .font(.system(size: 13, weight: .regular))
                .multilineTextAlignment(.center)
                .frame(width: 140)
                .lineLimit(2)
        }
    }
    
    // Helper computed properties for demo purposes
    private var backgroundColor: Color {
        // Generate a random color based on the team's ID for consistency
        let colors: [Color] = [
            .red, .blue, .green, .orange, .purple, .pink,
            .indigo, .teal, .mint, .cyan, .brown,
            Color(red: 0.0, green: 0.2, blue: 0.4), // Dark blue
            Color(red: 0.6, green: 0.0, blue: 0.4), // Dark purple
            Color(red: 0.8, green: 0.4, blue: 0.0), // Dark orange
            Color(red: 0.2, green: 0.6, blue: 0.0), // Dark green
            Color(red: 0.4, green: 0.0, blue: 0.6), // Dark magenta
            .black
        ]
        
        // Use the team name's hash to get consistent random color
        let index = abs(team.name.hashValue) % colors.count
        return colors[index]
    }
    
    private var logoColor: Color {
        return .white
    }
    
    private var logoSystemImage: String {
        return "sportscourt.fill"
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
