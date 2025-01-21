import SwiftUI

struct DetailsViewSubView: View {
    
    var projectItem: Project
    
    @State private var nameText: String = ""
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        NavigationStack {            
            List {
                projectTitleSection()
                
                Section {
                    sectionItem("Pending", .orange, projectItem.uncompletedTaskCount())
                    sectionItem("Completed", .green, projectItem.completedTaskCount())
                }
                
                Section {
                    sectionItem("High priority", .red, projectItem.priorityTaskCount(.High))
                    sectionItem("Medium priority", .yellow, projectItem.priorityTaskCount(.Medium))
                    sectionItem("Low priority", .green, projectItem.priorityTaskCount(.Low))
                }
            }
            
            .listRowSpacing(10)
            .navigationTitle("Project Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .symbolRenderingMode(.hierarchical)
                    }
                    .tint(Color(hex: projectItem.projectColor))
                }
                
                ToolbarItem(placement: .topBarLeading){
                    Button (projectItem.isArchived ? "Unarchive" : "Archive") {
                        projectItem.isArchived.toggle()
                    }
                    
                    .fontWeight(.medium)
                    .font(.subheadline)
                    .tint(Color(hex: projectItem.projectColor))
                }
            } 
        }
    }
    
    @ViewBuilder
    func projectTitleSection() -> some View {
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
        
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 10)
                .fill(colorScheme == .light ? Color(uiColor: .systemBackground) : Color(uiColor: .secondarySystemBackground))
            
        }
    }
    
    
    @ViewBuilder
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

#Preview {
    DetailsViewSubView(projectItem: .init(projectName: "Fini", projectColor: "#C8A2C8"))
}
