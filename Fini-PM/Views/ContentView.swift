//
//  ContentView.swift
//  Fini-PM
//
//  Created by Alexander Rivera on 4/4/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var selectedItem: Int = 0
    
    @EnvironmentObject var accentColorManager: AccentColorManager
    @AppStorage("appearance") var appearance: Appearance = .system
    
    var body: some View {
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
    }
}

#Preview {
    @Previewable @StateObject var accentColor = AccentColorManager()
    @Previewable @AppStorage("appearance") var appearance: Appearance = .system
    
    let container = try! ModelContainer(
        for: Tag.self, Project.self, Task.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    
    ContentView()
        .environmentObject(accentColor)
        .modelContainer(container)
}
