import SwiftUI
import SwiftData

struct TaskCardView: View {
    var taskItem: Task
    
    @Query private var tags: [Tag]
    
    //TODO: Move this to a view model
    @State private var titleField: String = ""
    @State private var descField: String = ""
    
    @State private var taskItemTag: Tag? = nil
    @State private var presentingConfirm: Bool = false
    
    @FocusState private var editingTitle: Bool
    @FocusState private var editingDesc: Bool 
    
    @EnvironmentObject var accentColorManager: AccentColorManager
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    
    init(taskItem: Task) {
        self.taskItem = taskItem
        
        _titleField = State(initialValue: taskItem.title)
        _descField = State(initialValue: taskItem.desc)
        
        if taskItem.tag != nil {
            _taskItemTag = State(initialValue: taskItem.tag!)
        }
    }
    
    private var projectColor: Color {
        return Color(hex: taskItem.project.projectColor)
    }
    
    var body: some View {
        NavigationStack {
            ZStack (alignment: .bottom) {
                ScrollView (.vertical) {
                    taskTitle
                    
                    Group {
                        descSection
                        prioritySection
                        statusSection
                        tagSection
                    }
                   
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(uiColor: .secondarySystemBackground))
                    )
                    .padding(.horizontal)
                    
                    controlButtons
                }
                
                if presentingConfirm {
                    confirmationView
                        .zIndex(1)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            
            
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                 ToolbarItem(placement: .topBarTrailing) {
                     Button {
                         dismiss()
                     } label: {
                         Image(systemName: "xmark.circle.fill")
                             .tint(.secondary)
                             .symbolRenderingMode(.hierarchical)
                     }
                 }
                 
                 ToolbarItem(placement: .principal) {
                     Text("Edit task")
                         .font(.subheadline.bold())
                         .foregroundStyle(Color(uiColor: .secondaryLabel))
                 }
             }
        }
        
        .tint(accentColorManager.accentColor)
    }
    
    private var confirmationView: some View {
        VStack (spacing: 5) {
            Group {
                Text("Are you sure?")
                    .font(.headline)
                Text("This action cannot be undone.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Divider()
                .hidden()
            
            HStack(spacing: 16) {
                Button(role: .cancel) {
                    withAnimation (.bouncy(duration: 0.3)) {
                        presentingConfirm.toggle()
                    }
                } label: {
                    Label("Cancel", systemImage: "xmark")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.secondary)

                Button(role: .destructive) {
                    dismiss()
                    context.delete(taskItem)
                } label: {
                    Label("Trash", systemImage: "trash.fill")
                        .frame(maxWidth: .infinity)
                }
                .tint(.red)
                .buttonStyle(.borderedProminent)
            }
            
            .frame(maxWidth: .infinity)
            .padding()
        }
        
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(.ultraThinMaterial)
                .shadow(radius: 0.5)
        )
        .padding(.horizontal)
    }
    
    private var controlButtons: some View {
        HStack {
            Button (role: .destructive) {
                withAnimation (.bouncy(duration: 0.3)) {
                    presentingConfirm.toggle()
                }
            } label: {
                Image(systemName: "trash.fill")
                    .fontWeight(.bold)
            }
            
            Divider()
            
            if (taskItem.status == .Done) {
                Button {
                    taskItem.isCompleted.toggle()
                } label: {
                    Image(systemName: taskItem.isCompleted ? "xmark" : "checkmark")
                        .fontWeight(.bold)
                }
            } else {
                Button {
                    taskItem.updateStatus()
                    
                    if (taskItem.status == .Done) {
                        taskItem.isCompleted = true
                    } else {
                        taskItem.isCompleted = false
                    }
                } label: {
                    Image(systemName: "arrow.right")
                }
            }
        }
        
        .padding()
        .background(
            Capsule()
                .fill(Color(uiColor: .secondarySystemBackground))
        )
        .padding()
    }
    
    private var taskTitle: some View {
        VStack (alignment: .leading) {
            TextField(taskItem.title, text: $titleField)
                .font(.title.bold())
                .padding(.horizontal)
                .submitLabel(.done)
            
            HStack (spacing: 5) {
                Text(taskItem.isCompleted ? "Done" : "Pending")
                    .foregroundStyle(taskItem.isCompleted ? .green : .orange)
                    .font(.subheadline.bold())
                
                Divider()
                    
                Text(taskItem.project.projectName)
                    .font(.subheadline.bold())
                    .foregroundStyle(Color(hex: taskItem.project.projectColor))
            }
            
            .padding([.horizontal])
        }
    }
    
    private var descSection: some View {
        TextField("", text: $descField, axis: .vertical)
            .font(.system(size: 18))
            .scrollContentBackground(.hidden)
            .submitLabel(.done)
            .scrollIndicators(.hidden)
            .focused($editingDesc)
            .lineLimit(3)
            .frame(maxHeight: 100)
            .onChange(of: editingDesc) {
                taskItem.desc = descField
            }
        
            .overlay {
                if descField.isEmpty && !editingDesc {
                    Text("Add description")
                        .font(.headline.bold())
                        .foregroundStyle(Color(uiColor: .secondaryLabel))
                }
            }
        
            .scaledToFill()
    }
    
    private var prioritySection: some View {
        HStack {
            Text("Priority")
            
            Spacer()
            
            Text(String(describing: taskItem.priority))
                .foregroundStyle(Color(uiColor: .secondaryLabel))
                .fontWeight(.bold)
            
            Menu {
                Picker("", selection: Binding(
                    get: { taskItem.priority },
                    set: { newValue in
                        taskItem.priority = newValue
                    }
                )){
                    ForEach(Priority.allCases, id: \.self){priority in
                        Text(String(describing: priority))
                    }
                }
            } label: {
                Circle()
                    .fill(taskItem.getPriorityColor())
                    .frame(width: 20, height: 20)
            }
        }
    }
    
    private var statusSection: some View {
        HStack {
            Text("Status")
            
            Spacer()
            
            Text(String(describing: taskItem.status))
                .foregroundStyle(Color(uiColor: .secondaryLabel))
                .fontWeight(.bold)
            
            Menu {
                Picker("", selection: Binding(
                    get: { taskItem.status },
                    set: { newValue in
                        taskItem.status = newValue
                    }
                )) {
                    ForEach(Status.allCases, id: \.self){status in
                        Text(String(describing: status))
                    }
                }
            } label: {
                //enum here to get relevant image
                Image(systemName: taskItem.getStatusImage())
                    .fontWeight(.bold)
                    .font(.headline)
            }
        }
    }
    
    private var tagSection: some View {
        HStack {
            Text("Tag")
            
            Spacer()
            
            Text(taskItem.tag != nil ? String(describing: taskItem.tag!.name) : "None")
                .foregroundStyle(Color(uiColor: .secondaryLabel))
                .fontWeight(.bold)
            
            Menu {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(tags, id: \.id) { tag in
                        Button(String(describing: tag.name)) {
                            taskItem.tag = tag
                        }
                    }
                    
                    Divider()
                    
                    Button("None") {
                        taskItem.tag = nil
                    }
                }
            } label: {
                Image(systemName: "tag.fill")
            }
        }
    }
}

struct TaskCardView_Previews: PreviewProvider {
    static var previews: some View {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: Tag.self, Task.self, Project.self, configurations: config)
        
        let newProject = Project(projectName: "ShipIt", projectColor: "#555")
        
        let newTag = Tag(name: "Testing")
        let newTag1 = Tag(name: "QoL")
        container.mainContext.insert(newTag)
        container.mainContext.insert(newTag1)
        container.mainContext.insert(newProject)
        
        let taskItem = Task(title: "Finish something", desc: "", tag: newTag, project: newProject)
        container.mainContext.insert(taskItem)
        
        return TaskCardView(taskItem: taskItem)
            .modelContainer(container)
            .environmentObject(AccentColorManager())
    }
}
