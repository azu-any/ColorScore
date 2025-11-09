//
//  SelectedTeamData.swift
//  AppAccesibilidad
//
//  Created by Maeva Mazadiego on 08/11/25.
//

import SwiftUI

// Represents a selected team (either predefined or custom)
struct SelectedTeamData: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let imageName: String? // For predefined teams
    let imageData: Data? // For custom teams
    let country: String?
    let division: String?
    let teamColorHex: String? // Team color
    
    // Initializer for predefined teams (with color)
    init(name: String, imageName: String, teamColor: Color? = nil) {
        self.name = name
        self.imageName = imageName
        self.imageData = nil
        self.country = nil
        self.division = nil
        self.teamColorHex = teamColor?.toHex()
    }
    
    // Initializer for custom teams
    init(customTeam: CustomTeam) {
        self.name = customTeam.name
        self.imageName = nil
        self.imageData = customTeam.logoImageData
        self.country = customTeam.country
        self.division = customTeam.division
        self.teamColorHex = customTeam.teamColorHex
    }
    
    // Get color from hex
    var teamColor: Color {
        if let hex = teamColorHex {
            return Color(hex: hex)
        }
        return Color.blue // Default
    }
    
    static func == (lhs: SelectedTeamData, rhs: SelectedTeamData) -> Bool {
        lhs.id == rhs.id
    }
}

// Observable object to manage team selections
@Observable
class TeamSelectionManager {
    var team1: SelectedTeamData?
    var team2: SelectedTeamData?
}
