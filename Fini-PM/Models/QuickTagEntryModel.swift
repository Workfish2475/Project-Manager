import SwiftUI
import SwiftData

@Observable
class QuickTagEntryModel {
    var tagName: String = ""
    
    func saveTag(_ context: ModelContext) {
        if (tagName.isEmpty) { 
            return
        }
        
        let newTag = Tag(name: tagName)
        
        tagName.removeAll()
        context.insert(newTag)
    }
}
