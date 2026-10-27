//
//  MenuSelectionRow.swift
//  AppAccesibilidad
//
//  Created by Maeva Mazadiego on 07/11/25.
//

import SwiftUI

/// A standardized form row presenting a dropdown menu for selecting a string option.
struct MenuSelectionRow: View {
    let title: String
    @Binding var selection: String
    let options: [String]
    let accessibilityHint: String
    
    var body: some View {
        HStack(spacing: 0) {
            Text(title)
                .foregroundStyle(.primary)
                .font(.body)
                .padding()
                .accessibilityHidden(true)
            
            Spacer()
            
            Menu {
                ForEach(options, id: \.self) { option in
                    Button(action: { selection = option }) {
                        HStack {
                            Text(option)
                            if option == selection {
                                Spacer()
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                HStack(spacing: 8) {
                    Text(selection)
                        .foregroundStyle(.secondary)
                        .font(.body)
                    
                    Image(systemName: "chevron.up.chevron.down")
                        .foregroundStyle(.secondary)
                        .font(.caption)
                }
                .padding()
                .frame(minHeight: 44)
                .contentShape(Rectangle())
            }
            .accessibilityLabel(title)
            .accessibilityValue(selection)
            .accessibilityHint(accessibilityHint)
        }
        .background(Color(uiColor: .systemBackground))
    }
}
