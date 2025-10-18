//
//  TeamSelectionView.swift
//  AppAccesibilidad
//
//  Created by Maeva Mazadiego on 10/10/25.
//

import SwiftUI

struct Team: Identifiable {
    let id = UUID()
    let name: String
    let imageName: String
}

struct TeamSelectionView: View {
    let copaLibertadoresTeams = [
        Team(name: "Boca Juniors", imageName: "boca"),
        Team(name: "River Plate", imageName: "river"),
        Team(name: "Flamengo", imageName: "flamengo"),
        Team(name: "Palmeiras", imageName: "palmeiras"),
        Team(name: "Santos", imageName: "santos"),
        Team(name: "Independiente", imageName: "independiente")
    ]
    
    let mexicoTeams = [
        Team(name: "Club América", imageName: "america"),
        Team(name: "Chivas Guadalajara", imageName: "chivas"),
        Team(name: "Cruz Azul", imageName: "cruzazul"),
        Team(name: "Pumas UNAM", imageName: "pumas"),
        Team(name: "Tigres UANL", imageName: "tigres"),
        Team(name: "Monterrey", imageName: "monterrey")
    ]
    
    let premierLeagueTeams = [
        Team(name: "Manchester United", imageName: "manutd"),
        Team(name: "Manchester City", imageName: "mancity"),
        Team(name: "Liverpool", imageName: "liverpool"),
        Team(name: "Arsenal", imageName: "arsenal"),
        Team(name: "Chelsea", imageName: "chelsea"),
        Team(name: "Tottenham Hotspur", imageName: "tottenham")
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Nuevo partido")
                            .font(.system(size: 34, weight: .bold))
                        
                        Text("Configura tu partido")
                            .font(.system(size: 17, weight: .regular))
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    // Copa Libertadores Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Copa libertadores")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.black)
                            .padding(.horizontal)
                        
                        TeamRowComponentView(teams: copaLibertadoresTeams, sectionColor: .red)
                    }
                    
                    // Mexico Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Liga MX")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.black)
                            .padding(.horizontal)
                        
                        TeamRowComponentView(teams: mexicoTeams, sectionColor: .blue)
                    }
                    
                    // Premier League Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Premier League")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.black)
                            .padding(.horizontal)
                        
                        TeamRowComponentView(teams: premierLeagueTeams, sectionColor: .indigo)
                    }
                }
                .padding(.vertical)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {}) {
                        Image(systemName: "plus")
                            .font(.system(size: 22, weight: .medium))
                            .foregroundColor(.primary)
                    }
                }
            }
        }
    }
}

struct TeamSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        TeamSelectionView()
    }
}
