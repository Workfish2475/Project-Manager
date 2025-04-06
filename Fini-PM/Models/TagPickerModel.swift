//
//  TagPickerModel.swift
//  Fini - Project Manager
//
//  Created by Alexander Rivera on 3/2/25.
//

import SwiftUI
import SwiftData

@Observable
class TagPickerModel {
    
    var addingTag: Bool = false
    var isEditing: Bool = false
    
    var tagName: String = ""
    var tagColor: Color = Color.allList[0]
    
    var focusedTagField: Bool = false
    
    var selectedTags: Set<Tag> = []
    
    func saveTag(_ modelContext: ModelContext) -> Void {
        if tagName.isEmpty {
            return
        }
        
        let newTag = Tag(name: tagName)
        
        modelContext.insert(newTag)
        resetState()
        
        do {
            try modelContext.save()
        } catch {
            print("Error, could not save tag: \(error)")
        }
    }
    
    func resetState() -> Void {
        tagName.removeAll()
        tagColor = Color.allList[0]
        
        isEditing = false
        addingTag = false
    }
    
    func deleteFromSelected(_ context: ModelContext) -> Void {
        for tag in selectedTags {
            context.delete(tag)
        }
        
        selectedTags.removeAll()
    }
    
    func toggleTag(_ tag: Tag) {
        if selectedTags.contains(tag) {
            selectedTags.remove(tag)
            return
        }
        
        selectedTags.insert(tag)
    }
}
