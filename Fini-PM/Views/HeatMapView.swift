import SwiftUI

struct HeatMapView: View {
    
    var projectColor: Color
    var projectTasks: [Task]
    
    var last4Weeks: [Date] {
        var dates: [Date] = []
        let calendar = Calendar.current
        for day in 0...27 {
            if let date = calendar.date(byAdding: .day, value: -day, to: Date()) {
                dates.append(date)
            }
        }
        return dates.reversed()
    }
    
    var dict: [Date: Int] {
        var dict: [Date: Int] = [:]
        let calendar = Calendar.current
        for date in last4Weeks {
            let dateKey = calendar.startOfDay(for: date)
            dict[dateKey] = projectTasks.filter { task in
                calendar.isDate(task.lastUpdated, inSameDayAs: dateKey)
            }.count
        }
        
        return dict
    }
    
    let columns: [GridItem] = Array(repeating: GridItem(.flexible()), count: 7)
    
    var body: some View {
        LazyVGrid (columns: columns, spacing: 5) {
            ForEach(last4Weeks, id: \.self) { day in
                
                let datekey = Calendar.current.startOfDay(for: day)
                
                RoundedRectangle(cornerRadius: 5)
                    .frame(width: 45, height: 35)
                    .foregroundColor(dict[datekey] == 0 ? .gray.opacity(0.7) : .green.opacity(setOpacity(dict[datekey]!)))
            }
        }
        
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(uiColor: .secondarySystemBackground))
        )
        .padding()
    }
    
    func setOpacity(_ value: Int) -> Double {
        switch value {
            case let x where x > 2:
                return 0.7
            case let x where x > 1:
                return 0.5
            case let x where x > 0:
                return 0.3
            default:
                return 0.3
        }
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
