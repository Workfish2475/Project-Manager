//
//  NewProjectEntryModel.swift
//  Fini - Project Manager
//
//  Created by Alexander Rivera on 2/28/25.
//

import SwiftUI
import SwiftData

@Observable
class NewProjectEntryModel {
    var name: String = ""
    var color: Color = Color.allList[0]
    
    func saveProject(_ modelContext: ModelContext) -> Void {
        if (name.isEmpty) {
            return
        }
        
        let newProject = Project(projectName: name, projectColor: color.getColorHex())
        resetState()
        
        modelContext.insert(newProject)
    }
    
    func changeColor(_ color: Color) -> Void {
        self.color = color
    }
    
    func resetState() -> Void {
        name.removeAll()
        color = Color.allList[0]
    }
}
