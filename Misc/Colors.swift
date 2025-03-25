import SwiftUI

struct colorPickerView: View {
    @EnvironmentObject var accentColorManager: AccentColorManager
    @State private var colorpick: Color = AccentColorManager().accentColor
    
    var body: some View {
        colorGrid()
    }
    
    @ViewBuilder
    func colorGrid() -> some View {
        ScrollView (.horizontal) {
            HStack {
                ForEach(Color.allList.indices, id: \.self) { index in
                    Circle()
                        .fill(Color.allList[index])
                        .frame(width: 50, height: 50)
                        .onTapGesture {
                            accentColorManager.accentColor = Color.allList[index]
                        }
                    
                        .overlay {
                            if Color.allList[index] == accentColorManager.accentColor {
                                Image(systemName: "circle.fill")
                            }
                        }
                }
            }
        }
        
        .scrollIndicators(.hidden)
        .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
    }
}

class AccentColorManager: ObservableObject {
    @AppStorage("accentColor") var accentColor: Color = Color.allList[0]
}

extension Color {
    init(hex: String) {
        let hexString = hex.hasPrefix("#") ? String(hex.dropFirst()) : hex
        
        guard hexString.count == 6, let hexValue = Int(hexString, radix: 16) else {
            self.init(red: 0, green: 0, blue: 0)
            return
        }
        
        let red = Double((hexValue >> 16) & 0xFF) / 255.0
        let green = Double((hexValue >> 8) & 0xFF) / 255.0
        let blue = Double(hexValue & 0xFF) / 255.0
        
        self.init(red: red, green: green, blue: blue)
    }
    
    func printColorHex() {
        if let components = self.cgColor?.components {

            let red = Int((components[0] * 255).rounded())
            let green = Int((components[1] * 255).rounded())
            let blue = Int((components[2] * 255).rounded())
            
            let hex = String(format: "#%02X%02X%02X", red, green, blue)
            print("Hex Color: \(hex)")
        } else {
            print("Unable to retrieve color components.")
        }
    }
    
    func getColorHex() -> String {
        if let components = self.cgColor?.components {
            
            let red = Int((components[0] * 255).rounded())
            let green = Int((components[1] * 255).rounded())
            let blue = Int((components[2] * 255).rounded())
            
            return String(format: "#%02X%02X%02X", red, green, blue)
        } else {
            return ""
        }
    }
    
    static let allList: [Color] = [
        Color(hex: "#FA7343"),  // Swift
        Color(hex: "#3776AB"),  // Python
        Color(hex: "#B07219"),  // Java
        Color(hex: "#EFD81D"),  // JavaScript (toned down yellow for contrast)
        Color(hex: "#3178C6"),  // TypeScript
        Color(hex: "#5C8DBC"),  // C (adjusted for better contrast)
        Color(hex: "#004482"),  // C++
        Color(hex: "#239120"),  // C# (cool green for visibility)
        Color(hex: "#CC342D"),  // Ruby
        Color(hex: "#00A9D6"),  // Go (balanced teal blue)
        Color(hex: "#D17F45"),  // Rust (warmer, more visible brown-orange)
        Color(hex: "#A97BFF"),  // Kotlin
        Color(hex: "#01589C"),  // Dart (muted slightly)
        Color(hex: "#6A7DBE"),  // PHP (lighter purple-blue for contrast)
        Color(hex: "#E44D26"),  // HTML
        Color(hex: "#2965F1"),  // CSS
        Color(hex: "#14557B"),  // SQL (deep but visible blue)
        Color(hex: "#276DC3"),  // R
        Color(hex: "#7FBF3F"),  // Shell (less neon)
        Color(hex: "#DC322F"),  // Scala
        Color(hex: "#525C96"),  // Perl (mid-blue purple)
        Color(hex: "#7E6DAE"),  // Haskell
        Color(hex: "#8E5EAA"),  // Elixir
        Color(hex: "#2C2D72"),  // Lua (dark but vivid navy)
        Color(hex: "#85613E"),  // Assembly (warmer brown)
        Color(hex: "#FF3E00")   // Svelte (official vibrant orange)
    ]
}

extension Color: RawRepresentable {
    
    public init?(rawValue: String) {
        guard let data = Data(base64Encoded: rawValue) else {
            self = .black
            return
        }
        
        do {
            let color = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? UIColor ?? .black
            self = Color(color)
        } catch {
            self = .black
        }
    }
    
    public var rawValue: String {
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: UIColor(self), requiringSecureCoding: false) as Data
            return data.base64EncodedString()  
        } catch {
            return ""   
        }
    }  
}
