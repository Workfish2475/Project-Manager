import SwiftUI
import SwiftData

struct ProjProgressView: View {
    @Query private var projects: [Project]
    @State private var showingSettings: Bool = false
    
    @EnvironmentObject var accentColorManager: AccentColorManager
    
    var body: some View {
        NavigationStack {
            kanban
                .navigationTitle("Progress")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            showingSettings.toggle()
                        } label: {
                            Image(systemName: "gear")
                        }
                    }
                }
        }
        
        .sheet(isPresented: $showingSettings) {
            Settings()
        }
    }
    
    private var kanban: some View {
        GeometryReader { geometry in
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 16) {
                    ForEach(Status.allCases, id: \.self) { status in
                        ProgressCardView(currentStatus: status)
                            .background(.thinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .frame(width: geometry.size.width >= 768 ? 
                                   (geometry.size.width / CGFloat(Status.allCases.count)) - 24 : 
                                    geometry.size.width - 32)
                    }
                }
                
                .padding()
                .scrollTargetLayout()
                .frame(maxHeight: .infinity)
            }
            
            .scrollDisabled(geometry.size.width >= 768)
            .scrollTargetBehavior(.viewAligned)
        }
    }
}

#Preview {
    @Previewable @StateObject var accentColor = AccentColorManager()
    @Previewable @AppStorage("appearance") var appearance: Appearance = .system
    
    ProjProgressView()
        .environmentObject(accentColor)
        .modelContainer(for: [Tag.self, Project.self, Task.self])
}
