import SwiftUI

struct AccentColorView: View {
    @EnvironmentObject var accentColorManager: AccentColorManager
    @State private var colorpick: Color = AccentColorManager().accentColor
    
    var body: some View {
        NavigationStack {
            colorGrid()
        }
        .navigationTitle("Accent Color")
        .toolbar {
            ToolbarItem {
                ColorPicker("", selection: accentColorManager.$accentColor, supportsOpacity: false)
                    .labelsHidden()
            }
        }
    }
    
    @ViewBuilder
    func colorGrid() -> some View {
        ScrollView (.vertical) {
            LazyVGrid (columns: [GridItem(.adaptive(minimum: 100))], spacing: 30) {
                ForEach(Color.allList.indices, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.allList[index])
                        .frame(width: 100, height: 100)
                        .onTapGesture {
                            accentColorManager.accentColor = Color.allList[index]
                        }
                }
            }
        }
        
        .scrollIndicators(.hidden)
    }
}

#Preview {
    @Previewable @StateObject var accentColor = AccentColorManager()
    
    AccentColorView()
        .environmentObject(accentColor)
}
