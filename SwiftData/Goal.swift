import SwiftUI
import SwiftData

// TODO: Could probably get rid of this.

@Model
class Goal {
    @Attribute(.unique) var id: UUID
    var title: String
    var tasks: [Task]
    
    init(
        id: UUID = UUID(),
        title: String, 
        tasks: [Task] = []
    ) {
        self.id = id
        self.title = title
        self.tasks = tasks
    }
}
