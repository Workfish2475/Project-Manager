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
                
                if !addingTag {
                    addButton()
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
                
                ForEach(tagItems, id: \.id) {tag in
                    tagItem(tag)
                        .swipeActions(edge: .trailing) {
                            Button (role: .destructive) {
                                
                            } label: {
                                Image(systemName: "x.square.fill")
                            }
                        }
                }
                
                if (addingTag) {
                    tagItemEntry()
                        .matchedGeometryEffect(id: "addTag", in: animation)
                }
            }
        }
    }
    
    @ViewBuilder
    func tagItem(_ tag: Tag) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(accentColorManager.accentColor)
            HStack {
                if isEditing {
                    Image(systemName: "minus.circle.fill")
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(.white)
                        .transition(.scale)
                        .onTapGesture {
                            context.delete(tag)
                        }
                }

                Text(tag.name)
                    .font(.headline.bold())
                    .foregroundStyle(.white)
                Spacer()
            }
            .padding()
        }
        .padding(.horizontal)
    }
    
    @ViewBuilder
    func tagItemEntry() -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(accentColorManager.accentColor)
            HStack {
                Image(systemName: "x.circle.fill")
                    .symbolRenderingMode(.multicolor)
                    .foregroundStyle(.red)
                    .fontWeight(.bold)
                    .onTapGesture {
                        withAnimation(.smooth(duration: 0.3)) {
                            addingTag = false
                        }
                    }
                
                TextField("Task entry" , text: $tagName)
                    .font(.title3.bold())
                    .foregroundStyle(.white)
                    .tint(.white)
                    .submitLabel(.done)
                    .onSubmit {
                        saveTag()
                    }
                
                Spacer()
                
                if !(tagName.isEmpty) {
                    Button {
                        tagName.removeAll()
                    } label: {
                        Image(systemName: "x.circle.fill")
                            .symbolRenderingMode(.hierarchical)
                            .padding(.trailing)
                            .foregroundStyle(.white.opacity(0.5))
                    }
                    
                    .transition(.opacity)
                }
            }
            
            .padding()
        }
        
        .padding(.horizontal)
        .frame(height: 50)
    }
    
    @ViewBuilder
    func addButton() -> some View {
        Button {
            withAnimation(.bouncy(duration: 0.4)) {
                addingTag = true
            }           
            
            tagField = true
        } label: {
            Label("Add tag", systemImage: "tag.fill")
                .fontWeight(.medium)
        }
        
        .matchedGeometryEffect(id: "addTag", in: animation)
        .tint(accentColorManager.accentColor)
        .buttonStyle(BorderedProminentButtonStyle())
        .padding()
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
        let newTag2 = Tag(name: "Testing")
        let newTag3 = Tag(name: "Testing")
        let newTag4 = Tag(name: "Testing")
        
        container.mainContext.insert(newTag1)
        container.mainContext.insert(newTag2)
        container.mainContext.insert(newTag3)
        container.mainContext.insert(newTag4)
        
        return TagPickerView()
            .modelContainer(container)
            .environmentObject(AccentColorManager())
    }
}
