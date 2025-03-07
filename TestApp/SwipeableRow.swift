//
//  SwipeableRow.swift
//  TestApp
//
//  Created by Ibrahim Gedami on 07/03/2025.
//

import AppBase
import SwiftUI

struct SwipeableRow: View {
    let title: String
    let onDelete: () -> Void
    let onEdit: () -> Void
    
    @Binding var activeRowId: UUID?
    let rowId: UUID
    
    @State private var offset: CGFloat = 0
    @State private var showActions = false
    private let actionWidth: CGFloat = 130
    
    var body: some View {
        ZStack(alignment: .trailing) {
            
            if showActions {
                // ✅ Action Buttons (Only Rendered When Swiping Starts)
                HStack(spacing: 8) {
                    Button {
                        onEdit()
                        resetSwipe()
                    } label: {
                        Image(systemName: "pencil")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .cornerRadius(8, corners: .allCorners)
                    
                    Button {
                        onDelete()
                        resetSwipe()
                    } label: {
                        Image(systemName: "trash")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .cornerRadius(8, corners: .allCorners)
                }
//                .offset(x: offset > -20 ? actionWidth : max(actionWidth + offset, 0))
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: offset)
            }
            
            // 🔥 Row Content
            HStack {
                Text(title)
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 3)
                    .offset(x: offset)
                    .gesture(
                        DragGesture()
                            .onChanged { gesture in
                                if gesture.translation.width < 0 {
                                    offset = gesture.translation.width
                                    activeRowId = rowId
                                    showActions = true
                                }
                            }
                            .onEnded { _ in
                                if offset < -100 {
                                    offset = -actionWidth
                                } else {
                                    resetSwipe()
                                }
                            }
                    )
                    .onTapGesture {
                        resetSwipe()
                    }
                    .animation(.spring(), value: offset)
            }
        }
        .frame(height: 60)
        .onChange(of: activeRowId) { _, newId in
            if newId != rowId {
                resetSwipe()
            }
        }
    }
    
    private func resetSwipe() {
        withAnimation {
            offset = 0
            showActions = false
        }
    }
}

struct SwipeableRowContainer: View {
    @State private var activeRowId: UUID?
    let items = ["Apple", "Banana", "Orange", "Mango", "Grapes"]
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 10) {
                ForEach(items, id: \.self) { item in
                    SwipeableRow(
                        title: item,
                        onDelete: { print("Deleted \(item)") },
                        onEdit: { print("Edited \(item)") },
                        activeRowId: $activeRowId,
                        rowId: UUID()
                    )
                    .padding(.horizontal, 20)
                }
            }
        }
        .background(Color(UIColor.systemGroupedBackground))
    }
}

struct ContentView: View {
    var body: some View {
        SwipeableRowContainer()
    }
}

#Preview {
    ContentView()
}
