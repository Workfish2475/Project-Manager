import SwiftUI

// FIXME: change not updating when switching from light to system def while in dark mode.
struct ColorSchemePicker: View {
    @AppStorage("appearance") var appearance: Appearance = .system
    @Environment(\.colorScheme) private var scheme 
    
    var body: some View {
        NavigationStack {
            List {
                Picker("", selection: $appearance) {
                    ForEach(Appearance.allCases, id: \.self) { option in
                        Text(option.rawValue.capitalized)
                            .tag(option)
                    }
                }
                .pickerStyle(.inline)
            }
            .navigationTitle("App theme")
        }
        .preferredColorScheme(appearance.colorScheme == .none ? scheme : appearance.colorScheme)
    }
}

#Preview {
    ColorSchemePicker()
}
