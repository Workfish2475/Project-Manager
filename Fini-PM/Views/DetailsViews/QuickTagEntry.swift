import SwiftUI

struct QuickTagEntry: View {
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context    
    @State var viewModel: QuickTagEntryModel = QuickTagEntryModel()

    var body: some View {
        VStack (alignment: .leading, spacing: 10) {
            VStack (alignment: .leading, spacing: 5) {
                HStack {
                    Text("New tag")
                        .font(.headline)
                    
                    Spacer()
                    
                    Button {
                        viewModel.saveTag(context)
                        dismiss()
                    } label: {
                        Text("Done")
                            .font(.headline)
                    }
                    
                    .tint(Color.green)
                    .disabled(viewModel.tagName.isEmpty)
                }
            }
            
            HStack {
                TextField("Tag title", text: $viewModel.tagName)
                    .font(.subheadline)
                
                if (!viewModel.tagName.isEmpty) {
                    Image(systemName: "xmark.circle.fill")
                        .symbolRenderingMode(.hierarchical)
                        .onTapGesture {
                            viewModel.tagName.removeAll() 
                        }
                }
            }
            
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(uiColor: .secondarySystemBackground))
            )
        }
        
        //Return the tag here somehow?
        .onDisappear() {
            
        }
    }
}
