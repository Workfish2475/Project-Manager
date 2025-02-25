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
    
    @Query var tags: [Tag]

    func resetState() -> Void {
        
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
    
    func saveTask(_ task: Task, context: ModelContext) -> Void {
        context.insert(task)
    }
    
    func setProject() {
        guard let taskItem = taskItem, let projectItem = projectItem else {
            print("Task item or project item is nil")
            return
        }
        
        taskItem.project = projectItem
    }
}
