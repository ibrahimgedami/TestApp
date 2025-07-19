//
//  SwipeableRow.swift
//  TestApp
//
//  Created by Ibrahim Gedami on 19/07/2025.
//

import SwiftUI

struct SwipeableRow: View {
    
    
    let title: String
    let onDelete: () -> Void
    
    @State private var offsetX: CGFloat = 0
    @GestureState private var dragOffset: CGFloat = 0
    
    private let swipeLimit: CGFloat = -80
    private let swipeThreshold: CGFloat = -50
    
    var body: some View {
        ZStack(alignment: .trailing) {
            // Background - Delete Button
            HStack {
                Spacer()
                Button(action: {
                    withAnimation(.spring()) {
                        offsetX = 0
                        onDelete()
                    }
                }) {
                    Image(systemName: "trash.fill")
                        .foregroundColor(.white)
                        .frame(width: 60, height: 50)
                        .background(Color.red)
                        .cornerRadius(10)
                }
                .padding(.trailing)
            }
            
            // Foreground - Main Content
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(UIColor.systemGray6))
                .overlay(
                    HStack {
                        Text(title)
                            .foregroundColor(.primary)
                            .padding(.leading)
                        Spacer()
                    }
                )
                .frame(height: 50)
                .offset(x: offsetX + dragOffset)
                .gesture(
                    DragGesture()
                        .updating($dragOffset) { value, state, _ in
                            let proposed = value.translation.width
                            state = proposed < 0 ? max(proposed, swipeLimit) : 0
                        }
                        .onEnded { value in
                            let totalDrag = value.translation.width
                            withAnimation(.interactiveSpring()) {
                                if totalDrag < swipeThreshold {
                                    offsetX = swipeLimit
                                } else {
                                    offsetX = 0
                                }
                            }
                        }
                )
                .animation(.easeOut(duration: 0.2), value: offsetX)
        }
        .padding(.horizontal)
    }
    
}
