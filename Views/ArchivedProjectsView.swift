import SwiftUI
import SwiftData

struct ArchivedProjectsView: View {
    @EnvironmentObject var accentColorManager: AccentColorManager
    @Query(filter: Project.getArchivedProjects()) var projects: [Project]
    
    var body: some View {
        NavigationStack {
            if (projects.isEmpty) {
                emptyView()
                    .navigationTitle("Archived")
                    .navigationBarTitleDisplayMode(.large)
            } else {
                listView()
                    .navigationTitle("Archived projects")
                    .navigationBarTitleDisplayMode(.large)
            }
        }
    }
    
    @ViewBuilder
    func emptyView() -> some View {
        VStack (alignment: .center, spacing: 10) {
            Image(systemName: "archivebox.circle.fill")
                .resizable()
                .frame(width: 75, height: 75)
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(accentColorManager.accentColor)
            
            Text("No projects archived")
                .font(.headline.bold())
                .foregroundStyle(Color(uiColor: .secondaryLabel))
        }
    }
    
    @ViewBuilder
    func listView() -> some View {
        List {
            ForEach(projects, id: \.id){project in
                Text(project.projectName)    
            }
        }
    }
}

#Preview {
    ArchivedProjectsView()
        .environmentObject(AccentColorManager())
}
