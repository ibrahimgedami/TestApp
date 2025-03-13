//
//  CartButton.swift
//  TestApp
//
//  Created by Ibrahim Gedami on 12/03/2025.
//

import SwiftUI

struct CartButton: View {
    
    @Binding var cartItemCount: Int
    
    @State private var scaleEffect: CGFloat = 1.0
    @State private var imageScale: CGFloat = 1.0
    @State private var rotationAngle: Double = 0
    @State private var opacity: Double = 1.0
    @State private var badgeScale: CGFloat = 1.0
    
    var action: (() async -> Void)
    
    var body: some View {
        Button(action: {
            Task {
                await action()
            }
        }) {
            ZStack(alignment: .topTrailing) {
                Image(systemName: "cart.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .foregroundColor(.blue)
                    .scaleEffect(imageScale)
                    .rotationEffect(.degrees(rotationAngle))
                    .opacity(opacity)
                
                if cartItemCount > 0 {
                    Text("\(cartItemCount)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(width: 25, height: 25)
                        .background(Circle().fill(Color.red))
                        .offset(x: 20, y: -20)
                        .scaleEffect(badgeScale)
                }
            }
            .padding()
            .background(Circle().fill(Color.white))
            .shadow(radius: 5)
        }
        .padding()
        .onChange(of: cartItemCount) { _, newValue in
            withAnimation(.easeInOut(duration: 0.2)) {
                imageScale = 1.2
            }
            
            withAnimation(.easeInOut(duration: 0.2)) {
                rotationAngle += 45
            }
            
            withAnimation(.easeInOut(duration: 0.2)) {
                opacity = 0.5
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(.easeInOut(duration: 0.2)) {
                    imageScale = 1.0
                    rotationAngle = 0
                    opacity = 1.0
                }
            }
            
            withAnimation(.easeInOut(duration: 0.3).repeatForever(autoreverses: true)) {
                badgeScale = 1.5
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation {
                    badgeScale = 1.0
                }
            }
        }
    }

}

struct CartButtonView: View {
    
    @State var cartItemCount: Int = 0
    
    var body: some View {
        VStack {
            CartButton(cartItemCount: $cartItemCount) {
                print("Goooooo")
            }
            
            Button(action: {
                cartItemCount += 1
            }) {
                Text("Press")
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.gray.opacity(0.1)) // Background for testing
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        CartButtonView()
    }
}
