import SwiftUI
import SwiftData

struct ProgressCardView: View {
    let currentStatus: Status
    let projects: [Project]
    
    @State var selectedTask: Task? = nil
    @EnvironmentObject var accentColorManager: AccentColorManager
    
    var projectItems: [Task] {
        let uniqueTasks = Set(
            projects.flatMap { project in
                project.ProjectTasks.filter { $0.status == currentStatus }
            }
        )
        return Array(uniqueTasks)
    }
    
    var body: some View {
        if projectItems.isEmpty {
            emptyView()
        } else {
            listView()
        }
    }
    
    @ViewBuilder
    func emptyView() -> some View {
        VStack(spacing: 10) {
            HStack {
                Text(String(describing: currentStatus))
                    .font(.title2.bold())
                    .fontDesign(.rounded)
                
                Spacer()
                
                Text("0")
                    .font(.title3.bold())
                    .fontDesign(.rounded)
            }
            
            .padding()
            
            VStack (spacing: 10) {
                Spacer()
                Image(systemName: "checkmark.rectangle.stack.fill")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .foregroundStyle(accentColorManager.accentColor)
                
                Text("No tasks with this status")
                    .font(.headline.bold())
                Spacer()
            }
        }
    }
    
    @ViewBuilder
    func listView() -> some View {
        VStack(spacing: 10) {
            HStack {
                Text(String(describing: currentStatus))
                    .font(.title2.bold())
                    .fontDesign(.rounded)
                
                Spacer()
                
                Text("\(projectItems.count)")
                    .font(.title3.bold())
                    .fontDesign(.rounded)
            }
            
            .padding()
            
            ScrollView (.vertical) {
                ForEach(projectItems, id: \.id) {task in
                    taskItemView(taskItem: task)
                        .padding(.horizontal)
                        .frame(minHeight: 100)
                        .onTapGesture {
                            selectedTask = task
                        }
                }
                
                Spacer()
            }
            
            .scrollIndicators(.hidden)
        }
        
        .sheet(item: $selectedTask) {task in
            TaskCardView(taskItem: task)
                .presentationDetents([.height(500), .large])
        }
    }
    
    @ViewBuilder
    func taskItemView(taskItem: Task) -> some View {
        HStack {
            Button {
                taskItem.isCompleted.toggle()
            } label: {
                Image(systemName: taskItem.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(.white)
                    .symbolEffect(.bounce, value: taskItem.isCompleted)
            }
            
            VStack (alignment: .leading) {
                Text(taskItem.title)
                    .font(.headline.bold())
                    .foregroundStyle(.white)
                
                Text(taskItem.desc)
                    .font(.subheadline)
                    .foregroundStyle(.white)
                
                HStack (spacing: 5) {
                    if taskItem.tag != nil {
                        Text(taskItem.tag!.name)
                            .font(.caption.bold())
                            .foregroundStyle(.white)
                            .padding(7)
                            .background {
                                Capsule()
                                    .fill(.thinMaterial)
                            }
                    }
                    
                    Spacer()
                }
            }
            .padding(.vertical)
            
            Spacer()
            
            Menu {
                Picker("", selection: Binding(
                    get: { taskItem.priority },
                    set: { newValue in
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
                    .frame(width: 10, height: 10)
                    .padding()
            }
        }
        
        .padding(.leading)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(accentColorManager.accentColor)
        )
    }
}

struct ProjCardView_Previews: PreviewProvider {
    static var previews: some View {
        // Configure an in-memory-only model container for testing
        let config = ModelConfiguration(isStoredInMemoryOnly: false)
        let container = try! ModelContainer(for: Tag.self, Task.self, Project.self, configurations: config)
        
        // Create unique tags
        let tag1 = Tag(name: "Testing")
        let tag2 = Tag(name: "UI")
        let tag3 = Tag(name: "Backend")
        let tag4 = Tag(name: "User study")
        
        // Create distinct tasks
        let task1 = Task(title: "Design UI", desc: "Make sure to get everything aligned nicely.", tag: tag2, status: .Backlog)
        let task2 = Task(title: "Debugging", tag: tag1, status: .Review)
        
        // Create projects with different tasks
        let project1 = Project(projectName: "Project Alpha", projectColor: "#FF5733", projectTasks: [task1])
        let project2 = Project(projectName: "Project Beta", projectColor: "#33FF57", projectTasks: [task2])
        
        // Insert data into the model container
        container.mainContext.insert(project1)
        container.mainContext.insert(project2)
        container.mainContext.insert(tag1)
        container.mainContext.insert(tag2)
        container.mainContext.insert(tag3)
        container.mainContext.insert(tag4)
        container.mainContext.insert(task1)
        container.mainContext.insert(task2)
        
        // Return the view with the container and any required environment objects
        return ProjProgressView()
            .modelContainer(container)
            .environmentObject(AccentColorManager())
    }
}
