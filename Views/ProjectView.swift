import SwiftUI
import SwiftData

//TODO: This should only fetch projects that are NOT archived. 

struct ProjectView: View {
    @Query var projects: [Project]
    @Environment(\.modelContext) private var context
    @Environment(\.colorScheme) private var scheme
    
    @EnvironmentObject var accentColorManager: AccentColorManager
    
    var body: some View {
        NavigationStack {
            VStack {
                Divider()
                    .frame(height: 3)
                    .foregroundStyle(.white.opacity(0.4))
                    .padding(.bottom, 10)
                    .hidden()
                
                if projects.isEmpty {
                    emptyProject()
                } else {
                    List {
                        ForEach(projects, id: \.id) { project in
                            NavigationLink(destination: DetailsView(projectItem: project)) {
                                projectItem(project) 
                            } //NavigationLink
                        } //ForEach
                        
                        .scrollIndicators(.hidden)
                        .listRowSeparator(.hidden)
                    }
                    
                    .listStyle(.plain)
                    .tint(accentColorManager.accentColor)
                }
            }
        }
    }
    
    @ViewBuilder
    func emptyProject() -> some View {
        VStack(spacing: 10) {
            Spacer() 
            
            Image(systemName: "hammer.circle.fill")
                .resizable()
                .symbolRenderingMode(.hierarchical)
                .frame(width:75, height: 75)
                .foregroundStyle(accentColorManager.accentColor)
            
            Text("No projects have been added")
                .font(.headline.bold())
                .foregroundStyle(Color(uiColor: .secondaryLabel))
            
            Spacer()
        }
    }
    
    @ViewBuilder
    func projectItem(_ projectItem: Project) -> some View {
        VStack (alignment: .leading, spacing: 5) {
            Text("\(projectItem.projectName)")
                .font(.title2.bold())
                .foregroundStyle(scheme == .light ? .black : .white)
            
            ProgressView("Progress", value: projectItem.progressValue() * 100, total: 100)
                .progressViewStyle(.linear)
                .foregroundStyle(.gray.opacity(0.8))
                .tint(Color(hex: projectItem.projectColor))
                .font(.caption.bold())
            
            Text(String(format: "%.0f%% completed", projectItem.progressValue() * 100))
                .font(.caption2.bold())
                .foregroundStyle(.gray)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        
        .tint(accentColorManager.accentColor)
        .swipeActions(edge: .trailing) {
            Button {
                context.delete(projectItem)
            } label: {
                Image(systemName: "x.square.fill")
            }
        }
    }
}

struct ProjectView_Previews: PreviewProvider {
    static var previews: some View {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: Project.self, configurations: config)
        
        let newTask = Task(title: "testing", isCompleted: true)
        
        let project1 = Project(projectName: "Fini App", projectColor: "#ED2939")
        project1.ProjectTasks.append(newTask)
        let project2 = Project(projectName: "Personal Website", projectColor: "#32CD32")
        let project3 = Project(projectName: "Travel Planner", projectColor: "#1E90FF")
        let project4 = Project(projectName: "Fitness Tracker", projectColor: "#FFD700")
        
        container.mainContext.insert(project1)
        container.mainContext.insert(project2)
        container.mainContext.insert(project3)
        container.mainContext.insert(project4)
        
        return ProjectView()
            .modelContainer(container)
            .environmentObject(AccentColorManager())
    }
}
