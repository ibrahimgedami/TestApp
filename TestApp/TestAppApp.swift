//
//  TestAppApp.swift
//  TestApp
//
//  Created by Ibrahim Gedami on 14/05/2024.
//

import SwiftUI
import AppBase
import CombineNetwork

class InformationViewModel: ObservableObject {
    
    let numbers = [1, 2, 3, 4]
    
    var result = 0
    
    func doTask() -> [Int] {
        let lazySquared = numbers.lazy.map { $0 * $0 }
        return Array(lazySquared) // [1, 4, 9, 16]
    }
    
}

struct InformationView: View {
    
    @State private var showingInfo = false
    @StateObject private var viewModel = InformationViewModel()
    
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
                    .alert("Information\n\n\n", isPresented: $showingInfo) {
                        Button("OK", role: .cancel) {
                            
                        }
                    } message: {
                        Text("This is an info button.")
                    }
                }
                .padding()
            }
        }
        .onAppear {
            viewModel.doTask()
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
