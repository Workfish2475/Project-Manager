import SwiftUI

struct AboutView: View {
    
    @EnvironmentObject var accentColorManager: AccentColorManager
    
    var body: some View {
        NavigationStack {
            ScrollView (.vertical) {
                DescArea()
                    .navigationTitle("About")
            }
        }
    }
    
    @ViewBuilder
    func DescArea() -> some View {

    }
}



#Preview {
    AboutView()
        .environmentObject(AccentColorManager())
}
