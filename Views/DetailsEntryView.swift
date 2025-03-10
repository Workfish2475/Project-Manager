import SwiftUI
import SwiftData

struct DetailsEntryView: View {
    
    var project: Project
    var task: Task? = nil
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @StateObject var viewModel: DetailsEntryModel = DetailsEntryModel()
    
    var body: some View {
        HStack (alignment: .center) {
            
            VStack (alignment: .leading) {
                TextField("New task", text: $viewModel.taskItemTitle)
                    .font(.title3.bold())
                    .onSubmit {
                        viewModel.saveTask(modelContext)
                    }
                
                TextField("" ,text: $viewModel.taskItemDesc, axis: .vertical)
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
                    .overlay {
                        if (viewModel.taskItemDesc.isEmpty) {
                            Text("Description")
                                .font(.subheadline.bold())
                                .foregroundStyle(Color(uiColor: .secondaryLabel))
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                    }
                
                    .onSubmit {
                        viewModel.saveTask(modelContext)
                    }
                
                    .scaledToFill()
                
                HStack {
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
                            .foregroundStyle(.white)
                            .background(
                                Capsule()
                                    .fill(Color(hex: project.projectColor))
                            )
                    }
                    
                    Menu {
                        Picker("", selection: $viewModel.tag){
                            ForEach(viewModel.tags, id: \.id){tag in
                                Text(tag.name)
                            }
                        }
                    } label: {
                        Text(viewModel.tag != nil ? String(describing: viewModel.tag!.name) : "None")
                            .font(.caption.bold())
                            .foregroundStyle(.white)
                            .padding(5)
                            .background(
                                Capsule()
                                    .fill(Color(hex: project.projectColor))
                            )
                    }
                    
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
