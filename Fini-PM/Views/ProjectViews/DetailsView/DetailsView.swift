import SwiftUI
import SwiftData

struct DetailsView: View {
    var projectItem: Project
    
    @State var viewModel: DetailsViewModel = DetailsViewModel()
    
    @Namespace private var animation
    @EnvironmentObject var accentColorManager: AccentColorManager
    @AppStorage("appearance") var appearance: Appearance = .system
    @Environment(\.modelContext) private var context
    @Environment(\.colorScheme) private var scheme
    
    @Environment(\.dismiss) private var dismiss
    
    init(projectItem: Project) {
        self.projectItem = projectItem
        let viewModel = DetailsViewModel()
        viewModel.setProject(projectItem)
        _viewModel = State(initialValue: viewModel)
    }
    
    private var backgroundColor: Color {
        scheme == .dark ? .gray : .black
    }
    
    private var completedTasks: [Task] {
        projectItem.projectTasks.filter { $0.isCompleted }
    }
    
    var body: some View {
        NavigationStack {
            ZStack (alignment: .bottom) {
                GeometryReader { geo in
                    ScrollView (.vertical) {
                        VStack {
                            ControlView
                            
                            Group {
                                if (projectItem.projectTasks.isEmpty) {
                                    emptyView
                                        .frame(height: geo.size.height - 200)
                                } else {
                                    taskListView
                                }
                            }
                            
                            Spacer()
                        }
                    }
                }
                
                .disabled(viewModel.addingTask)
            
                if viewModel.addingTask {
                    Color.clear
                        .background(.ultraThinMaterial)
                        .ignoresSafeArea()
                        .transition(.opacity)
                        .onTapGesture {
                            hideTaskEntry()
                        }
                }

                VStack {
                    DetailsEntryView(project: projectItem, task: viewModel.selectedTask, isPresented: $viewModel.addingTask)
                        .id(viewModel.selectedTask?.id)
                        .frame(height: 150, alignment: .bottom)
                        .offset(y: viewModel.addingTask ? 0 : 350)
                        .scaleEffect(viewModel.addingTask ? 1.0 : 0.95)
                        .opacity(viewModel.addingTask ? 1 : 0)
                        .padding(.vertical)
                        .zIndex(1)
                    
                    Button {
                        if viewModel.addingTask {
                            return hideTaskEntry()
                        }
                        
                        showNewTaskEntry()
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .resizable()
                            .frame(width: 45, height: 45)
                            .rotationEffect(viewModel.addingTask ? .degrees(45) : .zero)
                    }
                    
                    .padding()
                    .disabled(projectItem.isArchived)
                    .frame(maxWidth: .infinity, alignment: .bottomTrailing)
                    .background(
                        LinearGradient(colors: [.clear, .black.opacity(0.1)], startPoint: .top, endPoint: .bottom)
                    )
                }
                
                .frame(maxWidth: .infinity)
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
                    
                    .opacity(viewModel.addingTask ? 0 : 1)
                }
                
                ToolbarItem(placement: .topBarLeading) {
                    if !viewModel.addingTask {
                        Button {
                            dismiss()
                        } label: {
                            Label("Back", systemImage: "chevron.left")
                                .labelStyle(.titleAndIcon)
                        }
                    }
                }
            }
        }
        
        .tint(Color(hex: projectItem.projectColor))
        .preferredColorScheme(appearance.colorScheme)
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .tabBar)
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
    
    private var ControlView: some View {
        TabView (selection: $viewModel.selected) {
            dashBoardView
                .tag(0)
            
            HeatMapView(projectColor: Color(hex: projectItem.projectColor), projectTasks: completedTasks)
                .tag(1)
        }
        
        .frame(height: 200)
        .tabViewStyle(.page(indexDisplayMode: .never))
    }
    
    private var dashBoardView: some View {
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
                .frame(height: 50)
            
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
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(uiColor: .secondarySystemBackground))
        )
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
                    if (taskItem.tag != nil) {
                        Text(String(describing: taskItem.tag!.name))
                            .font(.caption.bold())
                            .foregroundStyle(Color(hex: projectItem.projectColor))
                            .padding(5)
                            .background(
                                RoundedRectangle(cornerRadius: 5)
                                    .fill(Color(hex: projectItem.projectColor).opacity(0.1))
                                    .stroke(Color(hex: projectItem.projectColor), lineWidth: 2)
                                    .clipShape(RoundedRectangle(cornerRadius: 5))
                            )
                    }
                    
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
            showTaskEntry(task: taskItem)
        }
    }
    
    private var emptyView: some View {
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
        
        
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(uiColor: .secondarySystemBackground))
        )
        .padding()
    }
    
    private var taskListView: some View {
        ForEach(Status.allCases, id: \.self) { status in
            VStack {
                if (!projectItem.projectTasks.filter { $0.status == status }.isEmpty) {
                    HStack {
                        Text(String(describing: status))
                            .foregroundStyle(Color(uiColor: .secondaryLabel))
                            .font(.caption.bold())
                            .padding(.top)
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                }
                
                ForEach(projectItem.projectTasks.filter { $0.status == status }, id: \.id) { task in
                    projectTasksUpdated(task)
                        .opacity(projectItem.isArchived ? 0.7 : 1)
                        .disabled(projectItem.isArchived)
                        .matchedGeometryEffect(id: "updatingTask\(task.id)", in: animation)
                }
            }
        }
    }
}

#Preview {
    @Previewable @StateObject var accentColor = AccentColorManager()
    @Previewable @AppStorage("appearance") var appearance: Appearance = .system
    
    DetailsView(projectItem: .init(projectName: "Test Project", projectColor: "#555"))
        .environmentObject(accentColor)
        .modelContainer(for: [Tag.self, Project.self, Task.self])
}
