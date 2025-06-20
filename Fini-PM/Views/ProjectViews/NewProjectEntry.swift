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
        VStack {
            entrySection
            
            Divider()
                .padding(.horizontal)
                .padding(.vertical, 5)
            
            deviceView
        }
        
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(.background)
        )
    }
    
    private var entrySection: some View {
        HStack {
            TextField("New Project", text: $viewModel.name)
                .font(.headline)
                .submitLabel(.done)
                .tint(Color(hex: viewModel.color.getColorHex()))
                .onSubmit {
                    viewModel.saveProject(modelContext)
                    dismiss()
                }
            
            if !viewModel.name.isEmpty {
                Image(systemName: "xmark.circle.fill")
                    .resizable()
                    .frame(width: 10, height: 10)
                    .symbolRenderingMode(.hierarchical)
                    .onTapGesture {
                        viewModel.name.removeAll()
                    }
            }
            
            Circle()
                .foregroundStyle(Color(hex: viewModel.color.getColorHex()))
                .frame(width: 25, height: 25)
                .onTapGesture {
                    showColorPicker.toggle()
                }
            
                .popover(isPresented: $showColorPicker) {
                    ScrollView (.horizontal) {
                        FlowLayout (spacing: 5) {
                            ForEach(Color.allList, id: \.self){ color  in
                                Circle()
                                    .foregroundStyle(Color(hex: color.getColorHex()))
                                    .frame(minWidth: 30, minHeight: 30)
                                    .onTapGesture {
                                        viewModel.color = color
                                        showColorPicker.toggle()
                                    }
                            }
                        }
                    }
                    
                    .padding(.horizontal)
                    .scrollIndicators(.hidden)
                    .presentationCompactAdaptation(.popover)
                }
        }
        
        .padding([.horizontal, .top])
    }
    
    private var deviceView: some View {
        VStack (alignment: .leading, spacing: 10) {
            Text("Supported Devices")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            ScrollView (.horizontal) {
                HStack {
                    deviceItem("Mobile", "iphone")
                        .frame(width: 60, height: 60)
                        .foregroundStyle(viewModel.isMobile ? .blue : .primary)
                        .onTapGesture {
                            toggleDevice(&viewModel.isMobile)
                        }
                    
                    deviceItem("Tablet", "ipad")
                        .frame(width: 60, height: 60)
                        .foregroundStyle(viewModel.isPad ? .blue : .primary)
                        .onTapGesture {
                            toggleDevice(&viewModel.isPad)
                        }
                    
                    deviceItem("Desktop", "desktopcomputer")
                        .frame(width: 60, height: 60)
                        .foregroundStyle(viewModel.isDesktop ? .blue : .primary)
                        .onTapGesture {
                            toggleDevice(&viewModel.isDesktop)
                        }
                    
                    deviceItem("Watch", "applewatch")
                        .frame(width: 60, height: 60)
                        .foregroundStyle(viewModel.isWatch ? .blue : .primary)
                        .onTapGesture {
                            toggleDevice(&viewModel.isWatch)
                        }
                    
                    deviceItem("Tv", "tv")
                        .frame(width: 60, height: 60)
                        .foregroundStyle(viewModel.isTv ? .blue : .primary)
                        .onTapGesture {
                            toggleDevice(&viewModel.isTv)
                        }
                    
                    deviceItem("Web", "safari.fill")
                        .frame(width: 60, height: 60)
                        .foregroundStyle(viewModel.isWeb ? .blue : .primary)
                        .onTapGesture {
                            toggleDevice(&viewModel.isWeb)
                        }
                }
            }
        }
        
        .padding([.horizontal, .bottom])
    }
    
    private func deviceItem(_ title: String,_ image: String) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(.thinMaterial)
            
            VStack (spacing: 10) {
                Image(systemName: image)
                    .foregroundStyle(.secondary)
                
                Text(title)
                    .font(.caption)
            }
        }
    }
    
    private func toggleDevice(_ bool: inout Bool) {
        withAnimation(.easeIn(duration: 1)) {
            bool.toggle()
        }
    }
}

#Preview {
    NewProjectEntry(color: .red, viewModel: .init())
}
