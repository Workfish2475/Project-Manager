import SwiftUI

// Finally implementing some sort of design pattern throughout app.
// The corresponding model is called TaskEntryModel in the models folder

struct TaskEntryView: View {
    
    @FocusState private var editingDesc: Bool
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var viewModel = TaskEntryModel()
    
    var body: some View {
        NavigationStack {
            ScrollView (.vertical) {
                titleField()
                descriptionField()
                priorityPicker()
                statusPicker()
                tagPicker()
                actionButtons()
                    .navigationTitle("New task")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button {
                                dismiss()
                            } label: {
                                Image(systemName: "xmark.circle")
                                    .symbolRenderingMode(.multicolor)
                            }
                        }
                    }
            }
        }
    }
    
    @ViewBuilder
    func titleField() -> some View {
        HStack {
            TextField("Task title", text: $viewModel.title)
                .font(.title.bold())
                .padding(.horizontal)
                .submitLabel(.done)
            Spacer()
        }
        
        .frame(height: 40)
    }
    
    @ViewBuilder
    func descriptionField() -> some View {
        TextEditor(text: $viewModel.description)
            .font(.system(size: 18))
            .focused($editingDesc)
            .scrollContentBackground(.hidden)
            .submitLabel(.done)
            .scrollIndicators(.hidden)
            .padding()
            .frame(height: 75)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(uiColor: .secondarySystemBackground))
            )
            .padding(.horizontal)
            .overlay {
                if viewModel.description.isEmpty && !editingDesc {
                    Text("Add description")
                        .font(.headline.bold())
                        .foregroundStyle(Color(uiColor: .secondaryLabel))
                }
            }
    }
    
    @ViewBuilder
    func priorityPicker() -> some View {
        HStack {
            Text("Priority")
            
            Spacer()
            
            Text(String(describing: $viewModel.priority.wrappedValue))
                .foregroundStyle(Color(uiColor: .secondaryLabel))
                .fontWeight(.bold)
                .fontDesign(.rounded)
            
            Menu {
                Picker("", selection: $viewModel.priority){
                    ForEach(Priority.allCases, id: \.self){priority in
                        Text(String(describing: priority))    
                    }
                }
            } label: {
                Circle()
                    .fill(viewModel.getPriorityColor())
                    .frame(width: 20, height: 20)
            }
        }
        
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(uiColor: .secondarySystemBackground))
        )
        .padding(.horizontal)
    }
    
    @ViewBuilder
    func statusPicker() -> some View {
        HStack {
            Text("Status")
            
            Spacer()
            
            Text(String(describing: $viewModel.status.wrappedValue))
                .foregroundStyle(Color(uiColor: .secondaryLabel))
                .fontWeight(.bold)
                .fontDesign(.rounded)
            
            Menu {
                Picker("", selection: $viewModel.status){
                    ForEach(Status.allCases, id: \.self){status in
                        Text(String(describing: status))    
                    }
                }
            } label: {
                Image(systemName: viewModel.getStatusImage())
                    .fontWeight(.bold)
                    .font(.headline)
            }
        }
        
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(uiColor: .secondarySystemBackground))
        )
        .padding(.horizontal)
    }
    
    @ViewBuilder
    func tagPicker() -> some View {
        HStack {
            Text("Tag")
            
            Spacer()
            
            Text(viewModel.tag != nil ? String(describing: viewModel.tag!.name) : "None")
                .foregroundStyle(Color(uiColor: .secondaryLabel))
                .fontWeight(.bold)
                .fontDesign(.rounded)
            
            Menu {
                VStack(alignment: .leading, spacing: 8) { 
                    ForEach(viewModel.tags, id: \.id) { tag in
                        Button(String(describing: tag.name)) {
                            viewModel.tag = tag
                        }
                    }
                    
                    Divider()
                    
                    Button("None") {
                        viewModel.tag = nil
                    }
                }
            } label: {
                Image(systemName: "tag.fill")
            }                    
        }
        
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(uiColor: .secondarySystemBackground))
        )
        .padding(.horizontal)
    }
    
    @ViewBuilder
    func actionButtons() -> some View {
        HStack {
            Button (role: .destructive) {
                viewModel.resetState()
            } label: {
                Label("Clear", systemImage: "trash.fill")
                    .fontWeight(.bold)
            }
            
            Divider()
            
            Button {
                if (viewModel.isSaveable()) {
                    
                }
            } label: {
                Label("Save", systemImage: "checkmark")
                    .fontWeight(.bold)
                    .foregroundStyle(.green)
            }
        }
        
        .padding()
        .background(
            Capsule()
                .fill(Color(uiColor: .secondarySystemBackground))
        )
        .padding()
    }
}

#Preview {
    TaskEntryView()
}
