import SwiftUI
import SwiftData

// This should use @Observable
class TaskEntryModel: ObservableObject {
    @Published var title: String = ""
    @Published var description: String = ""
    
    @Published var tag: Tag? = nil
    
    @Published var status: Status = .Backlog
    @Published var priority: Priority = .None
    
    @Query var tags: [Tag]
    
    func resetState() -> Void {
        title.removeAll()
        description.removeAll()
        tag = nil
        status = .Backlog
        priority = .None
    }
    
    func isSaveable() -> Bool {
        return title.isEmpty
    }
    
    func getPriorityColor() -> Color {
        switch priority {
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
}
