//
//  MainView.swift
//  TestApp
//
//  Created by Ibrahim Gedami on 21/10/2024.
//

import SwiftUI
import AppBase

struct ContentView: View {
    
    @State var menuString = ["Profile", "Home", "Settings", "Notifications"]
    @State var xAxis: CGFloat = 0
    @State var selectedIndex: Int = 0
    @Namespace var animation

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                Image("IMG")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 200)
                    .edgesIgnoringSafeArea(.top)
                
                ZStack(alignment: .top) {
                    CustomShape(xAxis: xAxis)
                        .edgesIgnoringSafeArea(.bottom)
                        .frame(height: 50)
                        .foregroundStyle(Color.green)
                        .matchedGeometryEffect(id: "showRect", in: animation)
                    
                    HStack {
                        ForEach(menuString.indices, id: \.self) { number in
                            Text(menuString[number])
                                .foregroundStyle(selectedIndex == number ? .red : .gray.opacity(0.5))
                                .frame(width: (UIScreen.main.bounds.width - 20) / CGFloat(menuString.count))
                                .offset(y: 5)
                                .onTapGesture {
                                    selectedIndex = number
                                    withAnimation {
                                        xAxis = 10 + CGFloat((100 * number) - (number != 0 ? 5 / number : 0))
                                    }
                                }
                        }
                    }
                }
                .offset(y: -10)
                Spacer()
                
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
                
                Spacer()
            }
        }
    }
}

struct FirstView: View {
    
    @State var isAnimated: Bool = false
    
    var body: some View {
        ZStack {
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
        ZStack {
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
}

struct FourthView: View {
    
    @State var isAnimated: Bool = false
    
    var body: some View {
        ZStack {
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
}

struct CustomShape: Shape {

    var xAxis: CGFloat
    var animatableData: CGFloat {
        get { xAxis }
        set { xAxis = newValue }
    }
    func path(in rect: CGRect) -> Path {
        let customPath = Path { path in
            path.move(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: rect.width, y: 0))
            path.addLine(to: CGPoint(x: rect.width, y: rect.height))
            path.addLine(to: CGPoint(x: 0, y: rect.height))
            let center = xAxis + 40
            path.move(to: CGPoint(x: center - 70, y: 0))
            let to1 = CGPoint(x: center, y: 35)
            let control1 = CGPoint(x: center - 30, y: 0)
            let control2 = CGPoint(x: center - 50, y: 35)
            
            let to2 = CGPoint(x: center + 70, y: 0)
            let control3 = CGPoint(x: center + 50, y: 35)
            let control4 = CGPoint(x: center + 30, y: 35)
            
            path.addCurve(to: to1, control1: control1, control2: control2)
            path.addCurve(to: to2, control1: control3, control2: control4)
        }
        return customPath
    }
    
}
