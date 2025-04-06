import SwiftUI

//TODO: Need to finish implementing a heatmap depending on what day the tasks are completed.
struct HeatMapView: View {
    
    var projectColor: Color
    var projectTasks: [Task]
    
    var numOfDays: Int {
        return Calendar.current.range(of: .day, in: .month, for: .now)!.count
    }
    
    var today: Int {
        let calendar = Calendar.current
        return calendar.component(.day, from: Date())
    }
    
    let columns: [GridItem] = Array(repeating: GridItem(.flexible()), count: 7)
    
    var body: some View {
        FlowLayout (spacing: 7) {
            ForEach(1...numOfDays, id: \.self) { day in
                RoundedRectangle(cornerRadius: 5)
                    .frame(width: 30, height: 30)
                    .foregroundColor(projectColor)
            }
        }
        
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(uiColor: .secondarySystemBackground))
        )
        .padding()
    }
}

struct ColorSquare: View {
    let color: Color
    
    var body: some View {
        color
            .frame(width: 15, height: 15)
            .clipShape(RoundedRectangle(cornerRadius: 5))
    }
}

#Preview {
    HeatMapView(projectColor: .red, projectTasks: [])
}
