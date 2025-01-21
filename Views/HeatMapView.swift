import SwiftUI

struct HeatMapView: View {
    
    var numOfMonthDays: Int {
        let calendar = Calendar.current
        if let dateInterval = calendar.dateInterval(of: .month, for: Date()) {
            let start = dateInterval.start
            let end = dateInterval.end
            let days = calendar.dateComponents([.day], from: start, to: end).day ?? 0
            return days
        }
        
        return 0
    }

    
    var body: some View {
        Text("Something")
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
    HeatMapView()
}
