import SwiftUI
import SwiftData

@Model
class Project {
    @Attribute(.unique) var id: UUID
    var projectName: String
    var projectColor: String
    var isArchived: Bool
    
    @Relationship(deleteRule: .cascade, inverse: \Task.project) var projectTasks: [Task]
    
    //MARK: - flags for supported devices
    var isMobile: Bool = false
    var isPad: Bool = false
    var isDesktop: Bool = false
    var isTV: Bool = false
    var isWatch: Bool = false
    var isWeb: Bool = false
    
    var supportedDevices: Set<Devices> {
        get {
            var devices: Set<Devices> = []
            
            if self.isMobile {
                devices.insert(.Mobile)
            }
            if self.isPad {
                devices.insert(.Tablet)
            }
            if self.isDesktop {
                devices.insert(.Desktop)
            }
            if self.isTV {
                devices.insert(.Tv)
            }
            if self.isWatch {
                devices.insert(.Watch)
            }
            if self.isWeb {
                devices.insert(.Web)
            }
            
            return devices
        }
        set {
            isMobile = newValue.contains(.Mobile)
            isPad = newValue.contains(.Tablet)
            isDesktop = newValue.contains(.Desktop)
            isTV = newValue.contains(.Tv)
            isWatch = newValue.contains(.Watch)
            isWeb = newValue.contains(.Web)
        }
    }
    
    init(
        id: UUID = UUID(),
        projectName: String,
        projectColor: String,
        projectTasks: [Task] = [],
        isArchived: Bool = false,
    ) {
        self.id = id
        self.projectName = projectName
        self.projectColor = projectColor
        self.projectTasks = projectTasks
        self.isArchived = isArchived
        
        self.isMobile = supportedDevices.contains(.Mobile)
        self.isPad = supportedDevices.contains(.Tablet)
        self.isDesktop = supportedDevices.contains(.Desktop)
        self.isTV = supportedDevices.contains(.Tv)
        self.isWatch = supportedDevices.contains(.Watch)
        self.isWeb = supportedDevices.contains(.Web)
    }
    
    static func saveProject(projectItemName: String, projectItemColor: Color, context: ModelContext) {
        let newProject = Project(projectName: projectItemName, projectColor: projectItemColor.getColorHex())
        
        context.insert(newProject)
        
        do {
            try context.save()
        } catch {
            print("error: \(error)")
        }
    }
    
    func progressValue() -> Double {
        guard !self.projectTasks.isEmpty else { return 0 }
        
        let finishedTasks = self.projectTasks.filter { $0.isCompleted }
        return Double(finishedTasks.count) / Double(self.projectTasks.count)
    }
    
    func completedTaskCount() -> Int {
        return self.projectTasks.filter { $0.isCompleted }.count
    }
    
    func uncompletedTaskCount() -> Int {
        return self.projectTasks.filter { !$0.isCompleted }.count
    }
    
    func statusTaskCount(_ status: Status) -> Int {
        return self.projectTasks.filter {
            $0.status == status && !$0.isCompleted
        }.count
    }
    
    func priorityTaskCount(_ priority: Priority) -> Int {
        return self.projectTasks.filter {
            $0.priority == priority && !$0.isCompleted
        }.count
    }
    
    func removeTaskFromProject(_ targetTask: Task) -> Void {
        self.projectTasks.removeAll(where: { $0.id == targetTask.id })
    }
    
    static func getArchivedProjects() -> Predicate<Project> {
        return #Predicate<Project> {
            $0.isArchived
        }
    }
}

// MARK: - Device type enum
enum Devices {
    case Desktop
    case Mobile
    case Tablet
    case Tv
    case Web
    case Watch
    
    var deviceImage: Image {
        switch self {
            case .Desktop:
                return Image(systemName: "desktopcomputer")
            case .Mobile:
                return Image(systemName: "smartphone")
            case .Tablet:
                return Image(systemName: "ipad")
            case .Tv:
                return Image(systemName: "tv")
            case .Web:
                return Image(systemName: "safari")
        case .Watch:
            return Image(systemName: "applewatch")
        }
    }
}
