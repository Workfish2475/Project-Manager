import SwiftUI
import SwiftData

class DetailsViewModel: ObservableObject {
    @Published var projectItem: Project?
    
    @Published var addingTask: Bool = false
    @Published var isEditing: Bool = false
    @Published var deletingTasks: Bool = false
    @Published var changingColor: Bool = false
    @Published var selectedTask: Task? = nil
    
    func setProject(_ projectItem: Project) -> Void {
        self.projectItem = projectItem
    }
    
    func setSelectedTask(_ taskItem: Task) -> Void {
        selectedTask = taskItem
    }
    
    func clearSelectedTask() -> Void {
        selectedTask = nil
    }
    
    func removeTaskFromProject(_ taskItem: Task) -> Void {
        guard let projectItem = projectItem else {
            print("projectItem is nil")
            return
        }
        
        return projectItem.ProjectTasks.removeAll {
            $0.id == taskItem.id
        }
    }
}

struct DetailViewViewModel_Previews: PreviewProvider {
    static var previews: some View {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: Tag.self, Task.self, configurations: config)
        
        let newTag1 = Tag(name: "Testing")
        let newTag2 = Tag(name: "UI")
        let newTag3 = Tag(name: "Bugs")
        let newTag4 = Tag(name: "User study")
        
        let newTask = Task(title: "Design task view", desc: "Test some things and write some test cases. Do some Unit testing.", tag: newTag2)
        let newTask1 = Task(title: "Design task view", tag: newTag1)
        
        let newProject = Project(projectName: "Fini", projectColor: "#1E90FF", projectTasks: [newTask, newTask1])
        
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
