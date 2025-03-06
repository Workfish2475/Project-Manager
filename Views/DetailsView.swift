import SwiftUI
import SwiftData

struct DetailsView: View {
    var projectItem: Project
    
    @StateObject var viewModel: DetailsViewModel = DetailsViewModel()
    
    @State private var addingTask: Bool = false
    @State private var isEditing: Bool = false
    @State private var deletingTasks: Bool = false
    @State private var changingColor: Bool = false
    @State private var selectedTask: Task? = nil
    
    @Namespace private var animation
    @EnvironmentObject var accentColorManager: AccentColorManager
    @AppStorage("appearance") var appearance: Appearance = .system
    @Environment(\.modelContext) private var context
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack (alignment: .bottom) {
                GeometryReader{geo in
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
                
                
                Color.black
                    .opacity(viewModel.addingTask ? 0.7 : 0)
                    .ignoresSafeArea(.all)
                    .animation(.snappy(duration: 0.2), value: viewModel.addingTask)
                    .onTapGesture {
                        withAnimation(.bouncy(duration: 0.4)) {
                            viewModel.addingTask = false
                        }
                    }
                
                if viewModel.addingTask {
                    DetailsEntryView(project: projectItem, task: viewModel.selectedTask)
                        .frame(width: .infinity, height: 150, alignment: .bottom)
                        .transition(
                            .asymmetric(
                                insertion: .move(edge: .bottom).combined(with: .scale(scale: 1.05)),
                                removal: .offset(y: 350).combined(with: .scale(scale: 0.95))
                            )
                        )
                        
                        .sensoryFeedback(.impact, trigger: viewModel.addingTask)
                        .padding(.vertical)
                        .zIndex(1)
                }
            }
            
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.hidden, for: .tabBar)
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
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button (viewModel.deletingTasks ? "Done" : "Edit") {
                        viewModel.deletingTasks.toggle()
                    }
                    
                    .disabled(viewModel.addingTask)
                    .disabled(projectItem.isArchived)
                }
                
                ToolbarItem(placement: .bottomBar) {
                    Button {
                        withAnimation (.snappy) {
                            viewModel.addingTask = true
                        }
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
        
        .task {
            viewModel.setProject(projectItem)
        }
        
        .onChange(of: viewModel.addingTask) {
            if !viewModel.addingTask {
                DispatchQueue.main.asyncAfter(deadline: .now(), qos: .userInteractive) {
                    viewModel.clearSelectedTask()
                }
            }
        }
        
        .sheet(isPresented: $viewModel.isEditing){
            DetailsViewSubView(projectItem: projectItem)
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
                .onTapGesture {
                    taskItem.isCompleted.toggle()
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
                    Text(String(describing: taskItem.status))
                        .font(.caption.bold())
                        .padding(5)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(hex: projectItem.projectColor).opacity(0.4))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        )
                    
                    if (taskItem.tag != nil) {
                        Text(String(describing: taskItem.tag!.name))
                            .font(.caption.bold())
                            .padding(5)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color(hex: projectItem.projectColor).opacity(0.4))
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            )
                    }
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
            withAnimation (.snappy(duration: 0.3, extraBounce: 0.2)) {
                viewModel.setSelectedTask(taskItem)
                viewModel.addingTask = true
            }
        }
    }
    
    @ViewBuilder
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
        ForEach(projectItem.ProjectTasks, id: \.id){task in
            projectTasksUpdated(task)
                .opacity(projectItem.isArchived ? 0.7 : 1)
                .disabled(projectItem.isArchived)
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
        
        let newProject = Project(projectName: "Fini", projectColor: "#1E90FF", projectTasks: [])
        
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
