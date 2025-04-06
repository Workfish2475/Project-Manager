import SwiftUI

struct SplashScreen: View {
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            newDesc()
                .navigationTitle("Whats New?")
                .toolbar {
                    ToolbarItem (placement: .topBarTrailing) {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .symbolRenderingMode(.hierarchical)
                        }
                    }
                }
        }
    }
    
    @ViewBuilder
    func newDesc() -> some View {
        ZStack {
            Color(uiColor: .secondarySystemBackground)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            
            VStack {
                itemEntry("gear.circle.fill", "New Settings", "Added new personalization settings.")
                Divider()
                itemEntry("gear.circle.fill", "New Settings", "Added new personalization settings.")
            }
            
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        
        .padding()
    }
    
    @ViewBuilder
    func itemEntry(_ imageName: String, _ title: String, _ desc: String) -> some View {
        HStack {
            Image(systemName: "gear.circle.fill")
                .imageScale(.large)
            VStack (alignment: .leading) {
                Text("New settings")
                    .font(.headline)
                Text("Added new personalization settings")
                    .font(.subheadline)
            }
            Spacer()
        }
    }
}

#Preview {
    SplashScreen()
}
