//
//  MatchSettings.swift
//  AppAccesibilidad
//
//  Created by Azuany Mila Cerón on 11/8/25.
//

import Foundation
import UIKit

@Observable
class MatchSettings {
    
    var team1Shape: PlayerShape = .circle
    var team1Color: PlayerColor = .blue
    var goalkeeper1Shape: PlayerShape = .square
    var goalkeeper1Color: PlayerColor = .blue
    var team2Shape: PlayerShape = .circle
    var team2Color: PlayerColor = .red
    var goalkeeper2Shape: PlayerShape = .square
    var goalkeeper2Color: PlayerColor = .red
    var ballShape: PlayerShape = .circle
    var ballColor: PlayerColor = .orange
    
    var zoom: Double = 1.0
    
    struct Style {
        let shape: PlayerShape
        let color: UIColor
        
        // Define a default for unclassified objects
        static let unclassified = Style(shape: .square, color: .gray)
    }
    
    /// Returns the correct shape and color for any given detection
    func style(for detection: DetectionType) -> Style {
        switch detection {
        case .ball:
            return Style(shape: ballShape, color: ballColor.uiColor)
            
        case .player(let teamID):
            switch teamID {
            case 0: return Style(shape: team1Shape, color: team1Color.uiColor)
            case 1: return Style(shape: team2Shape, color: team2Color.uiColor)
            // case 2: ... (add 3rd team if needed)
            default: return .unclassified
            }
            
        case .goalkeeper(let teamID):
            switch teamID {
            case 0: return Style(shape: goalkeeper1Shape, color: goalkeeper1Color.uiColor)
            case 1: return Style(shape: goalkeeper2Shape, color: goalkeeper2Color.uiColor)
            default: return .unclassified
            }
            
        case .unclassified:
            return .unclassified
        }
    }
    
}

/// A more descriptive way to represent a detection
enum DetectionType {
    case player(teamID: Int)
    case goalkeeper(teamID: Int)
    case ball
    case unclassified
    
    /// Helper to create this enum from your old parameters
    init(label: String, teamID: Int?) {
        switch label.lowercased() {
        case "ball":
            self = .ball
        case "player":
            if let teamID {
                self = .player(teamID: teamID)
            } else {
                self = .unclassified
            }
        case "goalkeeper":
            if let teamID {
                self = .goalkeeper(teamID: teamID)
            } else {
                self = .unclassified
            }
        default:
            self = .unclassified
        }
    }
}
