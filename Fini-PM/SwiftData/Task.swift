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
    var lastUpdated: Date
    var project: Project
    
    init (
        id: UUID = UUID(),
        title: String,
        desc: String = "",
        tag: Tag? = nil,
        isCompleted: Bool = false,
        status: Status = .Backlog,
        priority: Priority = .None,
        lastUpdated: Date = .now,
        project: Project
    ){
        self.id = id
        self.title = title  
        self.desc = desc
        self.tag = tag
        self.isCompleted = isCompleted
        self.status = status
        self.priority = priority
        self.lastUpdated = lastUpdated
        self.project = project
    }
    
    static func saveTask(taskName: String, taskTag: Tag? = nil, project: Project, context: ModelContext) {
        let newTask = Task(title: taskName, tag: taskTag, project: project)
        
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
    
    func updateStatus() -> Void {
        switch self.status {
        case .Backlog:
            self.status = .Doing
        case .Doing:
            self.status = .Review
        case .Review:
            self.status = .Done
        case .Done:
            self.status = .Review
        }
    }
}

//TODO: Implement image var with switch in enum
enum Status: CaseIterable, Codable {
    case Backlog, Doing, Review, Done
}

//TODO: Implement image var with switch in enum
enum Priority: CaseIterable, Codable {
    case None, Low, Medium, High
}

extension Task {
    //TODO: Setup some demo placeholder items that can be used in the previews for troubleshooting/debugging
}
