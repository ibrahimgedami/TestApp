//
//  SwipeableAction.swift
//  TestApp
//
//  Created by Ibrahim Gedami on 21/02/2025.
//

import SwiftUI

struct SwipeActionScrollView: View {
    
    @State private var items = ["Item 1", "Item 2", "Item 3", "Item 4"]
    @State private var swipedItem: String? = nil  // Track which item is swiped
    
    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                ForEach(items, id: \.self) { item in
                    SwipeableRow(
                        item: item,
                        swipedItem: $swipedItem,
                        onDelete: {
                            withAnimation {
                                items.removeAll { $0 == item }
                            }
                        }
                    )
                }
            }
            .padding()
        }
        .onTapGesture {
            withAnimation {
                swipedItem = nil  // Close any open swipe when tapping outside
            }
        }
    }
}

struct SwipeableRow: View {
    
    let item: String
    @Binding var swipedItem: String? // Track which row is swiped
    var onDelete: () -> Void
    
    @State private var offset: CGFloat = 0
    private let swipeThreshold: CGFloat = -80
    
    var body: some View {
        ZStack {
            // Background delete button
            HStack {
                Spacer()
                Button {
                    withAnimation(.bouncy) {
                        onDelete()
                    }
                } label: {
                    Image(systemName: "trash")
                        .font(.system(size: 20))
                }
                .frame(maxHeight: .infinity)
                .frame(height: 80)
                .padding(.horizontal)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            .linearGradient(
                                colors: [.pink.opacity(0.8), .red.opacity(0.8)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                )
                .foregroundStyle(.white)
//                Button(action: {
//                    withAnimation {
//                        onDelete()
//                    }
//                }) {
//                    Text("Delete")
//                        .font(.headline)
//                        .foregroundColor(.white)
//                        .padding()
//                        .background(Color.red)
//                        .cornerRadius(10)
//                }
//                .frame(width: 80)
            }
            .frame(maxWidth: .infinity, maxHeight: 50)
//            .background(Color.gray.opacity(0.2))
            .cornerRadius(10)
            
            // Foreground row
            Text(item)
                .frame(maxWidth: .infinity, maxHeight: 50)
                .background(Color.white)
                .cornerRadius(10)
                .shadow(radius: 3)
                .offset(x: offset)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            if value.translation.width < 0 { // Swipe left only
                                offset = max(value.translation.width, swipeThreshold * 1.5)
                                swipedItem = item // Mark this row as swiped
                            }
                        }
                        .onEnded { value in
                            withAnimation(.spring()) {
                                if value.translation.width < swipeThreshold {
                                    offset = swipeThreshold
                                    swipedItem = item // Keep it open
                                } else {
                                    offset = 0
                                    swipedItem = nil // Close swipe
                                }
                            }
                        }
                )
                .onChange(of: swipedItem) { _, newValue in
                    if newValue != item {
                        withAnimation {
                            offset = 0 // Close if another row is swiped
                        }
                    }
                }
        }
        .padding(.horizontal)
    }
}
