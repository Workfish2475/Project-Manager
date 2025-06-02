import SwiftUI

struct ColorSchemePicker: View {
    @AppStorage("appearance") var appearance: Appearance = .system
    @Environment(\.colorScheme) private var scheme 
    
    var body: some View {
        Picker("", selection: $appearance) {
            ForEach(Appearance.allCases, id: \.self) { option in
                Text(option.rawValue.capitalized)
                    .tag(option)
            }
        }
        
        .pickerStyle(.wheel)
        .navigationTitle("App theme")
        .preferredColorScheme(appearance.colorScheme == .none ? scheme : appearance.colorScheme)
    }
}

#Preview {
    ColorSchemePicker()
}
