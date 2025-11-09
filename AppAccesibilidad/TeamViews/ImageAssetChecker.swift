//
//  ImageAssetChecker.swift
//  AppAccesibilidad
//
//  Helper for checking which team images are missing
//  Run this in a test or debug view to see which images need to be added
//

import UIKit

struct ImageAssetChecker {
    
    // All team image names from TeamSelectionView
    static let requiredImages = [
        // México
        "america", "chivas", "tigres", "monterrey", "cruzazul", "pumas", "toluca", "santos", "leon", "atlas",
        
        // MLS
        "intermiami", "lafc", "lagalaxy", "nycfc", "atlanta",
        
        // Canadá
        "toronto", "montreal", "vancouver", "forge", "pacific",
        
        // Costa Rica
        "saprissa", "alajuelense", "herediano", "cartagines", "perezZeledon",
        
        // España
        "realmadrid", "barcelona", "atletico", "sevilla", "realsociedad",
        
        // Inglaterra
        "mancity", "liverpool", "arsenal", "chelsea", "manutd",
        
        // Italia
        "juventus", "acmilan", "inter", "napoli", "roma",
        
        // Alemania
        "bayern", "dortmund", "leipzig", "leverkusen", "frankfurt",
        
        // Francia
        "psg", "marseille", "monaco", "lyon", "lille",
        
        // Brasil
        "flamengo", "palmeiras", "corinthians", "saopaulo", "fluminense",
        
        // Argentina
        "boca", "river", "racing", "sanlorenzo", "independiente",
        
        // Colombia
        "nacional", "millonarios", "americacali", "deportivocali", "medellin",
        
        // Uruguay
        "nacionaluy", "penarol", "defensor", "danubio", "liverpooluy",
        
        // Chile
        "colocolo", "uchile", "catolica", "unionespanola", "audax",
        
        // Japón
        "kawasaki", "yokohama", "urawa", "kashima", "fctokyo",
        
        // Arabia Saudita
        "alhilal", "alnassr", "alittihad", "alahli", "alshabab",
        
        // Corea del Sur
        "jeonbuk", "ulsan", "pohang", "seoul", "suwon",
        
        // Egipto
        "alahlyegypt", "zamalek", "pyramids", "almasry", "smouha",
        
        // Marruecos
        "wydad", "raja", "fus", "berkane", "far",
        
        // Australia
        "sydney", "melbournecity", "victory", "brisbane", "perth"
    ]
    
    /// Check which images are missing from the asset catalog
    static func checkMissingImages() -> [String] {
        var missingImages: [String] = []
        
        for imageName in requiredImages {
            if UIImage(named: imageName) == nil {
                missingImages.append(imageName)
            }
        }
        
        return missingImages
    }
    
    /// Check which images exist in the asset catalog
    static func checkExistingImages() -> [String] {
        var existingImages: [String] = []
        
        for imageName in requiredImages {
            if UIImage(named: imageName) != nil {
                existingImages.append(imageName)
            }
        }
        
        return existingImages
    }
    
    /// Print a report to the console
    static func printReport() {
        let missing = checkMissingImages()
        let existing = checkExistingImages()
        
        print("========================================")
        print("TEAM IMAGES REPORT")
        print("========================================")
        print("Total images required: \(requiredImages.count)")
        print("Images found: \(existing.count)")
        print("Images missing: \(missing.count)")
        print("")
        
        if !missing.isEmpty {
            print("❌ MISSING IMAGES:")
            for image in missing {
                print("   - \(image)")
            }
            print("")
        }
        
        if !existing.isEmpty {
            print("✅ FOUND IMAGES:")
            for image in existing.sorted() {
                print("   - \(image)")
            }
        }
        
        print("========================================")
    }
    
    /// Get progress percentage
    static func getProgress() -> Double {
        let existing = checkExistingImages().count
        let total = requiredImages.count
        return Double(existing) / Double(total) * 100.0
    }
}

// MARK: - Debug View for Testing
#if DEBUG
import SwiftUI

struct ImageCheckerDebugView: View {
    @State private var missingImages: [String] = []
    @State private var existingImages: [String] = []
    @State private var progress: Double = 0.0
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Progress")) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Images Added")
                            .font(.headline)
                        
                        ProgressView(value: progress, total: 100.0)
                        
                        Text("\(existingImages.count) of \(ImageAssetChecker.requiredImages.count) images")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 8)
                }
                
                if !existingImages.isEmpty {
                    Section(header: Text("✅ Found Images (\(existingImages.count))")) {
                        ForEach(existingImages.sorted(), id: \.self) { imageName in
                            HStack {
                                if let image = UIImage(named: imageName) {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 40, height: 40)
                                }
                                Text(imageName)
                                    .font(.system(.body, design: .monospaced))
                            }
                        }
                    }
                }
                
                if !missingImages.isEmpty {
                    Section(header: Text("❌ Missing Images (\(missingImages.count))")) {
                        ForEach(missingImages, id: \.self) { imageName in
                            HStack {
                                Image(systemName: "photo")
                                    .frame(width: 40, height: 40)
                                    .foregroundColor(.red)
                                Text(imageName)
                                    .font(.system(.body, design: .monospaced))
                            }
                        }
                    }
                }
            }
            .navigationTitle("Team Images Check")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Refresh") {
                        checkImages()
                    }
                }
            }
            .onAppear {
                checkImages()
            }
        }
    }
    
    private func checkImages() {
        missingImages = ImageAssetChecker.checkMissingImages()
        existingImages = ImageAssetChecker.checkExistingImages()
        progress = ImageAssetChecker.getProgress()
        
        // Also print to console
        ImageAssetChecker.printReport()
    }
}

#Preview {
    ImageCheckerDebugView()
}
#endif
