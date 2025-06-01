import SwiftUI
import SwiftData

struct ProjectView: View {
    @Query(filter: #Predicate<Project> {!$0.isArchived}) var projects: [Project]
    @Query(filter: #Predicate<Project> {$0.isArchived}) var archivedProjects: [Project]
    
    @Environment(\.modelContext) private var context
    @Environment(\.colorScheme) private var scheme
    
    @State private var showingEntry: Bool = false
    @State private var showingSettings: Bool = false
    @State private var showingArchived: Bool = false
    @State private var showingGrid: Bool = false
    
    @Namespace private var animation
    @EnvironmentObject var accentColorManager: AccentColorManager
    
    private var accentColor: Color {
        return accentColorManager.accentColor
    }
    
    var body: some View {
        NavigationStack {
            ZStack (alignment: .bottomTrailing) {
                mainContent
                
                if showingEntry {
                    Color.clear
                        .background(.thinMaterial)
                        .ignoresSafeArea()
                        .transition(.opacity)
                        .zIndex(0)
                        .onTapGesture {
                            withAnimation (.bouncy(duration: 0.3)) {
                                showingEntry.toggle()
                            }
                        }
                }
                
                VStack {
                    if showingEntry {
                        NewProjectEntry(color: accentColor)
                            .frame(height: 200)
                            .padding(.horizontal)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                            .zIndex(1)
                    }

                    Image(systemName: "plus.circle.fill")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .padding()
                        .foregroundStyle(accentColor)
                        .rotationEffect(showingEntry ? .degrees(45) : .zero)
                        .zIndex(1)
                        .sensoryFeedback(.impact, trigger: showingEntry)
                        .frame(maxWidth: .infinity, alignment: .bottomTrailing)
                        .onTapGesture {
                            withAnimation (.bouncy(duration: 0.3)) {
                                showingEntry.toggle()
                            }
                        }
                }
            }
            
            .navigationTitle(showingEntry ? "" :"Projects")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingSettings.toggle()
                    } label: {
                        Image(systemName: "gear")
                    }
                    
                    .opacity(showingEntry ? 0 : 1)
                }
            }
        }
        
        .tint(accentColor)
        .sheet(isPresented: $showingSettings) {
            Settings()
        }
        
        .onChange(of: projects) {
            withAnimation {
                showingEntry = false
            }
        }
    }
    
    private var mainContent: some View {
        ScrollView (.vertical) {
            VStack (spacing: 10) {
                buttonsSection
                
                let currentProjects = showingArchived ? archivedProjects : projects
                
                if currentProjects.isEmpty {
                    
                    ContentUnavailableView {
                        Label("No Projects", systemImage: "hammer.circle.fill")
                    } description: {
                        Text("Add some to get started")
                    }
                    
                } else {
                    if showingGrid {
                        projectLinksGrid(currentProjects)
                    } else {
                        projectLinks(currentProjects)
                    }
                    
                    Spacer()
                }
            }
            
            .containerRelativeFrame(.vertical)
        }
    }
    
    private var buttonsSection: some View {
        ScrollView (.horizontal) {
            HStack {
                Button {
                    withAnimation {
                        showingGrid.toggle()
                    }
                } label: {
                    Label("Grid", systemImage: "square.grid.2x2.fill")
                        .font(.headline)
                }
                
                .tint(showingGrid ? accentColor : .gray)
                
                Button {
                    withAnimation {
                        showingArchived.toggle()
                    }
                } label: {
                    Label("Archived", systemImage: "line.3.horizontal.decrease.circle.fill")
                        .font(.headline)
                        
                }
                
                .tint(showingArchived ? accentColor : .gray)
            }
            
            .padding(.horizontal)
            .buttonStyle(.bordered)
        }
    }
    
    func projectLinks(_ projects: [Project]) -> some View {
        List {
            ForEach(projects, id: \.id){ project in
                NavigationLink(destination: DetailsView(projectItem: project)) {
                    projectItem(project)
                }
            }
            
            .scrollIndicators(.hidden)
            .listRowSeparator(.hidden)
        }
        
        .listStyle(.plain)
        .tint(accentColor)
    }
    
    func projectLinksGrid(_ projects: [Project]) -> some View {
        LazyVGrid(columns: .init(repeating: GridItem(.flexible()), count: 2)) {
            ForEach(projects, id: \.id) { project in
                NavigationLink(destination: DetailsView(projectItem: project)) {
                    
                    //TODO: Extract this to its own view var
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.thinMaterial)
                        
                        VStack {
                            CircularProgressView(progress: project.progressValue(), ringColor: Color(hex:project.projectColor))
                                .tint(.primary)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(.ultraThinMaterial)
                                )
                            
                            Text("\(project.projectName)")
                                .font(.title3.bold())
                                .foregroundStyle(Color(hex: project.projectColor))
                        }
                        
                        .padding()
                    }
                    
                    .contextMenu {
                        Button (role: .destructive) {
                            for task in project.projectTasks {
                                context.delete(task)
                            }
                            
                            context.delete(project)
                        } label: {
                            Label("Trash", systemImage: "trash.fill")
                        }
                    }
                }
            }
        }
        
        .padding()
    }

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
        
        .tint(accentColor)
        .swipeActions(edge: .trailing) {
            Button (role: .destructive) {
                for task in projectItem.projectTasks {
                    context.delete(task)
                }
                
                context.delete(projectItem)

            } label: {
                Label("Trash", systemImage: "trash.fill")
            }
            
            .tint(.red)
        }
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

#Preview {
    @Previewable @StateObject var accentColor = AccentColorManager()
    @Previewable @AppStorage("appearance") var appearance: Appearance = .system
    
    ProjectView()
        .environmentObject(accentColor)
        .modelContainer(for: [Tag.self, Project.self, Task.self])
}
