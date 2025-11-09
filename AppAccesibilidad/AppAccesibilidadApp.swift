//
//  AppAccesibilidadApp.swift
//  AppAccesibilidad
//
//  Created by Azuany Mila Cerón on 9/24/25.
//

import SwiftUI
import SwiftData

@main
struct AppAccesibilidadApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
            CustomTeam.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            HomeView()
        }
        .modelContainer(sharedModelContainer)
    }
}
