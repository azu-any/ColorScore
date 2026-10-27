//
//  ColorButton.swift
//  AppAccesibilidad
//
//  Created by Maeva Mazadiego on 07/11/25.
//

import SwiftUI

/// Circular button representing a selectable team color option.
struct ColorButton: View {
    let color: Color
    var colorName: String = "Color"
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                colorCircle
                if isSelected {
                    selectionCheckmark
                }
            }
            .frame(minWidth: 44, minHeight: 44)
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(colorName)
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
    }
    
    private var colorCircle: some View {
        Circle()
            .fill(color)
            .frame(width: 60, height: 60)
            .overlay(
                Circle()
                    .strokeBorder(
                        isSelected ? Color.primary : Color.primary.opacity(0.15),
                        lineWidth: isSelected ? 3 : 1
                    )
            )
            .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
    }
    
    private var selectionCheckmark: some View {
        Image(systemName: "checkmark.circle.fill")
            .font(.title3)
            .foregroundStyle(.white)
            .background(
                Circle()
                    .fill(Color.black.opacity(0.4))
                    .frame(width: 32, height: 32)
            )
    }
}
