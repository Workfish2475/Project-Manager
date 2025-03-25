import SwiftUI
import SwiftData

struct ProjectView: View {
    @Query(filter: #Predicate<Project> {!$0.isArchived}) var projects: [Project]
    @Environment(\.modelContext) private var context
    @Environment(\.colorScheme) private var scheme
    
    @State private var showingEntry: Bool = false
    @State private var showingSettings: Bool = false
    
    @Namespace private var animation
    @EnvironmentObject var accentColorManager: AccentColorManager
    
    private var backgroundColor: Color {
        scheme == .dark ? .gray : .black
    }
    
    var body: some View {
            ZStack (alignment: .bottomTrailing) {
                
                backgroundColor
                    .ignoresSafeArea(.all)
                    .opacity(showingEntry ? 0.1 : 0)
                    .zIndex(1)
                    .onTapGesture {
                        withAnimation (.bouncy(duration: 0.3)) {
                            showingEntry.toggle()
                        }
                    }
                
                Image(systemName: "plus.circle.fill")
                    .resizable()
                    .imageScale(.large)
                    .frame(width: 50, height: 50)
                    .padding()
                    .foregroundStyle(accentColorManager.accentColor)
                    .rotationEffect(showingEntry ? .degrees(45) : .zero)
                    .zIndex(2)
                    .sensoryFeedback(.impact, trigger: showingEntry)
                    .onTapGesture {
                        withAnimation (.bouncy(duration: 0.3)) {
                            showingEntry.toggle()
                        }
                    }
                
                VStack {
                    if projects.isEmpty {
                        emptyProject()
                            .containerRelativeFrame(.horizontal)
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
                
                if (showingEntry) {
                    NewProjectEntry(color: accentColorManager.accentColor)
                        .frame(height: 300, alignment: .center)
                        .transition(.move(edge: .bottom))
                        .zIndex(2)
                }
            }
            
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingSettings.toggle()
                    } label: {
                        Image(systemName: "gear")
                    }
                }
            }
            
            .tint(accentColorManager.accentColor)
            .sheet(isPresented: $showingSettings) {
                Settings()
            }
            
            .onChange(of: projects) {
                withAnimation {
                    showingEntry = false
                }
            }
    }
    
    @ViewBuilder
    func emptyProject() -> some View {
        VStack(alignment: .center, spacing: 10) {
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
                .font(.title3.bold())
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
            Button (role: .destructive) {
                context.delete(projectItem)
            } label: {
                Label("Delete", systemImage: "trash.fill")
            }
            
            .tint(.red)
        }
        
//        Uncomment this only when you're trying to delete everything!
//        .onAppear() {
//            deleteAllData(modelContext: context)
//        }
    }
    
    func deleteAllData(modelContext: ModelContext) {
        do {
            let taskDescriptor = FetchDescriptor<Task>()
            let tasks = try modelContext.fetch(taskDescriptor)
            tasks.forEach { modelContext.delete($0) }

            let projectDescriptor = FetchDescriptor<Project>()
            let projects = try modelContext.fetch(projectDescriptor)
            projects.forEach { modelContext.delete($0) }

            let tagDescriptor = FetchDescriptor<Tag>()
            let tags = try modelContext.fetch(tagDescriptor)
            tags.forEach { modelContext.delete($0) }

            try modelContext.save()
        } catch {
            print("Error deleting all data: \(error)")
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
