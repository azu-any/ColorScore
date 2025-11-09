//
//  ShapeColorPicker.swift
//  AppAccesibilidad
//
//  Created by Azuany Mila Cerón on 11/8/25.
//
import SwiftUI

// MARK: - Shape Color Picker Component
struct ShapeColorPicker: View {
    let title: String
    @Binding var selectedShape: PlayerShape
    @Binding var selectedColor: PlayerColor
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
            
            // Shape picker
            VStack(alignment: .leading, spacing: 8) {
                Text("Shape")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(PlayerShape.allCases) { shape in
                            Button {
                                selectedShape = shape
                            } label: {
                                VStack(spacing: 6) {
                                    shape.view(color: selectedColor.color, size: 32)
                                        .frame(width: 60, height: 60)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(selectedShape == shape ? Color.accentColor.opacity(0.15) : Color.secondary.opacity(0.1))
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .strokeBorder(selectedShape == shape ? Color.accentColor : Color.clear, lineWidth: 2)
                                        )
                                    
                                    Text(shape.rawValue)
                                        .font(.caption2)
                                        .foregroundStyle(selectedShape == shape ? .primary : .secondary)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            
            // Color picker
            VStack(alignment: .leading, spacing: 8) {
                Text("Color")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 44))], spacing: 12) {
                    ForEach(PlayerColor.allCases) { colorOption in
                        Button {
                            selectedColor = colorOption
                        } label: {
                            Circle()
                                .fill(colorOption.color)
                                .frame(width: 44, height: 44)
                                .overlay(
                                    Circle()
                                        .strokeBorder(selectedColor == colorOption ? Color.primary : Color.clear, lineWidth: 3)
                                )
                                .overlay(
                                    Circle()
                                        .strokeBorder(Color.white, lineWidth: 1)
                                )
                                .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(colorOption.rawValue)
                    }
                }
            }
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Compact Shape Color Picker for Overlay
struct CompactShapeColorPicker: View {
    let title: String
    @Binding var selectedShape: PlayerShape
    @Binding var selectedColor: PlayerColor
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(title)
                    .font(.system(.callout, design: .rounded, weight: .medium))
                    .foregroundStyle(.primary)
                Spacer()
                // Preview
                selectedShape.view(color: selectedColor.color, size: 20)
            }
            
            // Shape picker - compact horizontal scroll
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(PlayerShape.allCases) { shape in
                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedShape = shape
                            }
                        } label: {
                            shape.view(color: selectedColor.color, size: 20)
                                .frame(width: 40, height: 40)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(selectedShape == shape ? selectedColor.color.opacity(0.2) : Color.primary.opacity(0.05))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .strokeBorder(selectedShape == shape ? selectedColor.color : Color.clear, lineWidth: 2)
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            
            // Color picker - compact grid
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 36))], spacing: 8) {
                ForEach(PlayerColor.allCases) { colorOption in
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedColor = colorOption
                        }
                    } label: {
                        Circle()
                            .fill(colorOption.color)
                            .frame(width: 36, height: 36)
                            .overlay(
                                Circle()
                                    .strokeBorder(selectedColor == colorOption ? Color.white : Color.clear, lineWidth: 2.5)
                            )
                            .overlay(
                                Circle()
                                    .strokeBorder(selectedColor == colorOption ? Color.primary : Color.primary.opacity(0.2), lineWidth: 1)
                            )
                            .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(colorOption.rawValue)
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.primary.opacity(0.05))
        )
    }
}
