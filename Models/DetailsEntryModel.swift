import SwiftUI
import SwiftData

class DetailsEntryModel: ObservableObject {
    var projectItem: Project?
    var taskItem: Task?
    
    @Published var taskIsNil: Bool = false
    
    @Published var taskItemTitle: String = ""
    @Published var taskItemDesc: String = ""
    
    @Published var tag: Tag? = nil
    
    @Published var status: Status = .Backlog
    @Published var priority: Priority = .None
    
    @Published var addingDesc: Bool = false
    
    @Query var tags: [Tag]

    //TODO: Look over this to make sure this is good before pushing.
    func resetState() -> Void {
        addingDesc = false
        taskItemTitle.removeAll()
        taskItemDesc.removeAll()
        status = .Backlog
        priority = .None
        tag = nil
    }
    
    func setProjectItem(_ projectItem: Project) -> Void {
        self.projectItem = projectItem
    }
    
    func setTaskItem(_ taskItem: Task) -> Void {
        self.taskItem = taskItem
        
        self.taskItemTitle = self.taskItem!.title
        self.taskItemDesc = self.taskItem!.desc
        self.tag = self.taskItem!.tag
        self.status = self.taskItem!.status
        self.priority = self.taskItem!.priority
    }
    
    func addTaskToProject(_ task: Task) -> Void {
        guard let projectItem = projectItem else {
            print("Task item or project item is nil")
            return
        }
        
        projectItem.ProjectTasks.append(task)
    }
    
    //TODO: Look over this to make sure this is good before pushing.
    func saveTask(_ context: ModelContext) -> Void {
        if (taskItemTitle.isEmpty) {
            return
        }
        
        let newTask = Task(title: taskItemTitle, desc: taskItemDesc, tag: tag,status: status, priority: priority, project: projectItem!)
        context.insert(newTask)
        resetState()
    }
    
    func setProject() {
        guard let taskItem = taskItem, let projectItem = projectItem else {
            print("Task item or project item is nil")
            return
        }
        
        taskItem.project = projectItem
    }
    
    func updatePriority() -> Void {
        guard let taskItem = taskItem else {
            return
        }
        
        taskItem.priority = priority
    }
}
