//
//  TestAppApp.swift
//  TestApp
//
//  Created by Ibrahim Gedami on 14/05/2024.
//

import SwiftUI
import AppBase
import CombineNetwork


struct InformationView: View {
    
    @State private var showingInfo = false
    
    var body: some View {
        VStack {
            HStack {
                HStack {
                    Rectangle()
                        .frame(height: 50)
                        .cornerRadius(12, corners: .allCorners)
                        .onTapGesture {
                            debugPrint("Information pressed")
                        }
                    
                    Button(action: {
                        showingInfo.toggle()
                    }) {
                        Image("icon_info")
                            .font(.largeTitle)
                            .foregroundStyle(.blue)
                    }
                    .alert("Information", isPresented: $showingInfo) {
                        Button("OK", role: .cancel) { }
                    } message: {
                        Text("This is an info button.")
                    }
                }
                .padding()
            }
        }
    }
}

#Preview {
    InformationView()
}

@main
struct TestAppApp: App {
    
    var body: some Scene {
        WindowGroup {
        }
    }
    
}
