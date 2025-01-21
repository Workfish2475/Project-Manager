import SwiftUI
import SwiftData

@Model
class Tag {
    @Attribute(.unique) var id: UUID
    var name: String
    
    init(
        id: UUID = UUID(),
        name: String
    ) {
        self.id = id
        self.name = name
    }
}
