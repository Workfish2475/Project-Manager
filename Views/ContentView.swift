import SwiftUI

//TODO: This should make use of some sort of Design Pattern (MVVM or MVC)

struct ContentView: View {
    @State private var selectedItem: Int = 0
    
    @State private var showingSettings: Bool = false
    @State private var showingEntry: Bool = false
    @FocusState private var showingEntryField
    
    @State private var projectEntry: String = ""
    @State private var projectColor: Color = Color.allList[0]
    
    @State private var confirmCancel: Bool = false
    
    @Namespace private var animation
    
    @Environment(\.modelContext) private var context
    @EnvironmentObject var accentColorManager: AccentColorManager
    @AppStorage("appearance") var appearance: Appearance = .system
    
    var body: some View {
        NavigationStack {
            TabView (selection: $selectedItem) {
                ZStack (alignment: .bottomTrailing) {
                    ProjectView()
                    
                    if showingEntry {
                        Color.black.opacity(0.4)
                            .edgesIgnoringSafeArea(.all)
                            .transition(.opacity)
                            .onTapGesture {
                                if !projectEntry.isEmpty {
                                    confirmCancel.toggle()
                                } else {
                                    showingEntry = false
                                }
                            }
                    }
                    
                    
                    if showingEntry {
                        projEntryView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                            .transition(.asymmetric(
                                insertion: .scale(scale: 0.8).combined(with: .opacity),
                                removal: .scale(scale: 0.6).combined(with: .opacity)
                            ))
                            .padding(.bottom)
                    } else {
                        addButton()
                            .transition(.scale)
                    }
                }
                
                .tabItem {
                    Label("Projects", systemImage: "hammer.fill")
                }
                .tag(0)
                
                ZStack (alignment: .bottomTrailing) {
                    ProjProgressView()
                }
                
                .tabItem {
                    Label("Progress", systemImage: "chart.bar")
                }
                .tag(1)
            }
            
            .tint(accentColorManager.accentColor)
            .navigationTitle(selectedItem == 0 ? "Projects" : "Progress")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingSettings.toggle()
                    } label: {
                        Image(systemName: "gear")
                            .imageScale(.large)
                            .foregroundStyle(accentColorManager.accentColor)
                    }
                }
            }
            
            .sheet(isPresented: $showingSettings) {
                Settings()
            }
            
            .preferredColorScheme(appearance.colorScheme)
        }
    }
    
    @ViewBuilder
    func addButton() -> some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8, blendDuration: 0)) {
                showingEntry = true
                showingEntryField = true
            }
        } label: {
            Image(systemName: "plus.circle.fill")
                .resizable()
                .frame(width: 50, height: 50)
                .foregroundColor(accentColorManager.accentColor)
                .padding()
        }
        
        .matchedGeometryEffect(id: "addProj", in: animation)
        .scaleEffect(1.0)
        .shadow(radius: 2)
    }
    
    @ViewBuilder
    func projEntryView() -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(.thickMaterial)
                .shadow(color: .black.opacity(0.2), radius: 5)
                .frame(height: 200)
            
            VStack (spacing: 30) {
                HStack {
                    TextField("New Project", text: $projectEntry)
                        .font(.title.bold())
                        .tint(accentColorManager.accentColor)
                        .focused($showingEntryField)
                        .submitLabel(.done)
                        .onSubmit {
                            if projectEntry.isEmpty {
                                return
                            }
                            
                            Project.saveProject(projectItemName: projectEntry, projectItemColor: projectColor, context: context)
                            
                            showingEntry = false
                            projectColor = .allList[0]
                            projectEntry.removeAll()
                        }
                    
                        .phaseAnimator([false, true], trigger: confirmCancel) { content, phase in
                            content
                                .opacity(phase ? 0.7 : 1.0)
                                .foregroundStyle(phase ? .red : .primary)
                        } animation: { phase in
                                .snappy(duration: 0.3)
                        }
                    
                    if !(projectEntry.isEmpty) {
                        Image(systemName: "x.circle.fill")
                            .foregroundStyle(Color(uiColor: .systemGray))
                            .onTapGesture {
                                projectEntry.removeAll()
                            }
                    }
                }

                ScrollView(.horizontal) {
                    HStack {
                        ForEach(Color.allList, id: \.self){color in
                            Circle()
                                .foregroundStyle(color)
                                .frame(width: 25, height: 25)
                                .submitLabel(.done)
                                .onTapGesture {
                                    projectColor = color
                                }
                            
                                .overlay {
                                    if color == projectColor {
                                        Circle()
                                            .stroke(color, lineWidth: 2)
                                            .frame(width: 30, height: 30)
                                    }
                                }
                        }
                    }
                    
                    .padding()
                }
                
                .scrollIndicators(.hidden)
                .background {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(uiColor: .systemBackground))
                }
                
            } //VStack 
            
            .padding(.horizontal)
        } //ZStack
        
        .padding(.horizontal)
        .matchedGeometryEffect(id: "addProj", in: animation)
    }
}
