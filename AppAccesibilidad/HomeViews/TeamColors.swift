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
            return Color(red: 1.0, green: 0.8, blue: 0.0) // Yellow/Gold
        case "Chivas de Guadalajara":
            return Color(red: 0.8, green: 0.0, blue: 0.0) // Red
        case "Tigres UANL":
            return Color(red: 1.0, green: 0.65, blue: 0.0) // Orange/Gold
        case "Monterrey":
            return Color(red: 0.0, green: 0.3, blue: 0.6) // Blue
        case "Cruz Azul":
            return Color(red: 0.0, green: 0.3, blue: 0.6) // Blue
        case "Pumas UNAM":
            return Color(red: 0.0, green: 0.2, blue: 0.4) // Navy/Gold
        case "Toluca":
            return Color(red: 0.8, green: 0.0, blue: 0.0) // Red
        case "Santos Laguna":
            return Color(red: 0.0, green: 0.5, blue: 0.2) // Green
        case "León":
            return Color(red: 0.0, green: 0.5, blue: 0.2) // Green
        case "Atlas":
            return Color(red: 0.8, green: 0.0, blue: 0.0) // Red/Black
            
        // MLS
        case "Inter Miami CF":
            return Color(red: 0.95, green: 0.4, blue: 0.7) // Pink
        case "LAFC":
            return Color(red: 0.2, green: 0.2, blue: 0.2) // Black/Gold
        case "LA Galaxy":
            return Color(red: 0.0, green: 0.2, blue: 0.4) // Navy/Gold
        case "New York City FC":
            return Color(red: 0.0, green: 0.7, blue: 0.8) // Light Blue
        case "Atlanta United":
            return Color(red: 0.8, green: 0.0, blue: 0.0) // Red
            
        // España - LaLiga
        case "Real Madrid CF":
            return Color(red: 0.9, green: 0.9, blue: 0.9) // White
        case "FC Barcelona":
            return Color(red: 0.0, green: 0.2, blue: 0.5) // Blue/Red
        case "Atlético de Madrid":
            return Color(red: 0.8, green: 0.0, blue: 0.0) // Red/White
        case "Sevilla FC":
            return Color(red: 0.8, green: 0.0, blue: 0.0) // Red/White
        case "Real Sociedad":
            return Color(red: 0.0, green: 0.3, blue: 0.6) // Blue/White
            
        // Inglaterra - Premier League
        case "Manchester City":
            return Color(red: 0.0, green: 0.7, blue: 0.8) // Sky Blue
        case "Liverpool FC":
            return Color(red: 0.8, green: 0.0, blue: 0.0) // Red
        case "Arsenal FC":
            return Color(red: 0.8, green: 0.0, blue: 0.0) // Red/White
        case "Chelsea FC":
            return Color(red: 0.0, green: 0.3, blue: 0.6) // Blue
        case "Manchester United":
            return Color(red: 0.8, green: 0.0, blue: 0.0) // Red
            
        // Italia - Serie A
        case "Juventus":
            return Color(red: 0.2, green: 0.2, blue: 0.2) // Black/White
        case "AC Milan":
            return Color(red: 0.8, green: 0.0, blue: 0.0) // Red/Black
        case "Inter de Milán":
            return Color(red: 0.0, green: 0.3, blue: 0.6) // Blue/Black
        case "Napoli":
            return Color(red: 0.0, green: 0.5, blue: 0.8) // Light Blue
        case "AS Roma":
            return Color(red: 0.6, green: 0.1, blue: 0.0) // Dark Red/Yellow
            
        // Alemania - Bundesliga
        case "Bayern München":
            return Color(red: 0.8, green: 0.0, blue: 0.0) // Red
        case "Borussia Dortmund":
            return Color(red: 1.0, green: 0.8, blue: 0.0) // Yellow/Black
        case "RB Leipzig":
            return Color(red: 0.8, green: 0.0, blue: 0.0) // Red/White
        case "Bayer Leverkusen":
            return Color(red: 0.8, green: 0.0, blue: 0.0) // Red/Black
        case "Eintracht Frankfurt":
            return Color(red: 0.8, green: 0.0, blue: 0.0) // Red/Black
            
        // Francia - Ligue 1
        case "Paris Saint-Germain":
            return Color(red: 0.0, green: 0.2, blue: 0.4) // Navy/Red
        case "Olympique de Marseille":
            return Color(red: 0.0, green: 0.7, blue: 0.9) // Light Blue/White
        case "AS Monaco":
            return Color(red: 0.8, green: 0.0, blue: 0.0) // Red/White
        case "Lyon":
            return Color(red: 0.0, green: 0.3, blue: 0.6) // Blue/Red/White
        case "Lille":
            return Color(red: 0.8, green: 0.0, blue: 0.0) // Red/Blue
            
        // Brasil - Serie A
        case "Flamengo":
            return Color(red: 0.8, green: 0.0, blue: 0.0) // Red/Black
        case "Palmeiras":
            return Color(red: 0.0, green: 0.5, blue: 0.2) // Green
        case "Corinthians":
            return Color(red: 0.9, green: 0.9, blue: 0.9) // White/Black
        case "São Paulo FC":
            return Color(red: 0.8, green: 0.0, blue: 0.0) // Red/White/Black
        case "Fluminense":
            return Color(red: 0.5, green: 0.0, blue: 0.0) // Maroon/Green/White
            
        // Argentina - Liga Profesional
        case "Boca Juniors":
            return Color(red: 0.0, green: 0.2, blue: 0.5) // Blue/Yellow
        case "River Plate":
            return Color(red: 0.8, green: 0.0, blue: 0.0) // Red/White
        case "Racing Club":
            return Color(red: 0.0, green: 0.7, blue: 0.9) // Sky Blue/White
        case "San Lorenzo":
            return Color(red: 0.0, green: 0.3, blue: 0.6) // Blue/Red
        case "Independiente":
            return Color(red: 0.8, green: 0.0, blue: 0.0) // Red
            
        // Colombia - Primera A
        case "Atlético Nacional":
            return Color(red: 0.0, green: 0.5, blue: 0.2) // Green
        case "Millonarios FC":
            return Color(red: 0.0, green: 0.3, blue: 0.6) // Blue
        case "América de Cali":
            return Color(red: 0.8, green: 0.0, blue: 0.0) // Red
        case "Deportivo Cali":
            return Color(red: 0.0, green: 0.5, blue: 0.2) // Green/White
        case "Independiente Medellín":
            return Color(red: 0.8, green: 0.0, blue: 0.0) // Red
            
        // Uruguay - Primera División
        case "Club Nacional de Football":
            return Color(red: 0.0, green: 0.3, blue: 0.6) // Blue/Red/White
        case "Peñarol":
            return Color(red: 1.0, green: 0.8, blue: 0.0) // Yellow/Black
        case "Defensor Sporting":
            return Color(red: 0.4, green: 0.0, blue: 0.6) // Purple
        case "Danubio FC":
            return Color(red: 0.0, green: 0.3, blue: 0.6) // Blue/Yellow
        case "Liverpool Montevideo":
            return Color(red: 0.0, green: 0.3, blue: 0.6) // Blue/Black
            
        // Chile - Primera División
        case "Colo-Colo":
            return Color(red: 0.9, green: 0.9, blue: 0.9) // White/Black
        case "Universidad de Chile":
            return Color(red: 0.0, green: 0.3, blue: 0.6) // Blue
        case "Universidad Católica":
            return Color(red: 0.0, green: 0.3, blue: 0.6) // Blue/White
        case "Unión Española":
            return Color(red: 0.8, green: 0.0, blue: 0.0) // Red/Yellow
        case "Audax Italiano":
            return Color(red: 0.0, green: 0.5, blue: 0.2) // Green/White
            
        // Default color for unlisted teams
        default:
            return Color(red: 0.0, green: 0.3, blue: 0.6) // Blue
        }
    }
}
