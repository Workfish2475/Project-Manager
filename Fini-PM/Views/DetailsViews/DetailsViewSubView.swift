import SwiftUI

struct DetailsViewSubView: View {
    
    var projectItem: Project
    
    @State private var nameText: String = ""
    @State private var editingDevices: Bool = false
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        NavigationStack {            
            List {
                projectTitleSection
                
                Section {
                    supportedDevices
                } footer: {
                    Text("Only highlighted devices are selected.")
                }
                
                
                Section {
                    sectionItem("High priority", .red, projectItem.priorityTaskCount(.High))
                    sectionItem("Medium priority", .yellow, projectItem.priorityTaskCount(.Medium))
                    sectionItem("Low priority", .green, projectItem.priorityTaskCount(.Low))
                }
                
                Section {
                    NavigationLink(destination: filteredItemsView(projectItem: projectItem, title: "Backlog")) {
                        sectionItem("Backlog", .gray, projectItem.projectTasks.filter { $0.status == .Backlog} .count)
                    }
                    
                    NavigationLink(destination: filteredItemsView(projectItem: projectItem, title: "In Progress")) {
                        sectionItem("In Progress", .orange, projectItem.projectTasks.filter { $0.status != .Done} .count)
                    }
                    
                    NavigationLink(destination: filteredItemsView(projectItem: projectItem, title: "Done")) {
                        sectionItem("Done", .green, projectItem.projectTasks.filter { $0.status == .Done} .count)
                    }
                }
            }
            
            .listRowSpacing(10)
            .navigationTitle("Project Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .symbolRenderingMode(.hierarchical)
                    }
                    .tint(.secondary)
                }
                
                ToolbarItem(placement: .topBarLeading){
                    Menu {
                        Button {
                            projectItem.isArchived.toggle()
                        } label: {
                            Label(projectItem.isArchived ? "Unarchive" : "Archive", systemImage: "archivebox")
                        }
                        
                        Divider()
                        
                        Button {
                            
                        } label: {
                            Label("Generate ReadMe", systemImage: "sparkles")
                        }
                        
                        Button {
                            
                        } label: {
                            Label("Generate release notes", systemImage: "document")
                        }
                        
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            } 
        }
        
        .tint(Color(hex: projectItem.projectColor))
    }
    
    private var supportedDevices: some View {
        VStack (alignment: .trailing) {
            HStack {
                Text("Supported Device(s)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Button {
                    editingDevices.toggle()
                } label: {
                    Text(editingDevices ? "Done" : "Edit")
                }
            }
            
            Divider()
            
            ScrollView(.horizontal) {
                HStack {
                    ForEach(Array(projectItem.supportedDevices), id: \.self) { device in
                        switch device {
                            case .Mobile:
                                deviceItem("Mobile", "iphone")
                                    .frame(width: 60, height: 60)
                            case .Tablet:
                                deviceItem("Tablet", "ipad")
                                    .frame(width: 60, height: 60)
                            case .Desktop:
                                deviceItem("Desktop", "desktopcomputer")
                                    .frame(width: 60, height: 60)
                            case .Watch:
                                deviceItem("Watch", "applewatch")
                                    .frame(width: 60, height: 60)
                            case .Tv:
                                deviceItem("Tv", "tv")
                                    .frame(width: 60, height: 60)
                            case .Web:
                                deviceItem("Web", "safari.fill")
                                    .frame(width: 60, height: 60)
                        }
                    }
                }
                
                .frame(height: 60)
            }
        }
    }
    
    private func deviceItem(_ title: String,_ image: String) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(.thinMaterial)
            
            VStack (spacing: 10) {
                Image(systemName: image)
                    .foregroundStyle(.secondary)
                
                Text(title)
                    .font(.caption)
            }
        }
    }
    
    private var projectTitleSection: some View {
        VStack {
            HStack {
                VStack (alignment: .leading) {
                    TextField(projectItem.projectName, text: Binding(
                        get: { projectItem.projectName},
                        set: { newValue in
                            projectItem.projectName = newValue
                        }
                    ))
                    
                    .font(.title3.bold())
                    
                    Text("Project title")
                        .font(.caption.bold())
                        .foregroundStyle(Color(uiColor: .secondaryLabel))
                }
                
                Spacer()
                
                Image(systemName: "pencil.line")
                    .foregroundStyle(Color(uiColor: .secondaryLabel))
            }
            
            Divider()
                .padding(.top)
            
            HStack {
                VStack (alignment: .leading) {
                    TextField("Link", text: Binding(
                        get: { projectItem.gitURL},
                        set: { newValue in
                            projectItem.gitURL = newValue
                        }
                    ))
                    
                    .font(.subheadline)
                    
                    Text("Github Link")
                        .font(.caption.bold())
                        .foregroundStyle(Color(uiColor: .secondaryLabel))
                }
                
                
                if let url = URL(string: projectItem.gitURL) {
                    Link(destination: url) {
                        Image(systemName: "safari")
                    }
                }
            }
            
            .padding(.top)
        }
        
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 10)
                .fill(colorScheme == .light ? Color(uiColor: .systemBackground) : Color(uiColor: .secondarySystemBackground))
            
        }
    }
    
    func sectionItem(_ title: String, _ color: Color, _ count: Int) -> some View {
        VStack (alignment: .leading) {
            Text(title)
                .font(.headline)
                .foregroundStyle(color)
            
            HStack {
                Text("\(count)")
                    .fontDesign(.rounded)
                    .fontWeight(.bold)
                
                Text("Tasks")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundStyle(Color(uiColor: .secondaryLabel))
            }
        }
    }
}

struct sectionItemView: View {
    var title: String = ""
    var color: Color
    
    var body: some View {
        VStack (alignment: .leading) {
            Text(title)
                .font(.headline)
                .foregroundStyle(color)
        }
    }
}

struct filteredItemsView : View {
    
    var projectItem: Project
    var title: String
    
    var tasks: [Task] {
        projectItem.projectTasks.filter { $0.status == .Backlog }
    }
    
    var body: some View {
        List {
            Section {
                ForEach(tasks, id: \.id){ task in
                    sectionItemView(title: task.title, color: .accentColor)
                }
            }
        }
        
        .scrollContentBackground(.hidden)
        .listStyle(.insetGrouped)
        .navigationTitle("\(title)")
        .scrollContentBackground(.hidden)
    }
}

#Preview {
    let projectItem = Project(projectName: "Fini", projectColor: "#aa5ee5")
        
    DetailsViewSubView(projectItem: projectItem)
}
