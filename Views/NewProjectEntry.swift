//
//  NewProjectEntry.swift
//  Fini - Project Manager
//
//  Created by Alexander Rivera on 2/28/25.
//

import SwiftUI

struct NewProjectEntry: View {
    var color: Color
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State var viewModel: NewProjectEntryModel = NewProjectEntryModel()
    
    @State var showColorPicker: Bool = false
    
    var body: some View {
        VStack (alignment: .leading, spacing: 0) {
            VStack (alignment: .leading) {
                HStack {
                    TextField("Title", text: $viewModel.name)
                        .font(.headline)
                        .submitLabel(.done)
                        .tint(Color(hex: viewModel.color.getColorHex()))
                        .onSubmit {
                            viewModel.saveProject(modelContext)
                            dismiss()
                        }
                    
                    Circle()
                        .foregroundStyle(Color(hex: viewModel.color.getColorHex()))
                        .frame(width: 25, height: 25)
                        .onTapGesture {
                            showColorPicker.toggle()
                        }
                    
                        .popover(isPresented: $showColorPicker, arrowEdge: .bottom) {
                            ScrollView (.vertical) {
                                FlowLayout (spacing: 5) {
                                    ForEach(Color.allList, id: \.self){ color  in
                                        Circle()
                                            .foregroundStyle(Color(hex: color.getColorHex()))
                                            .frame(width: 35, height: 35)
                                            .onTapGesture {
                                                viewModel.color = color
                                                showColorPicker.toggle()
                                            }
                                    }
                                }
                            }
                            
                            .padding()
                            .frame(width: 250, height: 150)
                            .presentationCompactAdaptation(.popover)
                        }
                }
                
            }
            
            .padding()
            .background(
                Color(uiColor: .systemBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
            )
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
    NewProjectEntry(color: .red, viewModel: .init())
}
