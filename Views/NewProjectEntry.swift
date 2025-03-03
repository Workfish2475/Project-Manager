//
//  NewProjectEntry.swift
//  Fini - Project Manager
//
//  Created by Alexander Rivera on 2/28/25.
//

import SwiftUI

struct NewProjectEntry: View {
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @StateObject var viewModel:NewProjectEntryModel = NewProjectEntryModel()
    
    var body: some View {
        VStack (spacing: 0) {
            TextField("New project", text: $viewModel.name)
                .padding()
                .font(.system(size: 30, weight: .bold, design: .none))
                .submitLabel(.done)
                .onSubmit {
                    viewModel.saveProject(modelContext)
                    dismiss()
                }
            
            ScrollView (.horizontal) {
                HStack {
                    ForEach(Color.allList, id: \.self){color in
                        Circle()
                            .fill(color)
                            .frame(width: 25, height: 25)
                            .onTapGesture {
                                withAnimation {
                                    viewModel.changeColor(color)
                                }
                            }
                        
                            .overlay {
                                if (color == viewModel.color) {
                                    Image(systemName: "circle.fill")
                                        .foregroundStyle(.white.opacity(0.8))
                                        .frame(width: 15, height: 15)
                                }
                            }
                    }
                }
            }
            
            .scrollIndicators(.hidden)
            .padding()
        }
        
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(uiColor: .secondarySystemBackground))
        )
        
        .padding()
    }
}


#Preview {
    NewProjectEntry(viewModel: .init())
}
