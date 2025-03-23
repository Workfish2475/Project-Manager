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
        ZStack (alignment: .bottomTrailing) {
            TabView(selection: $selectedItem) {
                ProjectView()
                    .tabItem {
                        Label("Projects", systemImage: "hammer.fill")
                    }
                
                ProjProgressView()
                    .tabItem {
                        Label("Progress", systemImage: "chart.bar.fill")
                    }
            }
            
            .tint(accentColorManager.accentColor)
            .preferredColorScheme(appearance.colorScheme)
        }
    }
}
