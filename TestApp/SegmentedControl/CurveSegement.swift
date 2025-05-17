//
//  CurveSegement.swift
//  TestApp
//
//  Created by Ibrahim Gedami on 17/05/2025.
//

import SwiftUI

struct SegmentSlopeHighlight: Shape {
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let waveHeight: CGFloat = 8
        let waveLength = rect.width * 0.2
        let slopeEndX = rect.width
        let slopeEndY = rect.height
        
        path.move(to: .zero)
        
        // Gentle wave to the right
        path.addCurve(
            to: CGPoint(x: waveLength, y: waveHeight),
            control1: CGPoint(x: waveLength * 0.3, y: 0),
            control2: CGPoint(x: waveLength * 0.7, y: waveHeight)
        )
        
        // Downward slope from wave to bottom-right
        path.addLine(to: CGPoint(x: slopeEndX, y: slopeEndY))
        
        // Complete the shape
        path.addLine(to: CGPoint(x: slopeEndX, y: rect.height))
        path.addLine(to: CGPoint(x: 0, y: rect.height))
        path.closeSubpath()
        
        return path
    }
 
}

struct CustomSegmentedControl: View {
    let tabs = ["Call", "Mail", "Chat"]
    @State private var selectedIndex = 0
    
    var body: some View {
        GeometryReader { geometry in
            let segmentWidth = geometry.size.width / CGFloat(tabs.count)
            
            ZStack(alignment: .leading) {
                // Overlay under selected tab
                SegmentSlopeHighlight()
                    .fill(Color.blue.opacity(0.2))
                    .frame(width: segmentWidth, height: geometry.size.height)
                    .offset(x: CGFloat(selectedIndex) * segmentWidth)
                    .animation(.easeInOut(duration: 0.3), value: selectedIndex)
                
                HStack(spacing: 0) {
                    ForEach(tabs.indices, id: \.self) { index in
                        Button(action: {
                            selectedIndex = index
                        }) {
                            Text(tabs[index])
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .foregroundColor(selectedIndex == index ? .blue : .gray)
                        }
                    }
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.3))
            )
        }
        .frame(height: 50)
        .padding()
    }
}

#Preview(body: {
    CustomSegmentedControl()
})
