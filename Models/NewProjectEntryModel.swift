//
//  NewProjectEntryModel.swift
//  Fini - Project Manager
//
//  Created by Alexander Rivera on 2/28/25.
//

import SwiftUI
import SwiftData

class NewProjectEntryModel: ObservableObject {
    @Published var name: String = ""
    @Published var color: Color = Color.allList[0]
    
    func saveProject() -> Void {
        
    }
    
    func changeColor(_ color: Color) -> Void {
        self.color = color
    }
}
