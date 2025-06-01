import SwiftUI
import SwiftData

@Observable
class DetailsEntryModel {
    var projectItem: Project?
    var taskItem: Task?
    
    var taskIsNil: Bool = false
    var taskItemTitle: String = ""
    
    var taskItemDesc: String = ""
    
    var tag: Tag? = nil
    
    var status: Status = .Backlog
    var priority: Priority = .None
    
    var addingDesc: Bool = false

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
        
        projectItem.projectTasks.append(task)
    }
    
    func saveTask(_ context: ModelContext) {
        if let existingTask = taskItem {
            existingTask.title = taskItemTitle
            existingTask.desc = taskItemDesc
            existingTask.tag = tag
            existingTask.status = status
            existingTask.priority = priority
        } else {
            guard let project = projectItem, !taskItemTitle.isEmpty else { return }
            let newTask = Task(title: taskItemTitle, desc: taskItemDesc, tag: tag, status: status, priority: priority, project: project)
            context.insert(newTask)
        }

        try? context.save()
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
    
    func updateStatus() -> Void {
        guard let taskItem = taskItem else {
            return
        }
        
        taskItem.status = status
    }
    
    func updateTag() -> Void {
        guard let taskItem = taskItem else {
            return
        }
        
        taskItem.tag = tag
    }
    
    func deleteTask(_ task: Task? = nil, _ context: ModelContext) {
        if let task = task {
            context.delete(task)
            
            do {
                try context.save()
            } catch {
                print("Error deleting task: \(error)")
            }
        }
    }
}
