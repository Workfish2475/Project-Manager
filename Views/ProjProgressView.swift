import SwiftUI
import SwiftData

struct ProjProgressView: View {
    @Query private var projects: [Project]
    @State private var showingSettings: Bool = false
    
    @EnvironmentObject var accentColorManager: AccentColorManager
    
    var body: some View {
        NavigationStack {
             kanban()
                .navigationTitle("Progress")
                .toolbar {
                    ToolbarItem (placement: .topBarTrailing) {
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
    
    @ViewBuilder
    func kanban() -> some View {
        GeometryReader { geometry in
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 16) {
                    ForEach(Status.allCases, id: \.self) { status in
                        ProgressCardView(currentStatus: status, projects: projects)
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


struct ProjProgressView_Previews: PreviewProvider {
    static var previews: some View {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: Tag.self, Task.self, Project.self, configurations: config)
        
        // Create unique tags
        let tag1 = Tag(name: "Testing")
        let tag2 = Tag(name: "UI")
        let tag3 = Tag(name: "Backend")
        let tag4 = Tag(name: "User study")
        
        // Create distinct tasks
        let task1 = Task(title: "Design UI", tag: tag2, status: .Backlog)
        let task2 = Task(title: "Debugging", tag: tag1, status: .Review)
        
        // Create projects with different tasks
        let project1 = Project(projectName: "Project Alpha", projectColor: "#FF5733", projectTasks: [task1])
        let project2 = Project(projectName: "Project Beta", projectColor: "#33FF57", projectTasks: [task2])
        
        // Insert data into the model container
        container.mainContext.insert(project1)
        container.mainContext.insert(project2)
        container.mainContext.insert(tag1)
        container.mainContext.insert(tag2)
        container.mainContext.insert(tag3)
        container.mainContext.insert(tag4)
        container.mainContext.insert(task1)
        container.mainContext.insert(task2)
        
        return ProjProgressView()
            .modelContainer(container)
            .environmentObject(AccentColorManager())
    }
}
