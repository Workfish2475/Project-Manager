import SwiftUI

struct Settings: View {
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var accentColorManager: AccentColorManager
    @AppStorage("appearance") var appearance: Appearance = .system
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("General")) {
                    NavigationLink(destination: TagPickerView()) {
                        Label("Tags", systemImage: "tag")
                    }
                }
                
                Section(header: Text("Appearance")) {
                    NavigationLink(destination: ColorSchemePicker()){
                        Label("App theme", systemImage: "sun.lefthalf.filled")
                    }
                    
                    NavigationLink(destination: AccentColorView()) {
                        Label("Accent color", systemImage: "paintpalette")
                    }
                }
                
                Section(header: Text("About")) {
                    Link(destination: URL(string: "https://workfish2475.github.io")!) {
                        HStack (spacing: 20) {
                            Image(systemName: "safari")
                                .imageScale(.large)
                            
                            Text("Website")
                                .tint(.primary)
                        }
                    }
                }
                
                Section {
                    HStack {
                        Spacer()
                        
                        VStack {
                            Spacer()
                            
                            Text("Fini")
                                .font(.headline.bold())
                                .foregroundStyle(Color(uiColor: .secondaryLabel))
                            
                            Text("Made by Alex")
                                .font(.caption)
                                .foregroundStyle(Color(uiColor: .secondaryLabel))
                        }
                        
                        Spacer()
                    }
                }
                
                .listRowBackground(colorScheme == .light ? Color(uiColor: .secondarySystemBackground) : Color(uiColor: .systemBackground))
            }

            .tint(accentColorManager.accentColor)
            .accentColor(accentColorManager.accentColor)
            .preferredColorScheme(appearance.colorScheme)
            
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "x.circle.fill")
                            .symbolRenderingMode(.hierarchical)
                            .imageScale(.large)
                            .foregroundStyle(Color(uiColor: .systemGray))
                    }
                }
            }
        }
        
        .tint(accentColorManager.accentColor)
        .accentColor(accentColorManager.accentColor)
        .preferredColorScheme(appearance.colorScheme)
    }
}

#Preview {
    Settings()
        .modelContainer(for: [Tag.self, Project.self])
        .environmentObject(AccentColorManager())
}
