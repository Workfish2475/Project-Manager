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
    var isMobile: Bool = true
    var isPad: Bool = false
    var isDesktop: Bool = false
    var isTv: Bool = false
    var isWeb: Bool = false
    var isWatch: Bool = false
    
    func saveProject(_ modelContext: ModelContext) -> Void {
        if (name.isEmpty) {
            return
        }
        
        let newProject = Project(projectName: name, projectColor: color.getColorHex())
        
        newProject.isMobile = isMobile
        newProject.isPad = isPad
        newProject.isWeb = isWeb
        newProject.isWatch = isWatch
        newProject.isTV = isTv
        newProject.isDesktop = isDesktop
        
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
    
    func updateIsMobile(_ isMobile: Bool) -> Void {
        self.isMobile = isMobile
    }
    
    func updateIsPad(_ isPad: Bool) -> Void {
        self.isPad = isPad
    }
    
    func updateIsWeb(_ isWeb: Bool) -> Void {
        self.isWeb = isWeb
    }
    
    func updateIsWatch(_ isWatch: Bool) -> Void {
        self.isWatch = isWatch
    }
    
    func updateIsTV(_ isTV: Bool) -> Void {
        self.isTv = isTV
    }
    
    func updateIsComputer(_ isDesktop: Bool) -> Void {
        self.isDesktop = isDesktop
    }
}
