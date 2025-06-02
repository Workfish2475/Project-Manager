import SwiftUI
import SwiftData

struct ProgressCardView: View {
    let currentStatus: Status
    
    @State var selectedTask: Task? = nil
    @EnvironmentObject var accentColorManager: AccentColorManager
    
    @Query var allTasks: [Task]
    
    @Namespace var animation

    var tasks: [Task] {
        if (currentStatus == .Done) {
            allTasks.filter { $0.status == currentStatus && Calendar.current.isDateInToday($0.lastUpdated) }
        } else {
            allTasks.filter { $0.status == currentStatus }
        }
    }

    var body: some View {
        if tasks.isEmpty {
            emptyView
        } else {
            listView
        }
    }
    
    private var emptyView: some View {
        VStack(spacing: 10) {
            HStack {
                Text(String(describing: currentStatus))
                    .font(.title2.bold())
                
                Spacer()
                
                Text("0")
                    .font(.title3.bold())
            }
            
            .padding()
            
            VStack (spacing: 10) {
                Spacer()
                Image(systemName: "checkmark.rectangle.stack.fill")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .foregroundStyle(accentColorManager.accentColor)
                
                Text("No tasks with this status")
                    .font(.headline.bold())
                Spacer()
            }
        }
    }
    
    private var listView: some View {
        VStack(spacing: 10) {
            HStack {
                Text(String(describing: currentStatus))
                    .font(.title2.bold())
                    .fontDesign(.rounded)
                Spacer()
                Text("\(tasks.count)")
                    .font(.title3.bold())
                    .fontDesign(.rounded)
            }
            .padding()
            
            ScrollView (.vertical) {
                ForEach(tasks, id: \.id) {task in
                    taskItemView(taskItem: task)
                        .padding(.horizontal)
                        .frame(minHeight: 50)
                        .onTapGesture {
                            selectedTask = task
                        }
                }
                Spacer()
            }
            
            .scrollIndicators(.hidden)
        }
        
        .sheet(item: $selectedTask) {task in
            TaskCardView(taskItem: task)
                .presentationDetents([.height(600), .large])
        }
    }
    
    func taskItemView(taskItem: Task) -> some View {
        HStack {
            Button {
                withAnimation (.bouncy) {
                    taskItem.updateStatus()
                }
                
                if (taskItem.status == .Done) {
                    taskItem.isCompleted = true
                } else {
                    taskItem.isCompleted = false
                }
                
                taskItem.lastUpdated = .now
            } label: {
                Image(systemName: taskItem.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(Color(hex: taskItem.project.projectColor))
                    .symbolEffect(.bounce, value: taskItem.isCompleted)
            }
            
            VStack (alignment: .leading) {
                Text(taskItem.title)
                    .font(.headline.bold())
                
                Text(String(describing: taskItem.project.projectName))
                    .font(.caption.bold())
                    .foregroundStyle(Color(hex: taskItem.project.projectColor))
                    .padding(.bottom, 5)
                
                if (!taskItem.desc.isEmpty) {
                    Text(taskItem.desc)
                        .font(.subheadline)
                        .lineLimit(3)
                }
                
                if (taskItem.tag != nil) {
                    HStack (spacing: 5) {
                        if taskItem.tag != nil {
                            Text(taskItem.tag!.name)
                                .font(.caption.bold())
                                .padding(5)
                                .foregroundStyle(Color(hex: taskItem.project.projectColor))
                                .background {
                                    RoundedRectangle(cornerRadius: 5) 
                                        .fill(Color(hex: taskItem.project.projectColor).opacity(0.1))
                                        .stroke(Color(hex: taskItem.project.projectColor), lineWidth: 2)
                                        .clipShape(RoundedRectangle(cornerRadius: 5))
                                }
                        }
                        
                        Spacer()
                    }
                }    
            }
            .padding(.vertical)
            
            Spacer()
            Circle()
                .fill(taskItem.getPriorityColor())
                .frame(width: 10, height: 10)
                .padding()
        }
        
        .padding(.leading)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(uiColor: .systemBackground))
        )
        .matchedGeometryEffect(id: "updatingStatus\(taskItem.id)", in: animation)
    }
}

#Preview {
    @Previewable @StateObject var accentColor = AccentColorManager()
    @Previewable @AppStorage("appearance") var appearance: Appearance = .system
    
    ProgressCardView(currentStatus: .Backlog)
        .environmentObject(accentColor)
        .modelContainer(for: [Tag.self, Project.self, Task.self])
}
