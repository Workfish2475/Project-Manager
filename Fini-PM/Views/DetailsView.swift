import SwiftUI
import SwiftData

struct DetailsView: View {
    var projectItem: Project
    
    @State var viewModel: DetailsViewModel = DetailsViewModel()
    
    @Namespace private var animation
    @EnvironmentObject var accentColorManager: AccentColorManager
    @AppStorage("appearance") var appearance: Appearance = .system
    @Environment(\.modelContext) private var context
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack (alignment: .bottom) {
                GeometryReader { geo in
                    ScrollView (.vertical) {
                        dashBoardView()
                        
                        if (projectItem.ProjectTasks.isEmpty) {
                            emptyView()
                                .frame(idealHeight: geo.size.height * 0.65)
                        } else {
                            taskListView()
                        }
                    }
                }
                .disabled(viewModel.addingTask)
            
                if viewModel.addingTask {
                    Color.primary
                        .opacity(0.3)
                        .ignoresSafeArea(.all)
                        .transition(.opacity)
                        .onTapGesture {
                            hideTaskEntry()
                        }
                }
                
                
                DetailsEntryView(project: projectItem, task: viewModel.selectedTask, isPresented: $viewModel.addingTask)
                    .id(viewModel.selectedTask?.id)
                    .frame(maxWidth: .infinity)
                    .frame(height: 150, alignment: .bottom)
                    .offset(y: viewModel.addingTask ? 0 : 350)
                    .scaleEffect(viewModel.addingTask ? 1.0 : 0.95)
                    .opacity(viewModel.addingTask ? 1 : 0)
                    .padding(.vertical)
                    .zIndex(1)
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
                        showNewTaskEntry()
                    } label: {
                        Label("New task", systemImage: "plus.circle.fill")
                            .imageScale(.large)
                    }
                    
                    .disabled(viewModel.addingTask)
                    .disabled(projectItem.isArchived)
                }
                
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Label("Back", systemImage: "chevron.left")
                            .labelStyle(.titleAndIcon)
                    }
                }
            }
        }
        
        .tint(Color(hex: projectItem.projectColor))
        .preferredColorScheme(appearance.colorScheme)
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .tabBar)
        
        .task {
            viewModel.setProject(projectItem)
        }
        
        .sheet(isPresented: $viewModel.isEditing){
            DetailsViewSubView(projectItem: projectItem)
        }
    }
    
    private func showNewTaskEntry() {
        viewModel.clearSelectedTask()
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            viewModel.addingTask = true
        }
    }
    
    private func showTaskEntry(task: Task) {
        viewModel.setSelectedTask(task)
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            viewModel.addingTask = true
        }
    }
    
    private func hideTaskEntry() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            viewModel.addingTask = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            viewModel.clearSelectedTask()
        }
    }
    
    @ViewBuilder
    func dashBoardView() -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(uiColor: .secondarySystemBackground))
            
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
                                        viewModel.changingColor.toggle()
                                    }
                                }
                            
                            if (viewModel.changingColor) {
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
                                                        viewModel.changingColor = false
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
            viewModel.isEditing = true
        }
    }
    
    @ViewBuilder
    func projectTasksUpdated(_ taskItem: Task) -> some View {
        HStack (alignment: .center) {
            Image(systemName: taskItem.isCompleted ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(Color(hex: projectItem.projectColor))
                .symbolEffect(.bounce, value: taskItem.isCompleted)
                .sensoryFeedback(.impact, trigger: taskItem.isCompleted)
            
                .onTapGesture {
                    withAnimation (.bouncy) {
                        taskItem.updateStatus()
                    }
                    
                    if (taskItem.status == .Done) {
                        taskItem.isCompleted = true
                    } else {
                        taskItem.isCompleted = false
                    }
                    
                    taskItem.lastUpdated = .now
                }
            
            VStack (alignment: .leading) {
                Text(taskItem.title)
                    .font(.headline)
                
                if !(taskItem.desc.isEmpty) {
                    Text(taskItem.desc)
                        .font(.subheadline)
                        .foregroundStyle(Color(uiColor: .secondaryLabel))
                }
                
                HStack {
                    HStack (spacing: 0) {
                        Text(String(describing: taskItem.status))
                            .font(.caption.bold())
                            .padding(5)
                            .foregroundStyle(Color(hex: projectItem.projectColor)) 
                        
                        if (taskItem.tag != nil) {
                            Divider()
                                .frame(width: 2, height: 10)
                                .overlay(Color(hex: projectItem.projectColor))
                                .clipShape(Capsule())
                            
                            Text(String(describing: taskItem.tag!.name))
                                .font(.caption.bold())
                                .foregroundStyle(Color(hex: projectItem.projectColor))
                                .padding(5)
                        }
                    }
                    
                    .background(
                        RoundedRectangle(cornerRadius: 5) 
                            .fill(Color(hex: projectItem.projectColor).opacity(0.1))
                            .stroke(Color(hex: projectItem.projectColor), lineWidth: 2)
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                    ) 
                    
                    Label(String(describing: taskItem.priority), systemImage: taskItem.getPriorityImage())
                        .font(.caption.bold())
                        .foregroundStyle(taskItem.getPriorityColor())
                        .padding(5)
                        .background(
                            RoundedRectangle(cornerRadius: 5) 
                                .fill(taskItem.getPriorityColor().opacity(0.1))
                                .stroke(taskItem.getPriorityColor(), lineWidth: 2)
                                .clipShape(RoundedRectangle(cornerRadius: 5))
                        )
                }
            }
            
            Spacer()
        }
        
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(uiColor: .secondarySystemBackground))
        )
        .padding(.horizontal)
        
        .onTapGesture {
            if (viewModel.isEditing) {

            }
            
            showTaskEntry(task: taskItem)
        }
    }
    
    func emptyView() -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(uiColor: .secondarySystemBackground))
            
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
        ForEach(Status.allCases, id: \.self) { status in
            VStack {
                if (!projectItem.ProjectTasks.filter { $0.status == status }.isEmpty) {
                    HStack {
                        Text(String(describing: status))
                            .foregroundStyle(Color(uiColor: .secondaryLabel))
                            .font(.caption.bold())
                            .padding(.top)
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                }
                
                ForEach(projectItem.ProjectTasks.filter { $0.status == status }, id: \.id) { task in
                    projectTasksUpdated(task)
                        .opacity(projectItem.isArchived ? 0.7 : 1)
                        .disabled(projectItem.isArchived)
                        .matchedGeometryEffect(id: "updatingTask\(task.id)", in: animation)
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
        
        let newTask = Task(title: "Design task view", desc: "Something Something Something", tag: newTag2, status: .Doing)
        let newTask1 = Task(title: "Design something", tag: newTag1, priority: .High)
        let newTask2 = Task(title: "Design something", tag: newTag1, priority: .High)
        
        let newProject = Project(projectName: "Fini", projectColor: "#1E90FF", projectTasks: [newTask, newTask1, newTask2])
        
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
