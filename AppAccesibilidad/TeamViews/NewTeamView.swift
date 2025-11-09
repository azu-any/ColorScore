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
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var teamName: String = ""
    @State private var country: String = "Mexico"
    @State private var division: String = "Liga MX"
    @State private var selectedColorIndex: Int = 0 // Default to first color
    @State private var customColor: Color = .blue // For custom color picker
    @State private var useCustomColor: Bool = false // Toggle between preset and custom colors
    @State private var selectedLogoItem: PhotosPickerItem?
    @State private var selectedLogoImage: Image?
    @State private var logoImageData: Data?
    @FocusState private var isTeamNameFocused: Bool
    
    // Countries with football teams
    let countries = [
        "Argentina", "Brazil", "Mexico", "España", "Inglaterra", "Italia",
        "Alemania", "Francia", "Portugal", "Holanda", "Uruguay", "Colombia",
        "Chile", "Ecuador", "Perú", "Paraguay", "Venezuela", "Bolivia"
    ]
    
    // Mexico divisions
    let mexicoDivisions = [
        "Liga MX",
        "Liga de Expansión MX",
        "Segunda División",
        "Tercera División"
    ]
    
    // Team colors - Popular football team colors
    let teamColors: [Color] = [
        Color(red: 0.0, green: 0.3, blue: 0.6),   // Blue (Classic)
        Color(red: 0.8, green: 0.0, blue: 0.0),   // Red (Classic)
        Color(red: 0.0, green: 0.5, blue: 0.2),   // Green
        Color(red: 1.0, green: 0.65, blue: 0.0),  // Orange
        Color(red: 0.4, green: 0.0, blue: 0.6),   // Purple
        Color(red: 0.0, green: 0.7, blue: 0.8),   // Cyan
        Color(red: 1.0, green: 0.8, blue: 0.0),   // Yellow/Gold
        Color(red: 0.2, green: 0.2, blue: 0.2),   // Dark Gray/Black
        Color(red: 0.9, green: 0.9, blue: 0.9),   // White/Light Gray
        Color(red: 0.5, green: 0.0, blue: 0.0),   // Maroon
        Color(red: 0.0, green: 0.2, blue: 0.4),   // Navy Blue
        Color(red: 0.6, green: 0.2, blue: 0.8),   // Violet
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.title2)
                            .foregroundColor(.gray)
                            .frame(width: 44, height: 44)
                    }
                    
                    Spacer()
                    
                    Text("Nuevo equipo")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Button(action: {
                        // Save action
                        saveTeam()
                        dismiss()
                    }) {
                        Image(systemName: "checkmark")
                            .font(.title2)
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(teamName.isEmpty ? Color.gray : Color.blue)
                            .clipShape(Circle())
                    }
                    .disabled(teamName.isEmpty)
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
                .background(Color(uiColor: .systemGray6))
                
                // Form Content
                ScrollView {
                    VStack(spacing: 0) {
                        // Team Name
                        HStack {
                            Text("Nombre del equipo")
                                .foregroundColor(.primary)
                                .font(.body)
                            
                            Spacer()
                            
                            TextField("Nombre del equipo", text: $teamName)
                                .font(.body)
                                .multilineTextAlignment(.trailing)
                                .submitLabel(.done)
                                .focused($isTeamNameFocused)
                        }
                        .padding()
                        .background(Color(uiColor: .systemBackground))
                        .onTapGesture {
                            isTeamNameFocused = true
                        }
                        
                        Divider()
                            .padding(.leading)
                        
                        // Country
                        HStack(spacing: 0) {
                            Text("País")
                                .foregroundColor(.primary)
                                .font(.body)
                                .padding()
                            
                            Spacer()
                            
                            Menu {
                                ForEach(countries, id: \.self) { countryOption in
                                    Button(action: {
                                        country = countryOption
                                    }) {
                                        HStack {
                                            Text(countryOption)
                                            if countryOption == country {
                                                Spacer()
                                                Image(systemName: "checkmark")
                                            }
                                        }
                                    }
                                }
                            } label: {
                                HStack(spacing: 8) {
                                    Text(country)
                                        .foregroundColor(.gray)
                                        .font(.body)
                                    
                                    Image(systemName: "chevron.up.chevron.down")
                                        .foregroundColor(.gray)
                                        .font(.caption)
                                }
                                .padding()
                                .contentShape(Rectangle())
                            }
                        }
                        .background(Color(uiColor: .systemBackground))
                        
                        Divider()
                            .padding(.leading)
                        
                        // Division
                        HStack(spacing: 0) {
                            Text("División")
                                .foregroundColor(.primary)
                                .font(.body)
                                .padding()
                            
                            Spacer()
                            
                            Menu {
                                ForEach(mexicoDivisions, id: \.self) { divisionOption in
                                    Button(action: {
                                        division = divisionOption
                                    }) {
                                        HStack {
                                            Text(divisionOption)
                                            if divisionOption == division {
                                                Spacer()
                                                Image(systemName: "checkmark")
                                            }
                                        }
                                    }
                                }
                            } label: {
                                HStack(spacing: 8) {
                                    Text(division)
                                        .foregroundColor(.gray)
                                        .font(.body)
                                    
                                    Image(systemName: "chevron.up.chevron.down")
                                        .foregroundColor(.gray)
                                        .font(.caption)
                                }
                                .padding()
                                .contentShape(Rectangle())
                            }
                        }
                        .background(Color(uiColor: .systemBackground))
                        
                        Divider()
                            .padding(.leading)
                        
                        // Team Logo
                        PhotosPicker(selection: $selectedLogoItem, matching: .images) {
                            HStack(spacing: 16) {
                                if let selectedLogoImage {
                                    selectedLogoImage
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 60, height: 60)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                } else {
                                    Image(systemName: "photo")
                                        .font(.system(size: 40))
                                        .foregroundColor(.gray)
                                        .frame(width: 60, height: 60)
                                        .background(Color(uiColor: .systemGray5))
                                        .cornerRadius(8)
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Logo del equipo")
                                        .foregroundColor(.primary)
                                        .font(.body)
                                    
                                    Text("Selecciona el logo del equipo")
                                        .foregroundColor(.gray)
                                        .font(.caption)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                                    .font(.footnote)
                            }
                            .padding()
                            .background(Color(uiColor: .systemBackground))
                        }
                        
                        Divider()
                            .padding(.leading)
                        
                        // Team Color Selection
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Color del equipo")
                                    .foregroundColor(.primary)
                                    .font(.body)
                                
                                Spacer()
                            }
                            .padding(.horizontal)
                            .padding(.top)
                            
                            Text("Elige un color predefinido o personalizado")
                                .foregroundColor(.gray)
                                .font(.caption)
                                .padding(.horizontal)
                            
                            // Color mode toggle
                            Picker("", selection: $useCustomColor) {
                                Text("Predefinidos").tag(false)
                                Text("Personalizado").tag(true)
                            }
                            .pickerStyle(.segmented)
                            .padding(.horizontal)
                            
                            if useCustomColor {
                                // Custom Color Picker
                                VStack(spacing: 16) {
                                    // Color preview
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
                                            .font(.system(size: 50))
                                            .foregroundColor(.white)
                                            .shadow(color: Color.black.opacity(0.3), radius: 4, x: 0, y: 2)
                                    }
                                    .padding(.horizontal)
                                    
                                    // Color picker
                                    ColorPicker("Seleccionar color", selection: $customColor, supportsOpacity: false)
                                        .padding(.horizontal)
                                }
                            } else {
                                // Preset Color Grid
                                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 4), spacing: 12) {
                                    ForEach(Array(teamColors.enumerated()), id: \.offset) { index, color in
                                        ColorButton(
                                            color: color,
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
                        .padding(.bottom)
                        .background(Color(uiColor: .systemBackground))
                    }
                }
            }
            .background(Color(uiColor: .systemGray6))
            .navigationBarHidden(true)
            .onChange(of: selectedLogoItem) { _, newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        selectedLogoImage = Image(uiImage: uiImage)
                        logoImageData = data
                    }
                }
            }
        }
    }
    
    // Save team to SwiftData
    private func saveTeam() {
        guard !teamName.isEmpty else { return }
        
        let selectedColor = useCustomColor ? customColor : teamColors[selectedColorIndex]
        let colorHex = selectedColor.toHex()
        
        let newTeam = CustomTeam(
            name: teamName,
            country: country,
            division: division,
            logoImageData: logoImageData,
            teamColorHex: colorHex
        )
        
        modelContext.insert(newTeam)
        
        do {
            try modelContext.save()
        } catch {
            print("Error saving team: \(error)")
        }
    }
    
    // Helper function to get the selected color
    func getSelectedColor() -> Color {
        return useCustomColor ? customColor : teamColors[selectedColorIndex]
    }
}

// MARK: - Color Button
struct ColorButton: View {
    let color: Color
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(color)
                    .frame(width: 60, height: 60)
                    .overlay(
                        Circle()
                            .strokeBorder(Color.white, lineWidth: 3)
                    )
                    .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                        .background(
                            Circle()
                                .fill(Color.black.opacity(0.3))
                                .frame(width: 32, height: 32)
                        )
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Team Name Edit View
struct TeamNameEditView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var teamName: String
    @State private var editedName: String = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
                
                Spacer()
                
                Text("Nombre del equipo")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button(action: {
                    teamName = editedName
                    dismiss()
                }) {
                    Text("Listo")
                        .foregroundColor(.blue)
                        .fontWeight(.semibold)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
            .background(Color(uiColor: .systemGray6))
            
            // Text field
            VStack(alignment: .leading, spacing: 8) {
                TextField("Nombre del equipo", text: $editedName)
                    .padding()
                    .background(Color(uiColor: .systemBackground))
                    .font(.body)
                
                Text("Ingresa el nombre completo del equipo")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
            }
            .padding(.top, 20)
            
            Spacer()
        }
        .background(Color(uiColor: .systemGray6))
        .navigationBarHidden(true)
        .onAppear {
            editedName = teamName
        }
    }
}

// MARK: - Country Picker View
struct CountryPickerView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedCountry: String
    
    let countries = [
        "Argentina", "Brazil", "Mexico", "España", "Inglaterra", "Italia",
        "Alemania", "Francia", "Portugal", "Holanda", "Uruguay", "Colombia",
        "Chile", "Ecuador", "Perú", "Paraguay", "Venezuela", "Bolivia"
    ]
    
    var body: some View {
        NavigationView {
            List(countries, id: \.self) { country in
                Button(action: {
                    selectedCountry = country
                    dismiss()
                }) {
                    HStack {
                        Text(country)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        if country == selectedCountry {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            .navigationTitle("País")
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

// MARK: - Division Picker View
struct DivisionPickerView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedDivision: String
    let divisions: [String]
    
    var body: some View {
        NavigationView {
            List(divisions, id: \.self) { division in
                Button(action: {
                    selectedDivision = division
                    dismiss()
                }) {
                    HStack {
                        Text(division)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        if division == selectedDivision {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            .navigationTitle("División")
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

struct NewTeamView_Previews: PreviewProvider {
    static var previews: some View {
        NewTeamView()
    }
}
