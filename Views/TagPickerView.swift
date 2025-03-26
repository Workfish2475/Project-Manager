import SwiftUI
import SwiftData

struct TagPickerView: View {
    
    @State private var viewModel: TagPickerModel = TagPickerModel()
    
    @Environment(\.modelContext) private var context
    @EnvironmentObject var accentColorManager: AccentColorManager
    @Namespace private var animation
    
    @Query private var tagItems: [Tag]
    
    @FocusState private var tagField
    
    var body: some View {
        ZStack (alignment: .bottom) {
            NavigationStack {
                tagList()
                    .navigationTitle("Tags")
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button {
                                withAnimation (.bouncy(duration: 0.3, extraBounce: 0.1)) {
                                    viewModel.isEditing.toggle()
                                }
                            } label: {
                                Text(viewModel.isEditing ? "Done" : "Edit")
                                    .fontWeight(.medium)
                            }
                            
                            .disabled(tagItems.isEmpty)
                            .disabled(viewModel.addingTag)
                        }
                    }
            }
            
            if viewModel.isEditing {
                deletionTab()
                    .transition(
                        .asymmetric(
                            insertion: .move(edge: .bottom),
                            removal: .move(edge: .bottom).combined(with: .opacity)
                        )
                    )
                    .animation(.easeInOut(duration: 0.3), value: viewModel.isEditing)
            }
        }
        
        .tint(accentColorManager.accentColor)
        .onChange(of: viewModel.isEditing) {
            viewModel.addingTag = false
            viewModel.selectedTags.removeAll()
        }
    }
    
    @ViewBuilder
    func tagList() -> some View {
        ScrollView (.vertical) {
            if (tagItems.isEmpty) {
                Text("You don't have any tags created yet. Add some now.")
                    .font(.subheadline)
                    .foregroundStyle(Color(uiColor: .secondaryLabel))
                    .padding()
            }
            
            Divider()
                .padding(.bottom, 10)
                .hidden()
            
            FlowLayout(spacing: 5, alignment: .center) {
                ForEach(tagItems, id: \.id) { tag in
                    tagItem(tag)
                        .scaleEffect(viewModel.selectedTags.contains(tag) && viewModel.isEditing ? 0.9 : 1)
                        .animation(.snappy(duration: 0.3), value: viewModel.selectedTags.contains(tag))
                        .disabled(viewModel.isEditing)
                        .onTapGesture {
                            if (!viewModel.isEditing) {
                                return
                            }
                            
                            viewModel.toggleTag(tag)
                        }
                }
                
                if (viewModel.addingTag) {
                    tagItemEntry()
                        .matchedGeometryEffect(id: "addTag", in: animation)
                }
                
                tagItemPlaceholder()
            }
            
            .padding()
        }
    }
    
    @ViewBuilder
    func tagItem(_ tag: Tag) -> some View {
        Text(tag.name)
            .font(.headline)
            .foregroundStyle(.white)
            .padding(.horizontal)
            .padding(.vertical, 10)
            .fontDesign(.rounded)
            .background(
                Capsule()
                    .fill(accentColorManager.accentColor)
            )
    }
    
    @ViewBuilder
    func tagItemPlaceholder() -> some View {
        Label("New", systemImage: "plus")
            .font(.headline)
            .foregroundStyle(accentColorManager.accentColor)
            .padding(.horizontal)
            .padding(.vertical, 10)
            .fontDesign(.rounded)
            .background(
                Capsule()
                    .fill(accentColorManager.accentColor.opacity(0.4))
                    .stroke(accentColorManager.accentColor, lineWidth: 2)
            )
        
            .onTapGesture {
                withAnimation (.spring) {
                    viewModel.addingTag.toggle()
                }
                
                tagField.toggle()
            }
    }
    
    //TODO: Need to take into account the max amount of chars for tag.
    @ViewBuilder
    func tagItemEntry() -> some View {
        TextField("Tag", text: $viewModel.tagName)
            .font(.headline)
            .foregroundStyle(.white)
            .padding(.horizontal)
            .padding(.vertical, 10)
            .tint(.white)
            .fontDesign(.rounded)
            .focused($tagField)
            .submitLabel(.done)
            .onSubmit {
                viewModel.saveTag(context)
            }
            .background(
                Capsule()
                    .fill(accentColorManager.accentColor)
            )
    }
    
    @ViewBuilder
    func deletionTab() -> some View {
        HStack (spacing: 10) {
            Button {
                withAnimation (.bouncy(duration: 0.3, extraBounce: 0.1)) {
                    viewModel.isEditing.toggle()
                }
            } label: {
                Label("Cancel", systemImage: "xmark")
                    .font(.headline)
            }
            
            Divider()
                .frame(height: 10)
            
            Text("\(viewModel.selectedTags.count) selected")
                .contentTransition(.numericText())
                .animation(.default, value: viewModel.selectedTags.count)
                .font(.headline)
            
            Divider()
                .frame(height: 10)
            
            Button (role: .destructive) {
                viewModel.deleteFromSelected(context)
                withAnimation (.bouncy(duration: 0.3, extraBounce: 0.1)) {
                    viewModel.isEditing.toggle()
                }
            } label: {
                Label("Delete", systemImage: "trash.fill")
                    .font(.headline)
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

struct TagPickerView_Previews: PreviewProvider {
    static var previews: some View {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: Tag.self, configurations: config)
        
        let newTag1 = Tag(name: "Testing")
        let newTag2 = Tag(name: "Backend")
        let newTag3 = Tag(name: "UX")
        let newTag4 = Tag(name: "User studies")
        let newTag5 = Tag(name: "Pricing")
        
        container.mainContext.insert(newTag1)
        container.mainContext.insert(newTag2)
        container.mainContext.insert(newTag3)
        container.mainContext.insert(newTag4)
        container.mainContext.insert(newTag5)
        
        return TagPickerView()
            .modelContainer(container)
            .environmentObject(AccentColorManager())
    }
}
