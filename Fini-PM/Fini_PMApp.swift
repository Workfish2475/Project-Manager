//
//  Fini_PMApp.swift
//  Fini-PM
//
//  Created by Alexander Rivera on 4/4/25.
//
import SwiftUI
import SwiftData

@main
struct MyApp: App {
    @StateObject private var accentColor = AccentColorManager()
    @AppStorage("appearance") var appearance: Appearance = .system
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(accentColor)
                .modelContainer(for: [Tag.self, Project.self, Task.self])
        }
    }
}
