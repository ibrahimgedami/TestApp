//
//  StickyHeader.swift
//  TestApp
//
//  Created by Ibrahim Gedami on 25/05/2025.
//

import SwiftUI

struct ResizableHeaderScrollView<Header: View,
                                 StickyHeader: View,
                                 Background: View,
                                 Content: View>: View {
    
    var spacing: CGFloat = 10
    @ViewBuilder var header: Header
    @ViewBuilder var stickyHeader: StickyHeader
    @ViewBuilder var heaerBackground: Background
    @ViewBuilder var content: Content
    
    @State private var currentDragOffset: CGFloat = 0
    @State private var previousDragOffset: CGFloat = 0
    @State private var headerOffset: CGFloat = 0
    @State private var headerSize: CGFloat = 0
    @State private var scrollOffset: CGFloat = 0
    
    var body: some View {
        ScrollView(.vertical) {
            content
        }
        .frame(maxWidth: .infinity)
        .onScrollGeometryChange(for: CGFloat.self, of: {
            $0.contentOffset.y + $0.contentInsets.top
        }, action: { oldValue, newValue in
            scrollOffset = newValue
        })
        .simultaneousGesture(
            DragGesture(minimumDistance: 10)
                 .onChanged { value in
                    /// Adjusting min distance  value
                     ///  thus it starts from 0
                    let dragOffset = -max(0, abs(value.translation.height) - 50) * (value.translation.height < 0 ? -1 : 1)
                     previousDragOffset = currentDragOffset
                     currentDragOffset = dragOffset
                     
                     let deltaOffset = (currentDragOffset - previousDragOffset).rounded()
                     headerOffset = max(min(headerOffset + deltaOffset, headerSize), 0)
                }.onEnded { value in
                    withAnimation(.easeInOut(duration: 0.2)) {
                        if (headerOffset > (headerSize * 0.5) && scrollOffset > headerSize) {
                            headerOffset = headerSize
                        } else {
                            headerOffset = 0
                        }
                    }
                    /// Reseting offset data
                    previousDragOffset = 0
                    currentDragOffset = 0
                }
        )
        .safeAreaInset(edge: .top, spacing: spacing) {
            combinedViewHeader
        }
    }
    
    @ViewBuilder
    var combinedViewHeader: some View {
        VStack(spacing: spacing) {
            header
                .onGeometryChange(for: CGFloat.self) {
                    $0.size.height
                } action: { newValue in
                    headerSize = newValue + spacing
                }

            stickyHeader
        }
        .offset(y: -headerOffset)
        .clipped()
        .background {
            heaerBackground
                .ignoresSafeArea()
                .offset(y: -headerOffset)
        }
    }
    
}

#Preview {
    StickyHeaderContainer()
}
