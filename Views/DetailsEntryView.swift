import SwiftUI

struct DetailsEntryView: View {
    
    var viewModel: DetailsEntryModel = DetailsEntryModel()
    
    var body: some View {
        HStack (alignment: .center) {
            Image(systemName: "circle")
            
            VStack (alignment: .leading) {
                TextField("New task", text: viewModel.taskItemTitle)
                    .font(.headline)
                
                Divider()
                
                if !(viewModel.taskItem?.desc.isEmpty) {
                    Text("Description")
                        .font(.caption2.bold())
                        .foregroundStyle(Color(uiColor: .secondaryLabel))
                    
                    Text(viewModel.taskItem.desc)
                        .font(.subheadline)
                }
                
                HStack {
                    Text(String(describing: viewModel.taskItem?.status))
                        .font(.caption)
                        .padding(5)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(hex: viewModel.projectItem?.projectColor).opacity(0.4))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        )
                    
                    if (viewModel.taskItem.tag != nil) {
                        Text(String(describing: viewModel.taskItem.tag.name))
                            .font(.caption)
                            .padding(5)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color(hex: viewModel.projectItem?.projectColor).opacity(0.4))
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            )
                    }
                }
            }
        }
        
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(uiColor: .secondarySystemBackground))
        )
        .padding(.horizontal)
    }
}


#Preview {
    DetailsEntryView()
}
