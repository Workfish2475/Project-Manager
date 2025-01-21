import SwiftUI

struct TipView: View {
    @EnvironmentObject var accentColorManager: AccentColorManager
    
    var body: some View {
        NavigationStack {
            ScrollView (.vertical) {
                VStack {
                    aboutDesc()
                        .navigationTitle("Tip")
                    
                    Spacer()
                }
            }
        }
    }
    
    @ViewBuilder
    func aboutDesc() -> some View {
        Text(
            "Fini will remain free as long as there are no maintenance costs. Tips are always appreciated, and I'll do my best to provide regular updates."
        )
        
        .font(.system(size: 16, weight: .medium))
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(uiColor: .secondarySystemBackground))
        )
        .padding()
    }
    
    @ViewBuilder
    func tipItems() -> some View {
        
    }
    
    // This could be moved to a splash screen or onboarding UI
    @ViewBuilder
    func proList() -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(uiColor: .secondarySystemBackground))
            
            VStack (alignment: .leading, spacing: 10) {
                proItem("Unlimited projects", "hammer.fill", "Allows for the addition of unlimted projects.")
                Divider()
                proItem("Unlimited tags", "tag.fill", "Allows for the addition of unlimted tags.")
                Divider()
                proItem("Custom app accent", "paintbrush.fill", "Allows for the selection of custom accent colors.")
                Divider()
                proItem("iCloud sync", "icloud.fill", "Allows for sync across devices using iCloud.")
                Spacer()
            }
            
            .padding()
        }
        
        .padding()
    }
    
    @ViewBuilder
    func proItem(_ itemName: String,_ itemImage: String, _ itemDesc: String) -> some View {
        HStack (alignment: .center) {
            Image(systemName: itemImage)
                .foregroundStyle(accentColorManager.accentColor)
            VStack (alignment: .leading){
                Text(itemName)
                    .font(.headline.bold())
                Text(itemDesc)
                    .font(.subheadline.bold())
                    .foregroundStyle(Color.gray)
            }
        }
    }
}

#Preview {
    TipView()
        .environmentObject(AccentColorManager())
}
