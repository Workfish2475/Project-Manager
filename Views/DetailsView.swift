import SwiftUI
import SwiftData

// TODO: This needs to be refactored to incorporate the viewModel

struct DetailsView: View {
    var projectItem: Project
    
     var viewModel: DetailsViewModel = DetailsViewModel()
    
    @State private var addingTask: Bool = false
    @State private var isEditing: Bool = false
    @State private var changingColor: Bool = false
    @State private var selectedTask: Task? = nil
    
    @Namespace private var animation
    @EnvironmentObject var accentColorManager: AccentColorManager
    @AppStorage("appearance") var appearance: Appearance = .system
    @Environment(\.modelContext) private var context
    
    var body: some View {
        NavigationStack {
            GeometryReader {geo in
                    ScrollView(.vertical) {
                        dashBoardView()   
                        
                        Divider()
                            .frame(width: 50)
                            .padding(.bottom)
                        
                        
                        if (projectItem.ProjectTasks.isEmpty) {
                            emptyView()
                                
                        } else {
                            taskListView()
                        }
                    }
                    
                    .scrollIndicators(.hidden)
                
            }
            
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal){
                    VStack {
                        Text(projectItem.projectName)
                            .font(.headline.bold())
                        Text(projectItem.isArchived ? "Archived" : "Active")
                            .font(.caption.bold())
                            .foregroundStyle(projectItem.isArchived ? .red : .green)
                    }
                }
                
                ToolbarItem(placement: .bottomBar) {
                    Button {
                        addingTask = true
                    } label: {
                        Label("New task", systemImage: "plus.circle.fill")
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button ("Edit") {
                        
                    }
                }
            }
        }
        
        .tint(Color(hex: projectItem.projectColor))
        .preferredColorScheme(appearance.colorScheme)
        
        //Replace this with .task
        .onAppear() {
            viewModel.setProject(projectItem)
        }
        
        .sheet(isPresented: $isEditing){
            DetailsViewSubView(projectItem: projectItem)
        }
    }
    
    
    @ViewBuilder
    func dashBoardView() -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(.thinMaterial)
            
            HStack {
                VStack (alignment: .leading, spacing: 10) {
                    VStack (alignment: .leading, spacing: 0) {
                        Text("Pending")
                            .fontWeight(.bold)
                            .foregroundStyle(.orange)
                            .fontDesign(.rounded)
                        HStack (alignment: .center) {
                            Text(String(describing: projectItem.uncompletedTaskCount()))
                                .fontDesign(.rounded)
                                .fontWeight(.bold)
                            Text("tasks")
                                .fontWeight(.bold)
                                .foregroundStyle(Color(uiColor: .secondaryLabel))
                        }
                    }
                    
                    VStack (alignment: .leading, spacing: 0) {
                        Text("Completed")
                            .fontWeight(.bold)
                            .foregroundStyle(.green)
                        HStack {
                            Text(String(describing: projectItem.completedTaskCount()))
                                .fontDesign(.rounded)
                                .fontWeight(.bold)
                            Text("tasks")
                                .fontWeight(.bold)
                                .foregroundStyle(Color(uiColor: .secondaryLabel))
                        }
                    }
                    
                    VStack (alignment: .leading) {
                        Text("Project color")
                            .fontDesign(.rounded)
                            .fontWeight(.bold)
                        HStack {
                            Circle()
                                .fill(Color(hex: projectItem.projectColor)) 
                                .frame(height: 20)
                                .onTapGesture {
                                    withAnimation {
                                        changingColor.toggle()
                                    }
                                }
                            
                            if (changingColor) {
                                Divider() 
                                    .frame(height: 10)
                                
                                ScrollView (.horizontal) {
                                    HStack {
                                        ForEach(Color.allList, id: \.self){color in
                                            Circle()
                                                .fill(color)
                                                .frame(height: 20)
                                                .onTapGesture {
                                                    projectItem.projectColor = color.getColorHex()
                                                    withAnimation {
                                                        changingColor = false
                                                    }
                                                }
                                        }
                                    } 
                                 }
                                
                                .scrollIndicators(.hidden)
                            }
                        }
                    }   
                }
                
                Spacer()
                Divider()
                
                VStack (spacing: 0) {
                    CircularProgressView(progress: projectItem.progressValue(), ringColor: Color(hex: projectItem.projectColor))
                        .frame(height: 125)
                        .padding(.horizontal)
                    Text("Progress")
                        .font(.caption2)
                        .foregroundStyle(Color(uiColor: .secondaryLabel))
                        .fontWeight(.bold)
                }
            }
            
            .padding()
        }
        
        .padding()
        .onTapGesture {
            isEditing = true
        }
    }
    
    @ViewBuilder
    func generalView() -> some View {
        if projectItem.ProjectTasks.isEmpty {
            emptyView()
        } else {
            taskListView()
        }
    }
    
    @ViewBuilder
    func projectTasksUpdated(_ taskItem: Task) -> some View {
        HStack (alignment: .center) {
            Image(systemName: "circle")
            
            VStack (alignment: .leading) {
                Text(taskItem.title)
                    .font(.headline)
                
                Divider()
                
                if !(taskItem.desc.isEmpty) {
                    Text("Description")
                        .font(.caption2.bold())
                        .foregroundStyle(Color(uiColor: .secondaryLabel))
                    
                    Text(taskItem.desc)
                        .font(.subheadline)
                }
                
                HStack {
                    Text(String(describing: taskItem.status))
                        .font(.caption)
                        .padding(5)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(hex: projectItem.projectColor).opacity(0.4))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        )
                    
                    if (taskItem.tag != nil) {
                        Text(String(describing: taskItem.tag!.name))
                            .font(.caption)
                            .padding(5)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color(hex: projectItem.projectColor).opacity(0.4))
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            )
                    }
                }
            }
        }
        
        
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(uiColor: .secondarySystemBackground))
        )
        .padding(.horizontal)
    }
    
    @ViewBuilder
    func emptyView() -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(.thinMaterial)
            
            VStack (alignment: .center, spacing: 10) {
                Spacer() 
                Image(systemName: "tray.circle.fill")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .foregroundStyle(Color(hex: projectItem.projectColor))
                Text("No tasks added to project")
                    .font(.headline.bold())
                Spacer()
            }
        }
        
        .padding()
    }
    
    @ViewBuilder
    func taskListView() -> some View {
        ForEach(projectItem.ProjectTasks, id: \.id){task in
            DetailsEntryView(project: projectItem, task: task)
        }
        
        ScrollViewReader {proxy in
            if (addingTask) {
                DetailsEntryView(project: projectItem, task: nil)
                    .id("newTaskEntry")
                    .onAppear {
                        proxy.scrollTo("newTaskEntry") 
                    }
            }
        }
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: Tag.self, Task.self, configurations: config)
        
        let newTag1 = Tag(name: "Testing")
        let newTag2 = Tag(name: "UI")
        let newTag3 = Tag(name: "Bugs")
        let newTag4 = Tag(name: "User study")
        
        let newTask = Task(title: "Design task view", desc: "Test some things and write some test cases. Do some Unit testing.", tag: newTag2)
        let newTask1 = Task(title: "Design task view", tag: newTag1)
        
        let newProject = Project(projectName: "Fini", projectColor: "#1E90FF", projectTasks: [newTask])
        
        container.mainContext.insert(newTag1)
        container.mainContext.insert(newTag2)
        container.mainContext.insert(newTag3)
        container.mainContext.insert(newTag4)
        container.mainContext.insert(newTask)
        
        return DetailsView(projectItem: newProject)
            .modelContainer(container)
            .environmentObject(AccentColorManager())
    }
}
