//
//  StickyHeaderContainer.swift
//  TestApp
//
//  Created by Ibrahim Gedami on 25/05/2025.
//

import SwiftUI

struct StickyHeaderContainer: View {
    
    var body: some View {
        ResizableHeaderScrollView {
            HStack(spacing: 12 ) {
                Button {
                    
                } label: {
                    Image(systemName:"chevron.left")
                        .font(.title3)
                }
                
                Spacer(minLength: 0)
                
                Button {
                    
                } label: {
                    Image(systemName: "magnifyingglass")
                        .font(.title3)
                }
                
                Button {
                    
                } label: {
                    Image(systemName: "bubble")
                        .font(.title3)
                }
            }
            .overlay {
                Text("Apple Store")
                    .fontWeight(.semibold)
            }
            .foregroundStyle(.primary)
            .padding(.horizontal, 15)
            .padding(.top, 15)
        } stickyHeader: {
            HStack {
                Text("Total \(25)")
                    .fontWeight(.semibold)
                
                Spacer(minLength: 0)
                
                Button {
                    
                } label: {
                    Image(systemName: "slider.vertical.3")
                        .font(.title3)
                }
            }
            .foregroundStyle(.primary)
            .padding(15)
            .padding(.vertical, 10)
        } heaerBackground: {
            Rectangle()
                .fill(.ultraThinMaterial)
                .overlay(alignment: .bottom) {
                    Divider()
                }
        } content: {
            VStack(spacing: 15) {
                ForEach(1...100, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: 15)
                        .fill(.gray.opacity(0.35))
                        .frame(height: 50)
                }
            }
            .padding(15 )
        }
    }
    
}

#Preview {
    StickyHeaderContainer()
}
