//
//  TagPickerModel.swift
//  Fini - Project Manager
//
//  Created by Alexander Rivera on 3/2/25.
//

import SwiftUI
import SwiftData

class TagPickerModel: ObservableObject {
    
    @Published var addingTag: Bool = false
    @Published var isEditing: Bool = false
    
    @Published var tagName: String = ""
    @Published var tagColor: Color = Color.allList[0]
    
    @Published var focusedTagField: Bool = false
    
    @Query var tagItems: [Tag]
    
    func saveTag(_ modelContext: ModelContext) -> Void {
        if tagName.isEmpty {
            return
        }
        
        let newTag = Tag(name: tagName)
        resetState()
        
        modelContext.insert(newTag)
    }
    
    func resetState() -> Void {
        tagName.removeAll()
        tagColor = Color.allList[0]
        
        isEditing = false
        addingTag = false
        focusedTagField = false
    }
    
    func removeTag(_ tag: Tag, _ modelContext: ModelContext) -> Void {
        modelContext.delete(tag)
    }
}
