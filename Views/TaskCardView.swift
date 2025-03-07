import SwiftUI
import SwiftData

struct TaskCardView: View {
    var taskItem: Task
    
    @Query private var tags: [Tag]
    
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
    
    var body: some View {
        NavigationStack {
            ScrollView (.vertical) {
                VStack (spacing: 0) {
                    taskTitle()
                    HStack {
                        Text(taskItem.isCompleted ? "Done" : "Pending")
                            .foregroundStyle(taskItem.isCompleted ? .green : .orange)
                            .font(.caption.bold())
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                }
                
                TextField("", text: $descField, axis: .vertical)
                    .font(.system(size: 18))
                    .scrollContentBackground(.hidden)
                    .submitLabel(.done)
                    .scrollIndicators(.hidden)
                    .focused($editingDesc)
                    .padding()
                    .lineLimit(3)
                    .frame(maxHeight: 100)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(uiColor: .secondarySystemBackground))
                    )
                    .padding(.horizontal)
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
                
                HStack {
                    Text("Priority")
                    
                    Spacer()
                    
                    Text(String(describing: taskItem.priority))
                        .foregroundStyle(Color(uiColor: .secondaryLabel))
                        .fontWeight(.bold)
                        .fontDesign(.rounded)
                    
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
                
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(uiColor: .secondarySystemBackground))
                )
                .padding(.horizontal)
                
                HStack {
                    Text("Status")
                    
                    Spacer()
                    
                    Text(String(describing: taskItem.status))
                        .foregroundStyle(Color(uiColor: .secondaryLabel))
                        .fontWeight(.bold)
                        .fontDesign(.rounded)
                    
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
                
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(uiColor: .secondarySystemBackground))
                )
                .padding(.horizontal)
                
                HStack {
                    Text("Tag")
                    
                    Spacer()
                    
                    Text(taskItem.tag != nil ? String(describing: taskItem.tag!.name) : "None")
                        .foregroundStyle(Color(uiColor: .secondaryLabel))
                        .fontWeight(.bold)
                        .fontDesign(.rounded)
                    
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
                
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(uiColor: .secondarySystemBackground))
                )
                .padding(.horizontal)
                
                HStack {
                    Button (role: .destructive) {
                        presentingConfirm = true
                    } label: {
                        Image(systemName: "trash.fill")
                            .fontWeight(.bold)
                    }
                    
                    Divider()
                    
                    Button {
                        taskItem.isCompleted.toggle()
                    } label: {
                        Image(systemName: taskItem.isCompleted ? "xmark" : "checkmark")
                            .fontWeight(.bold)
                    }
                }
                
                .padding()
                .background(
                    Capsule()
                        .fill(Color(uiColor: .secondarySystemBackground))
                )
                .padding()
                
                Spacer()
            }
            
            .overlay {
                if (presentingConfirm) {
                   Text("Something")
                }
            }
            
            .navigationBarTitleDisplayMode(.inline)
             .toolbar {
                 ToolbarItem(placement: .topBarTrailing) {
                     Button {
                         dismiss()
                     } label: {
                         Image(systemName: "xmark.circle.fill")
                             .symbolRenderingMode(.hierarchical)
                     }
                 }
                 
                 ToolbarItem(placement: .principal) {
                     Text("Edit task")
                         .font(.subheadline.bold())
                         .fontDesign(.rounded)
                         .foregroundStyle(Color(uiColor: .secondaryLabel))
                 }
             }
        }
        
        .tint(accentColorManager.accentColor)
        .onAppear() {
            titleField = taskItem.title
            
            if !(taskItem.desc.isEmpty) {
                descField = taskItem.desc
            }
            
            if (taskItem.tag != nil) {
                taskItemTag = taskItem.tag
            }
        }
    }
    
    @ViewBuilder
    func taskTitle() -> some View {
        HStack {
            TextField(taskItem.title, text: $titleField)
                .font(.title.bold())
                .fontDesign(.rounded)
                .padding(.horizontal)
                .submitLabel(.done)
            
            Spacer()
        }
        
        .frame(height: 40)
    }
}

struct TaskCardView_Previews: PreviewProvider {
    static var previews: some View {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: Tag.self, Task.self, Project.self, configurations: config)
        
        // Create mock data
        let newTag = Tag(name: "Testing")
        let newTag1 = Tag(name: "QoL")
        container.mainContext.insert(newTag)
        container.mainContext.insert(newTag1)
        
        let taskItem = Task(title: "Finish something", desc: "", tag: newTag)
        container.mainContext.insert(taskItem)
        
        // Render the preview with the model container
        return TaskCardView(taskItem: taskItem)
            .modelContainer(container)
            .environmentObject(AccentColorManager())
    }
}
