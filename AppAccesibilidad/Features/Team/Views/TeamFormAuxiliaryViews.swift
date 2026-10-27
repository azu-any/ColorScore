//
//  TeamFormAuxiliaryViews.swift
//  AppAccesibilidad
//
//  Created by Maeva Mazadiego on 07/11/25.
//

import SwiftUI

// MARK: - Team Name Edit View

struct TeamNameEditView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var teamName: String
    @State private var editedName: String = ""
    
    var body: some View {
        VStack(spacing: 0) {
            headerBar
            nameInputSection
            Spacer()
        }
        .background(Color(uiColor: .systemGray6))
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            editedName = teamName
        }
    }
    
    private var headerBar: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .foregroundStyle(.blue)
                    .frame(minWidth: 44, minHeight: 44)
            }
            .accessibilityLabel("Regresar")
            
            Spacer()
            
            Text("Nombre del equipo")
                .font(.headline.weight(.semibold))
                .accessibilityAddTraits(.isHeader)
            
            Spacer()
            
            Button(action: {
                teamName = editedName
                dismiss()
            }) {
                Text("Listo")
                    .foregroundStyle(.blue)
                    .fontWeight(.semibold)
                    .frame(minWidth: 44, minHeight: 44)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(Color(uiColor: .systemGray6))
    }
    
    private var nameInputSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            TextField("Nombre del equipo", text: $editedName)
                .padding()
                .background(Color(uiColor: .systemBackground))
                .font(.body)
            
            Text("Ingresa el nombre completo del equipo")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
        }
        .padding(.top, 20)
    }
}

// MARK: - Country & Division Picker Views

struct CountryPickerView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedCountry: String
    let countries: [String] = TeamFormOptions.availableCountries
    
    var body: some View {
        SelectionListPickerView(
            title: "País",
            options: countries,
            selection: $selectedCountry
        )
    }
}

struct DivisionPickerView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedDivision: String
    let divisions: [String]
    
    var body: some View {
        SelectionListPickerView(
            title: "División",
            options: divisions,
            selection: $selectedDivision
        )
    }
}

/// Shared list-based picker view used by `CountryPickerView` and `DivisionPickerView`.
struct SelectionListPickerView: View {
    @Environment(\.dismiss) private var dismiss
    let title: String
    let options: [String]
    @Binding var selection: String
    
    var body: some View {
        NavigationStack {
            List(options, id: \.self) { option in
                Button(action: {
                    selection = option
                    dismiss()
                }) {
                    HStack {
                        Text(option)
                            .foregroundStyle(.primary)
                        
                        Spacer()
                        
                        if option == selection {
                            Image(systemName: "checkmark")
                                .foregroundStyle(.blue)
                        }
                    }
                }
                .accessibilityAddTraits(option == selection ? .isSelected : [])
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Listo") {
                        dismiss()
                    }
                }
            }
        }
    }
}
