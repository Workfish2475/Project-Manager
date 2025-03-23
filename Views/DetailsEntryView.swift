import SwiftUI
import SwiftData

struct DetailsEntryView: View {
    
    var project: Project
    var task: Task?
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @Query var tags: [Tag]
    
    @State private var creatingTag: Bool = false
    @State private var tagName: String = ""
    
    @StateObject var viewModel: DetailsEntryModel = DetailsEntryModel()
    
    var body: some View {
        HStack (alignment: .center) {
            VStack (alignment: .leading, spacing: 15) {
                TextField("New task", text: $viewModel.taskItemTitle)
                    .font(.title3.bold())
                    .onSubmit {
                        viewModel.saveTask(modelContext)
                    }
                
                TextField("Description" ,text: $viewModel.taskItemDesc, axis: .vertical)
                    .font(.subheadline.bold())
                    .scrollContentBackground(.hidden)
                    .padding()
                    .lineLimit(3)
                    .submitLabel(.done)
                    .foregroundStyle(Color(uiColor: .secondaryLabel))
                    .background(
                        Color(uiColor: .secondarySystemBackground)
                    )
                
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .onSubmit {
                        viewModel.saveTask(modelContext)
                    }
                
                    .scaledToFill()
                
                HStack {
                    HStack (spacing: 5) {
                        Menu {
                            Picker("", selection: $viewModel.status){
                                ForEach(Status.allCases, id: \.self){status in
                                    Text(String(describing: status)) 
                                }
                            }
                        } label: {
                            Text(String(describing: viewModel.status))
                                .font(.caption.bold())
                                .padding(5)
                                .foregroundStyle(Color(hex: project.projectColor))
                        }
                        
                        Divider()
                            .frame(width: 2, height: 10)
                            .overlay(
                                Capsule()
                                    .fill(Color(hex: project.projectColor))
                            )
                        
                        Menu {
                            Section("Other") {
                                Button {
                                    creatingTag.toggle()
                                } label: {
                                    Text("New tag")
                                }
                            }
                            
                            Divider()
                            
                            Section("Tags") {
                                Picker("", selection: $viewModel.tag) {
                                    Text("None")
                                        .tag(nil as Tag?)
                                    
                                    ForEach(tags, id: \.id) { tag in
                                        Text(tag.name)
                                            .tag(tag)
                                    }
                                }
                            }
                            
                        } label: {
                            Text(viewModel.tag != nil ? viewModel.tag!.name : "None")
                                .font(.caption.bold())
                                .foregroundStyle(Color(hex: project.projectColor))
                                .padding(5)
                        }
                    }
                    
                    .background(
                        RoundedRectangle(cornerRadius: 5)
                            .fill(Color(hex: project.projectColor).opacity(0.1))
                            .stroke(Color(hex: project.projectColor), lineWidth: 1)
                    )
                    
                    Spacer()
                    
                    Menu {
                        Picker("", selection: $viewModel.priority) {
                            ForEach(Priority.allCases, id: \.self){priority in
                                Text(String(describing: priority))
                            }
                            
                            .onChange(of: viewModel.priority) {
                                viewModel.updatePriority()
                            }
                        }
                    } label: {
                        Image(systemName: "flag.fill")
                            .frame(width: 20, height: 20)
                            .foregroundStyle(task == nil ? .gray : task!.getPriorityColor())
                    }
                }
            }
        }
        
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(uiColor: .systemBackground))
        )
        .padding(.horizontal)
        
        .popover(isPresented: $creatingTag, arrowEdge: .bottom) {
            QuickTagEntry()
                .padding()
                .frame(minWidth: 350, maxHeight: 400)
                .presentationCompactAdaptation(.popover)
        }
        
        .task {
            viewModel.setProjectItem(project)
            if let task = task {
                viewModel.setTaskItem(task)
            }
        }
    }
}

struct DetailEntryView_Previews: PreviewProvider {
    static var previews: some View {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: Tag.self, Task.self, Project.self, configurations: config)
        
        let newTag1 = Tag(name: "Testing")
        let newTag2 = Tag(name: "UI")
        let newTag3 = Tag(name: "Bugs")
        let newTag4 = Tag(name: "User study")
        
        let newTask = Task(title: "Design task view", desc: "", tag: newTag2)
        let newTask1 = Task(title: "Design task view", tag: newTag1)
        
        let newProject = Project(projectName: "Fini", projectColor: "#1E90FF", projectTasks: [newTask, newTask1, newTask, newTask, newTask, newTask, newTask])
        
        container.mainContext.insert(newTag1)
        container.mainContext.insert(newTag2)
        container.mainContext.insert(newTag3)
        container.mainContext.insert(newTag4)
        container.mainContext.insert(newTask)
        container.mainContext.insert(newTask1)
        container.mainContext.insert(newProject)
        
        return DetailsEntryView(project: newProject, task: newTask, viewModel: .init())
            .modelContainer(container)
            .environmentObject(AccentColorManager())
            .padding(50)
    }
}
