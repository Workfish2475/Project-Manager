import SwiftUI

struct HeatMapView: View {
    
    var numOfDays: Int {
        return Calendar.current.range(of: .day, in: .month, for: .now)!.count
    }
    
    var today: Int {
        let calendar = Calendar.current
        return calendar.component(.day, from: Date())
    }
    
    let columns: [GridItem] = Array(repeating: GridItem(.flexible()), count: 7)
    
    //TODO: Something about fetching each task that was completed on that day.
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns) {
                ForEach(1...numOfDays, id: \.self) { day in
                    RoundedRectangle(cornerRadius: 10)
                        .frame(width: 50, height: 50)
                        .foregroundColor(day == today ? .red : .blue)
                        .overlay (
                            Text("\(day)")
                                .font(.headline)
                                .foregroundStyle(.white)
                        )
                }
            }
            
            .padding()
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
    HeatMapView()
}
