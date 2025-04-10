//
//  ContentView.swift
//  Fini-PM
//
//  Created by Alexander Rivera on 4/4/25.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedItem: Int = 0
    
    @EnvironmentObject var accentColorManager: AccentColorManager
    @AppStorage("appearance") var appearance: Appearance = .system
    
    var body: some View {
        NavigationStack {
            TabView(selection: $selectedItem) {
                ProjectView()
                    .tabItem {
                        Label("Projects", systemImage: "hammer.fill")
                    }
                    .tag(0)
                    
      
                ProjProgressView()
                    .tabItem {
                        Label("Progress", systemImage: "chart.bar.fill")
                    }
                    .tag(1)
                }
                .tint(accentColorManager.accentColor)
                .preferredColorScheme(appearance.colorScheme)
                .navigationTitle(selectedItem == 0 ? "Projects" : "Progress")
        }
    }
}

#Preview {
    @Previewable @StateObject var accentColor = AccentColorManager()
    @Previewable @AppStorage("appearance") var appearance: Appearance = .system
    
    ContentView()
        .environmentObject(accentColor)
        .modelContainer(for: [Tag.self, Project.self, Task.self])
}
