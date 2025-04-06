// Credit: https://sarunw.com/posts/swiftui-circular-progress-bar/
// Made some slight modifications to the given variables and adjusted lineWidth.

import SwiftUI

struct CircularProgressView: View {
    let progress: Double
    let ringColor: Color
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(
                    ringColor.opacity(0.5),
                    lineWidth: 10
                )
            
            HStack (alignment: .lastTextBaseline, spacing: 0) {
                Text(String(format: "%.0f%", progress * 100))
                    .font(.title.bold())
                    .fontDesign(.rounded)
                Text("%")
                    .font(.footnote.bold())
                    .foregroundStyle(Color(uiColor: .secondaryLabel))
            }
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    ringColor,
                    style: StrokeStyle(
                        lineWidth: 10,
                        lineCap: .round
                    )
                )
            
                .rotationEffect(.degrees(-90))
                .animation(.easeOut, value: progress)
        }
        
        .padding()
    }

}

#Preview {
    CircularProgressView(progress: 0.5, ringColor: Color(hex: "#FFFFFF"))
}
