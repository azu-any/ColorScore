//
//  TeamColorSelectionSection.swift
//  AppAccesibilidad
//
//  Created by Maeva Mazadiego on 07/11/25.
//

import SwiftUI

/// Form section allowing the user to pick either a preset color or a custom color for a team.
struct TeamColorSelectionSection: View {
    @Binding var useCustomColor: Bool
    @Binding var selectedColorIndex: Int
    @Binding var customColor: Color
    let presetOptions: [TeamColorOption]
    
    private let colorGridColumns = Array(
        repeating: GridItem(.flexible(), spacing: 12),
        count: 4
    )
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader
            colorModePicker
            
            if useCustomColor {
                customColorPickerView
            } else {
                presetColorGridView
            }
        }
        .padding(.bottom)
        .background(Color(uiColor: .systemBackground))
    }
    
    private var sectionHeader: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Color del equipo")
                    .foregroundStyle(.primary)
                    .font(.body)
                    .accessibilityAddTraits(.isHeader)
                
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top)
            
            Text("Elige un color predefinido o personalizado")
                .foregroundStyle(.secondary)
                .font(.caption)
                .padding(.horizontal)
        }
    }
    
    private var colorModePicker: some View {
        Picker("Modo de selección de color", selection: $useCustomColor) {
            Text("Predefinidos").tag(false)
            Text("Personalizado").tag(true)
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
        .accessibilityLabel("Modo de selección de color")
    }
    
    private var customColorPickerView: some View {
        VStack(spacing: 16) {
            customColorPreviewBanner
            
            ColorPicker(
                "Seleccionar color personalizado",
                selection: $customColor,
                supportsOpacity: false
            )
            .padding(.horizontal)
            .frame(minHeight: 44)
        }
    }
    
    private var customColorPreviewBanner: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(customColor)
                .frame(height: 120)
                .overlay(
                    LinearGradient(
                        colors: [
                            Color.black.opacity(0.1),
                            Color.black.opacity(0.2)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            
            Image(systemName: "shield.fill")
                .font(.largeTitle)
                .foregroundStyle(.white)
                .shadow(color: Color.black.opacity(0.3), radius: 4, x: 0, y: 2)
        }
        .padding(.horizontal)
        .accessibilityHidden(true)
    }
    
    private var presetColorGridView: some View {
        LazyVGrid(columns: colorGridColumns, spacing: 12) {
            ForEach(Array(presetOptions.enumerated()), id: \.element.id) { index, option in
                ColorButton(
                    color: option.color,
                    colorName: option.name,
                    isSelected: selectedColorIndex == index && !useCustomColor,
                    action: {
                        selectedColorIndex = index
                    }
                )
            }
        }
        .padding(.horizontal)
    }
}
