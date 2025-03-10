import SwiftUI

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
