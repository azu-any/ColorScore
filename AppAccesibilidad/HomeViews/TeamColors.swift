//
//  TeamColors.swift
//  AppAccesibilidad
//
//  Created by Maeva Mazadiego on 08/11/25.
//

import SwiftUI

struct TeamColors {
    /// Get the official color for a team by name
    static func color(for teamName: String) -> Color {
        switch teamName {
        // México - Liga MX
        case "Club América":
            return Color(red: 1.0, green: 0.84, blue: 0.0) // Bright Yellow/Gold
        case "Chivas de Guadalajara":
            return Color(red: 0.85, green: 0.11, blue: 0.14) // Red/White stripes
        case "Tigres UANL":
            return Color(red: 1.0, green: 0.6, blue: 0.0) // Orange/Gold
        case "Monterrey":
            return Color(red: 0.0, green: 0.32, blue: 0.61) // Royal Blue
        case "Cruz Azul":
            return Color(red: 0.0, green: 0.44, blue: 0.75) // Light Blue (different from Monterrey)
        case "Pumas UNAM":
            return Color(red: 0.0, green: 0.21, blue: 0.42) // Navy Blue/Gold
        case "Toluca":
            return Color(red: 0.75, green: 0.0, blue: 0.13) // Dark Red (different from Chivas)
        case "Santos Laguna":
            return Color(red: 0.0, green: 0.51, blue: 0.27) // Forest Green
        case "León":
            return Color(red: 0.0, green: 0.39, blue: 0.0) // Dark Green (different from Santos)
        case "Atlas":
            return Color(red: 0.8, green: 0.0, blue: 0.0) // Red/Black
            
        // MLS
        case "Inter Miami CF":
            return Color(red: 0.96, green: 0.42, blue: 0.71) // Pink/Coral
        case "LAFC":
            return Color(red: 0.15, green: 0.15, blue: 0.15) // Black/Gold
        case "LA Galaxy":
            return Color(red: 0.0, green: 0.2, blue: 0.35) // Navy/Gold
        case "New York City FC":
            return Color(red: 0.4, green: 0.7, blue: 0.93) // Sky Blue
        case "Atlanta United":
            return Color(red: 0.6, green: 0.0, blue: 0.0) // Maroon/Red
            
        // España - LaLiga
        case "Real Madrid CF":
            return Color(red: 0.95, green: 0.95, blue: 0.95) // Pure White
        case "FC Barcelona":
            return Color(red: 0.64, green: 0.13, blue: 0.19) // Blaugrana (Burgundy)
        case "Atlético de Madrid":
            return Color(red: 0.8, green: 0.15, blue: 0.21) // Red/White
        case "Sevilla FC":
            return Color(red: 0.9, green: 0.9, blue: 0.9) // White/Red
        case "Real Sociedad":
            return Color(red: 0.0, green: 0.28, blue: 0.67) // Royal Blue/White
            
        // Inglaterra - Premier League
        case "Manchester City":
            return Color(red: 0.38, green: 0.68, blue: 0.91) // Sky Blue
        case "Liverpool FC":
            return Color(red: 0.78, green: 0.08, blue: 0.22) // Liverpool Red
        case "Arsenal FC":
            return Color(red: 0.93, green: 0.0, blue: 0.16) // Arsenal Red (different tone)
        case "Chelsea FC":
            return Color(red: 0.0, green: 0.26, blue: 0.55) // Chelsea Blue
        case "Manchester United":
            return Color(red: 0.85, green: 0.05, blue: 0.11) // Manchester Red (different tone)
            
        // Italia - Serie A
        case "Juventus":
            return Color(red: 0.1, green: 0.1, blue: 0.1) // Black/White
        case "AC Milan":
            return Color(red: 0.8, green: 0.0, blue: 0.0) // Rossoneri Red
        case "Inter de Milán":
            return Color(red: 0.0, green: 0.24, blue: 0.47) // Nerazzurri Blue
        case "Napoli":
            return Color(red: 0.2, green: 0.51, blue: 0.82) // Napoli Light Blue
        case "AS Roma":
            return Color(red: 0.63, green: 0.11, blue: 0.08) // Roma Dark Red/Yellow
            
        // Alemania - Bundesliga
        case "Bayern München":
            return Color(red: 0.86, green: 0.0, blue: 0.13) // Bayern Red
        case "Borussia Dortmund":
            return Color(red: 1.0, green: 0.84, blue: 0.0) // Yellow/Black
        case "RB Leipzig":
            return Color(red: 0.85, green: 0.0, blue: 0.16) // Red/White (slightly different)
        case "Bayer Leverkusen":
            return Color(red: 0.9, green: 0.1, blue: 0.13) // Red/Black (more orange-red)
        case "Eintracht Frankfurt":
            return Color(red: 0.9, green: 0.0, blue: 0.0) // Red/Black (bright red)
            
        // Francia - Ligue 1
        case "Paris Saint-Germain":
            return Color(red: 0.0, green: 0.16, blue: 0.38) // Dark Navy/Red
        case "Olympique de Marseille":
            return Color(red: 0.13, green: 0.59, blue: 0.95) // Sky Blue
        case "AS Monaco":
            return Color(red: 0.9, green: 0.0, blue: 0.13) // Red/White
        case "Lyon":
            return Color(red: 0.0, green: 0.22, blue: 0.52) // Dark Blue/White
        case "Lille":
            return Color(red: 0.78, green: 0.0, blue: 0.16) // Dark Red (different from Monaco)
            
        // Brasil - Serie A
        case "Flamengo":
            return Color(red: 0.9, green: 0.0, blue: 0.13) // Red/Black
        case "Palmeiras":
            return Color(red: 0.0, green: 0.42, blue: 0.24) // Forest Green
        case "Corinthians":
            return Color(red: 0.95, green: 0.95, blue: 0.95) // White/Black
        case "São Paulo FC":
            return Color(red: 0.85, green: 0.11, blue: 0.14) // Red/Black/White
        case "Fluminense":
            return Color(red: 0.5, green: 0.11, blue: 0.14) // Maroon/Green/White
            
        // Argentina - Liga Profesional
        case "Boca Juniors":
            return Color(red: 0.0, green: 0.2, blue: 0.52) // Blue/Yellow
        case "River Plate":
            return Color(red: 0.9, green: 0.95, blue: 0.95) // White/Red diagonal
        case "Racing Club":
            return Color(red: 0.38, green: 0.68, blue: 0.91) // Sky Blue/White
        case "San Lorenzo":
            return Color(red: 0.64, green: 0.13, blue: 0.19) // Blue/Red
        case "Independiente":
            return Color(red: 0.9, green: 0.0, blue: 0.0) // Red
            
        // Colombia - Primera A
        case "Atlético Nacional":
            return Color(red: 0.0, green: 0.51, blue: 0.2) // Green/White
        case "Millonarios FC":
            return Color(red: 0.0, green: 0.26, blue: 0.59) // Blue
        case "América de Cali":
            return Color(red: 0.85, green: 0.0, blue: 0.0) // Red
        case "Deportivo Cali":
            return Color(red: 0.0, green: 0.42, blue: 0.24) // Green/White (darker than Nacional)
        case "Independiente Medellín":
            return Color(red: 0.9, green: 0.11, blue: 0.14) // Red (different tone)
            
        // Uruguay - Primera División
        case "Club Nacional de Football":
            return Color(red: 0.0, green: 0.26, blue: 0.67) // Blue/Red/White
        case "Peñarol":
            return Color(red: 1.0, green: 0.84, blue: 0.0) // Yellow/Black
        case "Defensor Sporting":
            return Color(red: 0.35, green: 0.16, blue: 0.49) // Purple/Green
        case "Danubio FC":
            return Color(red: 0.0, green: 0.51, blue: 0.78) // Light Blue/Yellow
        case "Liverpool Montevideo":
            return Color(red: 0.0, green: 0.2, blue: 0.4) // Navy Blue/Black
            
        // Chile - Primera División
        case "Colo-Colo":
            return Color(red: 0.95, green: 0.95, blue: 0.95) // White/Black
        case "Universidad de Chile":
            return Color(red: 0.0, green: 0.26, blue: 0.67) // Blue
        case "Universidad Católica":
            return Color(red: 0.0, green: 0.22, blue: 0.52) // Blue/White (darker than U de Chile)
        case "Unión Española":
            return Color(red: 0.9, green: 0.0, blue: 0.0) // Red/Yellow
        case "Audax Italiano":
            return Color(red: 0.0, green: 0.42, blue: 0.24) // Green/White
            
        // Default color for unlisted teams
        default:
            return Color(red: 0.0, green: 0.3, blue: 0.6) // Blue
        }
    }
}
