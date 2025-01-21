import SwiftUI

@Observable
class DetailsViewModel {
    var projectItem: Project?
    
    func setProject(_ projectItem: Project) -> Void {
        self.projectItem = projectItem
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
