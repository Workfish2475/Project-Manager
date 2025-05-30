import SwiftUI
import SwiftData

@Observable
class DetailsViewModel {
    var projectItem: Project?
    
    var addingTask: Bool = false
    var isEditing: Bool = false
    var deletingTasks: Bool = false
    var changingColor: Bool = false
    var selectedTask: Task? = nil
    var taskForDel: Set<Task> = []
    var selected: Int = 0
    
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
        
        return projectItem.projectTasks.removeAll {
            $0.id == taskItem.id
        }
    }
    
    func selectForDel() -> Void {
        
    }
    
    func unselectForDel() -> Void {
        
    }
}
