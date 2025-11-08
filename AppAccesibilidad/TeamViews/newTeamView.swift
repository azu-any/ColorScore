//
//  newTeamView.swift
//  AppAccesibilidad
//
//  Created by Maeva Mazadiego on 07/11/25.
//

import SwiftUI

struct NewTeamView: View {
    @Environment(\.dismiss) var dismiss
    @State private var teamName: String = "Cuervos de nue..."
    @State private var country: String = "Mexico"
    @State private var division: String = "Mexico"
    @State private var changeTeamColor: Bool = true
    @State private var selectedColorIndex: Int = 6 // Orange color selected by default
    
    // Team colors
    let teamColors: [[Color]] = [
        [Color(red: 1.0, green: 0.6, blue: 0.0)], // Orange (large)
        [Color(red: 0.0, green: 0.3, blue: 0.4), Color(red: 0.0, green: 0.3, blue: 0.6), Color(red: 0.3, green: 0.2, blue: 0.5)],
        [Color(red: 0.2, green: 0.6, blue: 0.6), Color(red: 0.7, green: 0.1, blue: 0.1), Color(red: 0.5, green: 0.3, blue: 0.8)],
        [Color(red: 1.0, green: 0.6, blue: 0.0), Color(red: 0.4, green: 0.6, blue: 1.0), Color(red: 0.9, green: 0.2, blue: 0.5)]
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
                        dismiss()
                    }) {
                        Image(systemName: "checkmark")
                            .font(.title2)
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(Color.blue)
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
                .background(Color(uiColor: .systemGray6))
                
                // Form Content
                ScrollView {
                    VStack(spacing: 0) {
                        // Team Name
                        NavigationLink(destination: Text("Edit Team Name")) {
                            HStack {
                                Text("Nombre del equipo")
                                    .foregroundColor(.primary)
                                    .font(.body)
                                
                                Spacer()
                                
                                Text(teamName)
                                    .foregroundColor(.gray)
                                    .font(.body)
                                    .lineLimit(1)
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                                    .font(.footnote)
                            }
                            .padding()
                            .background(Color(uiColor: .systemBackground))
                        }
                        
                        Divider()
                            .padding(.leading)
                        
                        // Country
                        HStack {
                            Text("País")
                                .foregroundColor(.primary)
                                .font(.body)
                            
                            Spacer()
                            
                            Text(country)
                                .foregroundColor(.gray)
                                .font(.body)
                            
                            Image(systemName: "chevron.up.chevron.down")
                                .foregroundColor(.gray)
                                .font(.caption)
                        }
                        .padding()
                        .background(Color(uiColor: .systemBackground))
                        
                        Divider()
                            .padding(.leading)
                        
                        // Team Logo
                        NavigationLink(destination: Text("Edit Team Logo")) {
                            HStack(spacing: 16) {
                                Image(systemName: "photo")
                                    .font(.system(size: 40))
                                    .foregroundColor(.gray)
                                    .frame(width: 60, height: 60)
                                    .background(Color(uiColor: .systemGray5))
                                    .cornerRadius(8)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Logo del equipo")
                                        .foregroundColor(.primary)
                                        .font(.body)
                                    
                                    Text("En png")
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
                        
                        // Division
                        HStack {
                            Text("División")
                                .foregroundColor(.primary)
                                .font(.body)
                            
                            Spacer()
                            
                            Text(division)
                                .foregroundColor(.gray)
                                .font(.body)
                            
                            Image(systemName: "chevron.up.chevron.down")
                                .foregroundColor(.gray)
                                .font(.caption)
                        }
                        .padding()
                        .background(Color(uiColor: .systemBackground))
                        
                        Divider()
                            .padding(.leading)
                        
                        // Team Figure
                        NavigationLink(destination: Text("Edit Team Figure")) {
                            HStack(spacing: 16) {
                                Image(systemName: "photo")
                                    .font(.system(size: 40))
                                    .foregroundColor(.gray)
                                    .frame(width: 60, height: 60)
                                    .background(Color(uiColor: .systemGray5))
                                    .cornerRadius(8)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Figura del equipo")
                                        .foregroundColor(.primary)
                                        .font(.body)
                                    
                                    Text("Para identificar en partido")
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
                        
                        // Change Team Color Toggle
                        HStack {
                            Text("Cambiar color del equipo")
                                .foregroundColor(.primary)
                                .font(.body)
                            
                            Spacer()
                            
                            Toggle("", isOn: $changeTeamColor)
                                .labelsHidden()
                        }
                        .padding()
                        .background(Color(uiColor: .systemBackground))
                        
                        // Color Picker
                        if changeTeamColor {
                            VStack(spacing: 20) {
                                // Large color preview
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(getSelectedColor())
                                    .frame(width: 140, height: 140)
                                    .padding(.top, 20)
                                
                                // Color palette
                                VStack(spacing: 16) {
                                    ForEach(0..<teamColors.count, id: \.self) { rowIndex in
                                        HStack(spacing: 16) {
                                            ForEach(0..<teamColors[rowIndex].count, id: \.self) { colIndex in
                                                let colorIndex = getColorIndex(row: rowIndex, col: colIndex)
                                                
                                                if rowIndex == 0 && colIndex == 0 {
                                                    // Large orange circle
                                                    Circle()
                                                        .fill(teamColors[rowIndex][colIndex])
                                                        .frame(width: 70, height: 70)
                                                        .overlay(
                                                            Circle()
                                                                .stroke(Color.white, lineWidth: selectedColorIndex == colorIndex ? 3 : 0)
                                                        )
                                                        .onTapGesture {
                                                            selectedColorIndex = colorIndex
                                                        }
                                                } else {
                                                    // Regular circles
                                                    Circle()
                                                        .fill(teamColors[rowIndex][colIndex])
                                                        .frame(width: 50, height: 50)
                                                        .overlay(
                                                            Circle()
                                                                .stroke(Color.white, lineWidth: selectedColorIndex == colorIndex ? 3 : 0)
                                                        )
                                                        .onTapGesture {
                                                            selectedColorIndex = colorIndex
                                                        }
                                                }
                                            }
                                            
                                            // Add button in last row
                                            if rowIndex == teamColors.count - 1 {
                                                Circle()
                                                    .fill(Color(uiColor: .systemGray5))
                                                    .frame(width: 50, height: 50)
                                                    .overlay(
                                                        Image(systemName: "plus")
                                                            .foregroundColor(.gray)
                                                            .font(.title3)
                                                    )
                                                    .onTapGesture {
                                                        // Add custom color
                                                    }
                                            }
                                        }
                                    }
                                }
                                
                                // Page indicator
                                HStack(spacing: 8) {
                                    Circle()
                                        .fill(Color.black)
                                        .frame(width: 8, height: 8)
                                    
                                    Circle()
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(width: 8, height: 8)
                                }
                                .padding(.bottom, 20)
                            }
                            .frame(maxWidth: .infinity)
                            .background(Color(uiColor: .systemBackground))
                        }
                    }
                }
            }
            .background(Color(uiColor: .systemGray6))
            .navigationBarHidden(true)
        }
    }
    
    // Helper function to get the selected color
    func getSelectedColor() -> Color {
        var currentIndex = 0
        for row in teamColors {
            for color in row {
                if currentIndex == selectedColorIndex {
                    return color
                }
                currentIndex += 1
            }
        }
        return Color.orange
    }
    
    // Helper function to get color index from row and column
    func getColorIndex(row: Int, col: Int) -> Int {
        var index = 0
        for r in 0..<row {
            index += teamColors[r].count
        }
        return index + col
    }
}

struct NewTeamView_Previews: PreviewProvider {
    static var previews: some View {
        NewTeamView()
    }
}
