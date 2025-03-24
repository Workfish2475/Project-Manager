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
