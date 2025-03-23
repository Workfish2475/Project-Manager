import SwiftUI
import SwiftData

struct TagPickerView: View {
    
    //Implement a binding item here
    //Implement viewModel here
    @StateObject private var viewModel: TagPickerModel = TagPickerModel()
    @FocusState private var focusTagField: Bool
    
    @State private var addingTag: Bool = false
    @State private var isEditing: Bool = false
    
    @Environment(\.modelContext) private var context
    @EnvironmentObject var accentColorManager: AccentColorManager
    @Namespace private var animation
    
    @Query private var tagItems: [Tag]
    
    @FocusState private var tagField
    
    @State private var tagName: String = ""
    @State private var tagColor: Color = Color.allList[0]
    
    var body: some View {
        ZStack {
            NavigationStack {
                tagList()
                    .navigationTitle("Tags")
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button {
                                withAnimation {
                                    isEditing.toggle()
                                }
                            } label: {
                                Text(isEditing ? "Done" : "Edit")
                                    .fontWeight(.medium)
                            }
                            
                            .disabled(tagItems.isEmpty)
                        }
                    }
            }
        }   
        
        .tint(accentColorManager.accentColor)
        .onChange(of: isEditing) {
            addingTag = false
        }
    }
    
    @ViewBuilder
    func tagList() -> some View {
        if tagItems.isEmpty {
            VStack (spacing: 10) {
                Spacer()
                if !addingTag {
                    Image(systemName: "tag.circle.fill")
                        .resizable()
                        .symbolRenderingMode(.hierarchical)
                        .frame(width: 75, height: 75)
                        .foregroundStyle(accentColorManager.accentColor)
                    
                    Text("No tags added")
                        .font(.title3.bold())
                        .foregroundStyle(Color(uiColor: .secondaryLabel))
                    
                } else {
                    tagItemEntry()
                        .matchedGeometryEffect(id: "addTag", in: animation)
                        .frame(height: 50)
                }
                
                Spacer()
            }
        } else {     
            ScrollView (.vertical) {
                Divider()
                    .padding(.bottom, 10)
                    .hidden()
                
                FlowLayout(spacing: 5, alignment: .center) {
                    ForEach(tagItems, id: \.id) { tag in
                        tagItem(tag)
                    }
                    
                    if (addingTag) {
                        tagItemEntry()
                            .matchedGeometryEffect(id: "addTag", in: animation)
                    }
                    
                    //Placeholder goes here
                    tagItemPlaceholder()
                }
                
                .padding()
            }
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
                    addingTag.toggle()
                }
                
                tagField.toggle()
            }
    }
    
    //Need to take into account the max amount of chars for tag.
    @ViewBuilder
    func tagItemEntry() -> some View {
        TextField("Tag", text: $tagName)
            .font(.headline)
            .foregroundStyle(.white)
            .padding(.horizontal)
            .padding(.vertical, 10)
            .fontDesign(.rounded)
            .focused($tagField)
            .background(
                Capsule()
                    .fill(accentColorManager.accentColor)
            )
    }
    
    func saveTag() {
        if tagName.isEmpty {
            return
        }
        
        let newTag = Tag(name: tagName)
        context.insert(newTag)
        
        tagName.removeAll()
        addingTag = false
        
        do {
            try context.save()
        } catch {
            print("Error, something went wrong during saving: \(error)")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
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
