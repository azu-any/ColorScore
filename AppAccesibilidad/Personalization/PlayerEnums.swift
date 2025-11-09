//
//  PlayerShape.swift
//  AppAccesibilidad
//
//  Created by Azuany Mila Cerón on 11/8/25.
//

import SwiftUI
import UIKit

// MARK: - Player Customization Types
enum PlayerShape: String, CaseIterable, Identifiable {
    case circle = "Circle"
    case square = "Square"
    case triangle = "Triangle"
    case diamond = "Diamond"
    case star = "Star"
    
    var id: String { rawValue }
    
    @ViewBuilder
    func view(color: Color, size: CGFloat = 24) -> some View {
        switch self {
        case .circle:
            Circle()
                .fill(color)
                .frame(width: size, height: size)
        case .square:
            Rectangle()
                .fill(color)
                .frame(width: size, height: size)
        case .triangle:
            Triangle()
                .fill(color)
                .frame(width: size, height: size)
        case .diamond:
            Diamond()
                .fill(color)
                .frame(width: size, height: size)
        case .star:
            Star()
                .fill(color)
                .frame(width: size * 1.2, height: size * 1.2)
        }
    }
    
    
    /// Converts the enum into a drawable UIBezierPath for UIKit
    func path(in bounds: CGRect) -> UIBezierPath {
        let midX = bounds.midX
        let midY = bounds.midY
        let minX = bounds.minX
        let minY = bounds.minY
        let maxX = bounds.maxX
        let maxY = bounds.maxY

        switch self {
        case .circle:
            return UIBezierPath(ovalIn: bounds)
            
        case .square:
            return UIBezierPath(rect: bounds)
            
        case .triangle:
            let path = UIBezierPath()
            path.move(to: CGPoint(x: midX, y: minY)) // Top-center
            path.addLine(to: CGPoint(x: maxX, y: maxY)) // Bottom-right
            path.addLine(to: CGPoint(x: minX, y: maxY)) // Bottom-left
            path.close()
            return path
            
        case .diamond:
            let path = UIBezierPath()
            path.move(to: CGPoint(x: midX, y: minY)) // Top-center
            path.addLine(to: CGPoint(x: maxX, y: midY)) // Mid-right
            path.addLine(to: CGPoint(x: midX, y: maxY)) // Bottom-center
            path.addLine(to: CGPoint(x: minX, y: midY)) // Mid-left
            path.close()
            return path
            
        case .star:
            // Creates a 5-point star path
            return UIBezierPath.star(in: bounds)
        }
    }
}

// Helper extension to create a star path
fileprivate extension UIBezierPath {
    static func star(in rect: CGRect, points: Int = 5, innerRadiusRatio: CGFloat = 0.38) -> UIBezierPath {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let outerRadius = min(rect.width, rect.height) / 2.0
        let innerRadius = outerRadius * innerRadiusRatio
        
        let path = UIBezierPath()
        let angleIncrement = .pi * 2.0 / CGFloat(points)
        let startAngle: CGFloat = -.pi / 2.0 // Start at the top

        for i in 0..<points {
            let outerPoint = CGPoint(
                x: center.x + outerRadius * cos(startAngle + CGFloat(i) * angleIncrement),
                y: center.y + outerRadius * sin(startAngle + CGFloat(i) * angleIncrement)
            )
            let innerPoint = CGPoint(
                x: center.x + innerRadius * cos(startAngle + CGFloat(i) * angleIncrement + angleIncrement / 2.0),
                y: center.y + innerRadius * sin(startAngle + CGFloat(i) * angleIncrement + angleIncrement / 2.0)
            )
            
            if i == 0 {
                path.move(to: outerPoint)
            } else {
                path.addLine(to: outerPoint)
            }
            path.addLine(to: innerPoint)
        }
        path.close()
        return path
    }
}

enum PlayerColor: String, CaseIterable, Identifiable {
    case blue = "Blue"
    case red = "Red"
    case green = "Green"
    case orange = "Orange"
    case purple = "Purple"
    case yellow = "Yellow"
    case cyan = "Cyan"
    case pink = "Pink"
    
    var id: String { rawValue }
    
    var color: Color {
        switch self {
        case .blue: return Color(red: 0.0, green: 0.48, blue: 0.8)      // Colorblind-friendly blue
        case .red: return Color(red: 0.9, green: 0.27, blue: 0.23)      // Colorblind-friendly red
        case .green: return Color(red: 0.0, green: 0.62, blue: 0.45)    // Colorblind-friendly green
        case .orange: return Color(red: 0.9, green: 0.6, blue: 0.0)     // High contrast orange
        case .purple: return Color(red: 0.58, green: 0.4, blue: 0.74)   // Distinct purple
        case .yellow: return Color(red: 0.95, green: 0.9, blue: 0.25)   // High visibility yellow
        case .cyan: return Color(red: 0.2, green: 0.73, blue: 0.87)     // Light cyan
        case .pink: return Color(red: 0.96, green: 0.51, blue: 0.69)    // Distinct pink
        }
    }
    
    var uiColor: UIColor {
        return UIColor(self.color)
    }
}
