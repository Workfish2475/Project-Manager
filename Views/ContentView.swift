import SwiftUI

struct ContentView: View {
    @State private var selectedItem: Int = 0
    
    @State private var showingSettings: Bool = false
    @State private var showingEntry: Bool = false
    @FocusState private var showingEntryField
    
    @State private var projectEntry: String = ""
    @State private var projectColor: Color = Color.allList[0]
    
    @State private var confirmCancel: Bool = false
    
    @Namespace private var animation
    
    @Environment(\.modelContext) private var context
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
