//
//  NewTeamView.swift
//  AppAccesibilidad
//
//  Created by Maeva Mazadiego on 07/11/25.
//

import SwiftUI
import PhotosUI
import SwiftData

struct NewTeamView: View {
    // MARK: Environment
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    
    // MARK: Form State
    @State private var teamName: String = ""
    @State private var country: String = "México"
    @State private var division: String = "Liga MX"
    @State private var selectedColorIndex: Int = 0
    @State private var customColor: Color = .blue
    @State private var useCustomColor: Bool = false
    @State private var selectedLogoItem: PhotosPickerItem?
    @State private var selectedLogoImage: Image?
    @State private var logoImageData: Data?
    @FocusState private var isTeamNameFocused: Bool
    
    // MARK: Computed Properties
    private var isFormValid: Bool {
        !teamName.isEmpty
    }
    
    private var selectedColor: Color {
        useCustomColor ? customColor : TeamFormOptions.presetColorOptions[selectedColorIndex].color
    }
    
    // MARK: Body
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                headerBar
                formContent
            }
            .background(Color(uiColor: .systemGray6))
            .toolbar(.hidden, for: .navigationBar)
            .onChange(of: selectedLogoItem) { _, newItem in
                Task {
                    await loadLogo(from: newItem)
                }
            }
        }
    }
}

// MARK: - Subviews

private extension NewTeamView {
    /// Top navigation header with cancel and save actions.
    var headerBar: some View {
        HStack {
            cancelButton
            Spacer()
            headerTitle
            Spacer()
            saveButton
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(Color(uiColor: .systemGray6))
    }
    
    var cancelButton: some View {
        Button(action: { dismiss() }) {
            Image(systemName: "xmark")
                .font(.title2)
                .foregroundStyle(.secondary)
                .frame(minWidth: 44, minHeight: 44)
                .contentShape(Rectangle())
        }
        .accessibilityLabel("Cancelar")
        .accessibilityHint("Cierra el formulario sin guardar cambios")
    }
    
    var headerTitle: some View {
        Text("Nuevo equipo")
            .font(.headline.weight(.semibold))
            .accessibilityAddTraits(.isHeader)
    }
    
    var saveButton: some View {
        Button(action: {
            saveTeam()
            dismiss()
        }) {
            Image(systemName: "checkmark")
                .font(.title2)
                .foregroundStyle(.white)
                .frame(width: 44, height: 44)
                .background(isFormValid ? Color.blue : Color.gray)
                .clipShape(Circle())
        }
        .disabled(!isFormValid)
        .accessibilityLabel("Guardar equipo")
        .accessibilityHint(
            isFormValid
                ? "Guarda el nuevo equipo personalizado"
                : "Ingresa primero el nombre del equipo para poder guardar"
        )
    }
    
    /// Main scrollable form container.
    var formContent: some View {
        ScrollView {
            VStack(spacing: 0) {
                teamNameRow
                formDivider
                countryRow
                formDivider
                divisionRow
                formDivider
                logoPickerRow
                formDivider
                TeamColorSelectionSection(
                    useCustomColor: $useCustomColor,
                    selectedColorIndex: $selectedColorIndex,
                    customColor: $customColor,
                    presetOptions: TeamFormOptions.presetColorOptions
                )
            }
        }
    }
    
    var formDivider: some View {
        Divider()
            .padding(.leading)
    }
    
    /// Row for entering the custom team's name.
    var teamNameRow: some View {
        HStack {
            Text("Nombre del equipo")
                .foregroundStyle(.primary)
                .font(.body)
            
            Spacer()
            
            TextField("Nombre del equipo", text: $teamName)
                .font(.body)
                .multilineTextAlignment(.trailing)
                .submitLabel(.done)
                .focused($isTeamNameFocused)
                .accessibilityLabel("Nombre del equipo")
        }
        .padding()
        .frame(minHeight: 44)
        .background(Color(uiColor: .systemBackground))
        .onTapGesture {
            isTeamNameFocused = true
        }
    }
    
    /// Row for selecting the team's country.
    var countryRow: some View {
        MenuSelectionRow(
            title: "País",
            selection: $country,
            options: TeamFormOptions.availableCountries,
            accessibilityHint: "Toca dos veces para cambiar el país del equipo"
        )
    }
    
    /// Row for selecting the team's league division.
    var divisionRow: some View {
        MenuSelectionRow(
            title: "División",
            selection: $division,
            options: TeamFormOptions.availableMexicoDivisions,
            accessibilityHint: "Toca dos veces para cambiar la división del equipo"
        )
    }
    
    /// Row for picking a team logo image from the photo library.
    var logoPickerRow: some View {
        PhotosPicker(selection: $selectedLogoItem, matching: .images) {
            HStack(spacing: 16) {
                logoThumbnail
                logoDescription
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundStyle(.secondary)
                    .font(.footnote)
                    .accessibilityHidden(true)
            }
            .padding()
            .background(Color(uiColor: .systemBackground))
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Logo del equipo")
        .accessibilityValue(selectedLogoImage == nil ? "Sin seleccionar" : "Imagen seleccionada")
        .accessibilityHint("Abre tu galería de fotos para elegir el escudo del equipo")
        .accessibilityAddTraits(.isButton)
    }
    
    @ViewBuilder
    var logoThumbnail: some View {
        if let selectedLogoImage {
            selectedLogoImage
                .resizable()
                .scaledToFill()
                .frame(width: 60, height: 60)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .accessibilityHidden(true)
        } else {
            Image(systemName: "photo")
                .font(.title)
                .foregroundStyle(.secondary)
                .frame(width: 60, height: 60)
                .background(Color(uiColor: .systemGray5))
                .cornerRadius(8)
                .accessibilityHidden(true)
        }
    }
    
    var logoDescription: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Logo del equipo")
                .foregroundStyle(.primary)
                .font(.body)
            
            Text(selectedLogoImage == nil ? "Selecciona el logo del equipo" : "Logo seleccionado")
                .foregroundStyle(.secondary)
                .font(.caption)
        }
    }
}

// MARK: - Actions & Helpers

extension NewTeamView {
    /// Returns the currently active team color (either custom or preset).
    func getSelectedColor() -> Color {
        selectedColor
    }
    
    /// Loads the selected photo item into an Image and raw Data for persistence.
    private func loadLogo(from item: PhotosPickerItem?) async {
        guard let item,
              let data = try? await item.loadTransferable(type: Data.self),
              let uiImage = UIImage(data: data) else {
            return
        }
        selectedLogoImage = Image(uiImage: uiImage)
        logoImageData = data
    }
    
    /// Persists the newly configured team in SwiftData.
    private func saveTeam() {
        guard isFormValid else { return }
        
        let newTeam = CustomTeam(
            name: teamName,
            country: country,
            division: division,
            logoImageData: logoImageData,
            teamColorHex: selectedColor.toHex()
        )
        
        modelContext.insert(newTeam)
        
        do {
            try modelContext.save()
        } catch {
            print("Error saving team: \(error)")
        }
    }
}

struct NewTeamView_Previews: PreviewProvider {
    static var previews: some View {
        NewTeamView()
    }
}
