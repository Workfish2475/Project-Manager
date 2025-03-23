import SwiftUI
import SwiftData

@Model
class Task {
    @Attribute(.unique) var id: UUID
    var title: String
    var desc: String
    var tag: Tag?
    var isCompleted: Bool
    var status: Status
    var priority: Priority
    @Relationship(inverse: \Project.ProjectTasks) var project: Project?
    
    init (
        id: UUID = UUID(),
        title: String,
        desc: String = "",
        tag: Tag? = nil,
        isCompleted: Bool = false,
        status: Status = .Backlog,
        priority: Priority = .None,
        project: Project? = nil
    ){
        self.id = id
        self.title = title  
        self.desc = desc
        self.tag = tag
        self.isCompleted = isCompleted
        self.status = status
        self.priority = priority
        self.project = project
    }
    
    static func saveTask(taskName: String, taskTag: Tag? = nil, context: ModelContext) {
        let newTask = Task(title: taskName, tag: taskTag)
        
        context.insert(newTask)
        
        do {
            try context.save()
        } catch {
            print("Error: something went wrong during saving, \(error)")
        }
    }
    
    func getPriorityColor() -> Color {
        switch self.priority {
        case .None:
            return .gray
        case .Low:
            return .green
        case .Medium: 
            return .yellow
        case .High:
            return .red
        }
    }
    
    func getPriorityImage() -> String {
        switch self.priority {
        case .None:
            return "checkmark"
        case .Low:
            return "exclamationmark"
        case .Medium:
            return "exclamationmark.2"
        case .High:
            return "exclamationmark.3"
        }
    }
    
    func getStatusImage() -> String {
        switch self.status {
        case .Backlog:
            return "book.closed.fill"
        case .Doing:
            return "hourglass"
        case .Review:
            return "magnifyingglass"
        case .Done:
            return "checkmark"
        }
    }
    
    //Testing required
    func updateStatus() -> Void {
        switch self.status {
        case .Backlog:
            self.status = .Doing
        case .Doing:
            self.status = .Done
        case .Done: 
            self.status = .Review
        case .Review:
            self.status = .Review
        }
    }
}

enum Status: CaseIterable, Codable {
    case Backlog, Doing, Review, Done
}

enum Priority: CaseIterable, Codable {
    case None, Low, Medium, High
}
