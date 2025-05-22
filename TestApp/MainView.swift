//
//  MainView.swift
//  TestApp
// 
//  Created by Ibrahim Gedami on 21/10/2024.
//

import SwiftUI
import AppBase

struct CurveSegement: View {
    
    @State var menuString = ["Profile", "Home", "Settings", "Notifi"]
    @State var selectedIndex: Int = 0
    @Namespace var animation
    
    // Instead of hardcoded xAxis, calculate dynamically based on GeometryReader
    @State private var xAxis: CGFloat = 0
    
    var body: some View {
        VStack(spacing: 0) {
            Image("IMG")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 200)
                .edgesIgnoringSafeArea(.top)
            
            GeometryReader { geo in
                let width = geo.size.width
                let tabWidth = width / CGFloat(menuString.count)
                
                ZStack(alignment: .topLeading) {
                    CustomShape(xAxis: xAxis, tabCount: menuString.count)
                        .fill(Color.blue)
                        .shadow(radius: 2)
                        .frame(height: 50)
                        .matchedGeometryEffect(id: "showRect", in: animation)
                    
                    HStack(spacing: 0) {
                        ForEach(menuString.indices, id: \.self) { number in
                            Text(menuString[number])
                                .foregroundColor(selectedIndex == number ? .black : .gray.opacity(0.5))
                                .frame(width: tabWidth, height: 50)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    withAnimation(.easeInOut) {
                                        selectedIndex = number
                                        xAxis = tabWidth * CGFloat(number)
                                    }
                                }
                        }
                    }
                }
                .offset(y: -30)
                .onAppear {
                    // initialize xAxis on appear for first tab
                    xAxis = tabWidth * CGFloat(selectedIndex)
                }
            }
//            .padding()
            .frame(height: 50) // fix GeometryReader height
            
            Spacer()
            
            // Show selected view
            Group {
                switch selectedIndex {
                case 0:
                    FirstView()
                case 1:
                    SecondView()
                case 2:
                    ThirdView()
                case 3:
                    FourthView()
                default:
                    EmptyView()
                }
            }
            
            Spacer()
        }
    }
}

struct CustomShape: Shape {
    
    var xAxis: CGFloat
    var tabCount: Int = 4  // You can pass this from outside if needed
    
    var animatableData: CGFloat {
        get { xAxis }
        set { xAxis = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        let tabWidth = rect.width / CGFloat(tabCount)
        // Center of the curve is at xAxis + half tabWidth
        let center = xAxis + tabWidth / 2
        
        // Curve width and height relative to tabWidth
        let curveWidth = tabWidth * 0.75
        let curveHeight: CGFloat = 45
        
        let leftCurveStart = center - curveWidth / 1.3
        let rightCurveEnd = center + curveWidth / 1.3
        
        return Path { path in
            // Draw outer rectangle
            path.move(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: rect.width, y: 0))
            path.addLine(to: CGPoint(x: rect.width, y: rect.height))
            path.addLine(to: CGPoint(x: 0, y: rect.height))
            path.closeSubpath()
            
            // Draw top curved bump
            path.move(to: CGPoint(x: leftCurveStart, y: 0))
            let to1 = CGPoint(x: center, y: curveHeight)
            let control1 = CGPoint(x: leftCurveStart + curveWidth * 0.3, y: 0)
            let control2 = CGPoint(x: leftCurveStart + curveWidth * 0.1, y: curveHeight)
            
            let to2 = CGPoint(x: rightCurveEnd, y: 0)
            let control3 = CGPoint(x: rightCurveEnd - curveWidth * 0.1, y: curveHeight)
            let control4 = CGPoint(x: rightCurveEnd - curveWidth * 0.3, y: 0)
            
            path.addCurve(to: to1, control1: control1, control2: control2)
            path.addCurve(to: to2, control1: control3, control2: control4)
        }
    }

}

#Preview(body: {
    CurveSegement()
})

struct FirstView: View {
    
    @State var isAnimated: Bool = false
    
    var body: some View {
        VStack {
            Image(systemName: "person.fill")
                .resizable()
                .font(.system(size: 150))
                .foregroundStyle(.orange.gradient)
            
            Text("Profile View")
                .font(.title)
                .foregroundStyle(.white.gradient)
            
            Text("Description Profile View")
                .font(.caption)
                .foregroundStyle(.white.gradient)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .opacity(isAnimated ? 1 : 0)
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                isAnimated.toggle()
            }
        }
    }

}

struct SecondView: View {
    
    @State var isAnimated: Bool = false
    
    var body: some View {
        ZStack {
            VStack {
                Image(systemName: "house.fill")
                    .resizable()
                    .frame(width: 150, height: 150)
                    .foregroundStyle(.blue.gradient)
                
                Text("Home View")
                    .font(.title)
                    .foregroundStyle(.white.gradient)
                
                Text("Description Home View")
                    .font(.caption)
                    .foregroundStyle(.white.gradient)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            .opacity(isAnimated ? 1 : 0)
            .onAppear {
                withAnimation(.easeOut(duration: 0.8)) {
                    isAnimated.toggle()
                }
            }
        }
    }
}

struct ThirdView: View {
    
    @State var isAnimated: Bool = false
    
    var body: some View {
        VStack {
            Image(systemName: "gearshape.fill")
                .resizable()
                .frame(width: 150, height: 150)
                .foregroundStyle(.green.gradient)
            
            Text("Settings View")
                .font(.title)
                .foregroundStyle(.white.gradient)
            
            Text("Description Settings View")
                .font(.caption)
                .foregroundStyle(.white.gradient)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .opacity(isAnimated ? 1 : 0)
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                isAnimated.toggle()
            }
        }
    }
}

struct FourthView: View {
    
    @State var isAnimated: Bool = false
    
    var body: some View {
            VStack {
                Image(systemName: "bell.fill")
                    .resizable()
                    .frame(width: 150, height: 150)
                    .foregroundStyle(.red.gradient)
                
                Text("Notifications View")
                    .font(.title)
                    .foregroundStyle(.white.gradient)
                
                Text("Description Notifications View")
                    .font(.caption)
                    .foregroundStyle(.white.gradient)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            .opacity(isAnimated ? 1 : 0)
            .onAppear {
                withAnimation(.easeOut(duration: 0.8)) {
                    isAnimated.toggle()
                }
            }
    }

}
