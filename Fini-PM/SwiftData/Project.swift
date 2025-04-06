import SwiftUI
import SwiftData

@Model
class Project {
    @Attribute(.unique) var id: UUID
    var projectName: String
    var projectColor: String
    var ProjectTasks: [Task]
    var isArchived: Bool
    
    init(
        id: UUID = UUID(),
        projectName: String,
        projectColor: String,
        projectTasks: [Task] = [],
        isArchived: Bool = false
    ) {
        self.id = id
        self.projectName = projectName
        self.projectColor = projectColor
        self.ProjectTasks = projectTasks
        self.isArchived = isArchived
    }
    
    static func saveProject(projectItemName: String, projectItemColor: Color, context: ModelContext) {
        let newProject = Project(projectName: projectItemName, projectColor: projectItemColor.getColorHex())
        
        // This should be enough as SwiftData has autosave.
        context.insert(newProject)
        
        do {
            try context.save()
        } catch {
            print("error: \(error)")
        }
    }
    
    func progressValue() -> Double {
        guard !self.ProjectTasks.isEmpty else { return 0 }
        
        let finishedTasks = self.ProjectTasks.filter { $0.isCompleted }
        return Double(finishedTasks.count) / Double(self.ProjectTasks.count)
    }
    
    func completedTaskCount() -> Int {
        return self.ProjectTasks.filter { $0.isCompleted }.count
    }
    
    func uncompletedTaskCount() -> Int {
        return self.ProjectTasks.filter { !$0.isCompleted }.count
    }
    
    func statusTaskCount(_ status: Status) -> Int {
        return self.ProjectTasks.filter {
            $0.status == status && !$0.isCompleted
        }.count
    }
    
    func priorityTaskCount(_ priority: Priority) -> Int {
        return self.ProjectTasks.filter {
            $0.priority == priority && !$0.isCompleted
        }.count
    }
    
    func removeTaskFromProject(_ targetTask: Task) -> Void {
        self.ProjectTasks.removeAll(where: { $0.id == targetTask.id })
    }
    
    static func getArchivedProjects() -> Predicate<Project> {
        return #Predicate<Project> {
            $0.isArchived
        }
    }
}

