//
//  TeamFormOptions.swift
//  AppAccesibilidad
//
//  Created by Maeva Mazadiego on 07/11/25.
//

import SwiftUI

/// Represents a predefined team color option with an accessible display name.
struct TeamColorOption: Identifiable {
    let id = UUID()
    let name: String
    let color: Color
}

/// Centralized static data options for creating or editing a custom team.
enum TeamFormOptions {
    static let availableCountries: [String] = [
        "Argentina", "Brasil", "México", "España", "Inglaterra", "Italia",
        "Alemania", "Francia", "Portugal", "Países Bajos", "Uruguay", "Colombia",
        "Chile", "Ecuador", "Perú", "Paraguay", "Venezuela", "Bolivia"
    ]
    
    static let availableMexicoDivisions: [String] = [
        "Liga MX",
        "Liga de Expansión MX",
        "Segunda División",
        "Tercera División",
        "Otro"
    ]
    
    static let presetColorOptions: [TeamColorOption] = [
        TeamColorOption(name: "Azul clásico", color: Color(red: 0.0, green: 0.3, blue: 0.6)),
        TeamColorOption(name: "Rojo clásico", color: Color(red: 0.8, green: 0.0, blue: 0.0)),
        TeamColorOption(name: "Verde", color: Color(red: 0.0, green: 0.5, blue: 0.2)),
        TeamColorOption(name: "Naranja", color: Color(red: 1.0, green: 0.65, blue: 0.0)),
        TeamColorOption(name: "Morado", color: Color(red: 0.4, green: 0.0, blue: 0.6)),
        TeamColorOption(name: "Cian", color: Color(red: 0.0, green: 0.7, blue: 0.8)),
        TeamColorOption(name: "Amarillo oro", color: Color(red: 1.0, green: 0.8, blue: 0.0)),
        TeamColorOption(name: "Gris oscuro", color: Color(red: 0.2, green: 0.2, blue: 0.2)),
        TeamColorOption(name: "Gris claro", color: Color(red: 0.9, green: 0.9, blue: 0.9)),
        TeamColorOption(name: "Guinda", color: Color(red: 0.5, green: 0.0, blue: 0.0)),
        TeamColorOption(name: "Azul marino", color: Color(red: 0.0, green: 0.2, blue: 0.4)),
        TeamColorOption(name: "Violeta", color: Color(red: 0.6, green: 0.2, blue: 0.8))
    ]
}
