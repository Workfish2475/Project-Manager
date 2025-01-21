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

// TODO: Should write test cases for this
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
        Color(hex: "#CA5310"),
        Color(hex: "#8F250C"),
        Color(hex: "#96031A"),
        Color(hex: "#32CD32"),
        Color(hex: "#FFD700"),
        Color(hex: "#1E90FF"),
        Color(hex: "#800080"),
        Color(hex: "#C44E30"),
        Color(hex: "#FE0000"),
        Color(hex: "#FF91AF"),
        Color(hex: "#B57EDC"),
        Color(hex: "#BA160C"),
        Color(hex: "#0059CF"),
        Color(hex: "#0466C8")
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
