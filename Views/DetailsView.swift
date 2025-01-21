import SwiftUI
import SwiftData

// TODO: This needs to be refactored to incorporate the viewModel

struct DetailsView: View {
    var projectItem: Project
    
     var viewModel: DetailsViewModel = DetailsViewModel()
    
    @State private var taskEntry: Bool = false
    @State private var taskText: String = ""
    @State private var addingTask: Bool = false
    
    @State private var topExpanded: Bool = false
    
    @State private var tagSelection: Tag?
    @State private var statusSelection: Status = .Backlog
    @State private var selectingTag: Bool = false
    
    @State private var isEditing: Bool = false
    @State private var changingColor: Bool = false
    @State private var selectedTask: Task? = nil
    
    @Query private var tags: [Tag]
    
    @Namespace private var animation
    @EnvironmentObject var accentColorManager: AccentColorManager
    @AppStorage("appearance") var appearance: Appearance = .system
    @Environment(\.modelContext) private var context
    
    var body: some View {
        NavigationStack {
            GeometryReader {geo in
                ZStack (alignment: .bottomTrailing) {
                    ScrollView(.vertical) {
                        VStack {
                            dashBoardView()   
                            
//                            emptyView()
//                                .frame(height: geo.size.height * 0.7)
                            Divider()
                                .frame(width: 50)
                                .padding(.bottom)
                            
                            ForEach(projectItem.ProjectTasks, id: \.id){task in
                                projectTasksUpdated(task)
                            }
                        }
                    }
                    
                    .scrollIndicators(.hidden)
                    
//                    buttonView()
//                        .frame(alignment: .bottomTrailing)
//                        .padding()
                }
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
        
        .onAppear() {
            viewModel.setProject(projectItem)
        }
        
        .sheet(isPresented: $isEditing){
            DetailsViewSubView(projectItem: projectItem)
        }
        
        .sheet(isPresented: $addingTask) {
            TaskEntryView()
                .presentationDetents([.medium])
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
    func buttonView() -> some View {
        Button {
            withAnimation(.snappy(duration: 0.3)) {
                addingTask = true
            }
        } label: {
            Image(systemName: "plus.circle.fill")
                .resizable()
                .frame(width: 50, height: 50)
        }
        

        .matchedGeometryEffect(id: "addingTask", in: animation)
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
    func projectTasks() -> some View {
        if projectItem.ProjectTasks.isEmpty {
            emptyView()
        } else {
            List {
                Section (header: Text("Tasks")) {
                    ForEach(projectItem.ProjectTasks, id: \.self){task in
                        taskItemView(taskItem: task)
                            .swipeActions(edge: .trailing){
                                Button (role: .destructive) {
                                    projectItem.removeTaskFromProject(task)
                                    context.delete(task)
                                } label: {
                                    Image(systemName: "x.square.fill")
                                }
                                
                                .tint(Color(hex: projectItem.projectColor).opacity(0.4))
                            }
                        
                            .listRowSeparatorTint(Color(uiColor: .systemFill))
                            .listRowBackground(Color(uiColor: .secondarySystemBackground))
                    }
                }
                
                .listStyle(.insetGrouped) 
            }
            
            .scrollIndicators(.hidden)  
            .scrollContentBackground(.hidden)
            .background(Color.clear.edgesIgnoringSafeArea(.all))
        }
    }
    
    @ViewBuilder
    func emptyView() -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(.thinMaterial)
            
            if addingTask {
                taskEntryView()
                    .matchedGeometryEffect(id: "addingTask", in: animation)
                    .padding(.horizontal)
            } else {
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
        }
        
        .padding()
    }
    
    @ViewBuilder
    func taskItemView(taskItem: Task) -> some View {
        HStack {
            Image(systemName: taskItem.isCompleted ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(Color(uiColor: .secondaryLabel))
                .symbolEffect(.bounce, value: taskItem.isCompleted)
                .onTapGesture {
                    taskItem.isCompleted.toggle()
                }
            
            VStack (alignment: .leading, spacing: 5) {
                if (selectedTask == taskItem) {
                    TextField(taskItem.title, text: $taskText)
                        .font(.headline.bold())
                        .opacity(taskItem.isCompleted ? 0.5 : 1.0)
                        .submitLabel(.done)
                        .onSubmit {
                            selectedTask = nil
                            taskItem.title = taskText
                            taskText.removeAll()
                        }
                    
                } else {
                    Text(taskItem.title)
                        .font(.headline.bold())
                        .opacity(taskItem.isCompleted ? 0.5 : 1.0)
                    
                        .onTapGesture {
                            selectedTask = taskItem
                            taskText = taskItem.title
                        }
                }
                
                HStack {
                    if let tag = taskItem.tag {
                        HStack {
                            Menu {
                                Picker("", selection: Binding(
                                    get: { taskItem.tag },
                                    set: { newValue in
                                        taskItem.tag = newValue
                                    }
                                )) {
                                    ForEach(tags, id: \.id) {tag in
                                        Text(tag.name).tag(tag as Tag?)
                                    }
                                }
                            } label: {
                                Text("\(tag.name)")
                                    .padding(7)
                                    .font(.caption.bold())
                                    .foregroundStyle(.white)
                                    .background {
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color(hex: projectItem.projectColor))
                                    }
                            }
                        }
                    }
                    
                    Menu {
                        Picker("", selection: Binding(
                            get: {taskItem.status}, 
                            set: {newValue in 
                                taskItem.status = newValue    
                            }
                        )) {
                            ForEach(Status.allCases, id: \.self){status in
                                Text(String(describing: status))
                            }
                        }
                    } label: {
                        Text("\(String(describing: taskItem.status))")
                            .padding(7)
                            .font(.caption.bold())
                            .foregroundStyle(.white)
                            .background {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color(hex: projectItem.projectColor))
                            }
                    }
                }
                
                .opacity(taskItem.isCompleted ? 0.5 : 1.0)
                .disabled(taskItem.isCompleted)
            }
            Spacer() 
            
            Menu {
                Picker("", selection: Binding(
                    get: {taskItem.priority},
                    set: {newValue in
                        taskItem.priority = newValue
                    }
                )) {
                    ForEach(Priority.allCases, id: \.self){priority in
                        Text(String(describing: priority))    
                    }
                }
            } label: {
                Circle()
                    .fill(taskItem.getPriorityColor())
                    .frame(width: 10, height: 10, alignment: .center)
            }
        }
    }
    
    @ViewBuilder
    func taskEntryView() -> some View {
        ZStack {
            VStack {
                HStack {
                    Image(systemName: "x.circle.fill")
                        .symbolRenderingMode(.multicolor)
                        .foregroundStyle(.red)
                        .imageScale(.medium)
                        .onTapGesture {
                            withAnimation(.smooth(duration: 0.3)) {
                                addingTask = false
                                tagSelection = nil
                            }
                        }
                    
                    VStack (alignment: .leading, spacing: 5) {
                        TextField("New task", text: $taskText)
                            .font(.title2.bold())
                            .tint(Color(hex: projectItem.projectColor))
                            .submitLabel(.done)
                            .onSubmit {
                                if taskText.isEmpty {
                                    return
                                }
                                
                                let newTask = Task(title: taskText, tag: tagSelection, status: statusSelection)
                                projectItem.ProjectTasks.append(newTask)
                                
                                //Cleanup for next task entry
                                taskText.removeAll()
                                tagSelection = nil
                                statusSelection = .Backlog
                                addingTask = false
                            }
                        
                        HStack (spacing: 5) {
                            Menu {
                                Picker("", selection: $tagSelection) {
                                    ForEach(tags, id: \.id){tag in
                                        Text(tag.name).tag(tag as Tag?)
                                    }
                                }
                            } label: {
                                Text(tagSelection != nil ? tagSelection!.name : "Tag")
                                    .padding(7)
                                    .font(.caption.bold())
                                    .foregroundStyle(.white)
                                    .background {
                                        Capsule()
                                            .fill(Color(hex: projectItem.projectColor))
                                    }
                            }
                            
                            Menu {
                                Picker("", selection: $statusSelection) {
                                    ForEach(Status.allCases, id: \.self){status in
                                        Text(String(describing: status))  
                                    }
                                }
                            } label: {
                                Text(String(describing: statusSelection))
                                    .padding(7)
                                    .font(.caption.bold())
                                    .foregroundStyle(.white)
                                    .background {
                                        Capsule()
                                            .fill(Color(hex: projectItem.projectColor))
                                    }
                            }
                        } //HStack 
                    } //VStack 
                } //HStack 
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
        
        let newProject = Project(projectName: "Fini", projectColor: "#1E90FF", projectTasks: [newTask, newTask1, newTask, newTask, newTask, newTask, newTask])
        
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
