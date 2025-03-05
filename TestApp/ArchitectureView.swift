//
//  ArchitectureView.swift
//  TestApp
//
//  Created by Ibrahim Gedami on 03/03/2025.
//

import SwiftUI

struct SplashView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    
    var body: some View {
        VStack {
            Text("Splash View")
                .font(.largeTitle)
            
            ProgressView()
                .padding()
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                coordinator.navigate(to: .login)
            }
        }
    }
}

struct LoginView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    
    var body: some View {
        VStack {
            Text("Login View")
                .font(.title)
            
            Button("Login") {
                coordinator.loginSuccess()
            }
        }
    }
}

struct EmployeeView: View {
    
    @EnvironmentObject var coordinator: AppCoordinator
    
    var body: some View {
        VStack {
            Text("Employee View")
                .font(.title)
                .padding()
            
            Button("Auth Employee") {
                coordinator.authEmployeeSuccess()
            }
        }
        .frame(width: 300, height: 300) // 🎯 Fixed Size
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 10)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.black.opacity(0.3), lineWidth: 1)
        )
        .onTapGesture {
            // Prevent dismiss when tapping on the popup itself
        }
    }
    
}

struct OverlayModifier: ViewModifier {
    
    @ObservedObject var coordinator: AppCoordinator
    
    func body(content: Content) -> some View {
        content
            .overlay(
                Group {
                    if let overlay = coordinator.activeOverlay {
                        Color.black.opacity(0.4)
                            .ignoresSafeArea()
                            .onTapGesture {
                                coordinator.dismissOverlay()
                            }
                        
                        switch overlay {
                        case .employee:
                            EmployeeView()
                                .environmentObject(coordinator)
                        case .authError(let message):
                            ErrorView(message: message)
                        }
                    }
                }
            )
            .animation(.easeInOut, value: coordinator.activeOverlay != nil)
    }

}

struct DashboardView: View {

    var body: some View {
        VStack {
            Text("Dashboard View")
                .font(.largeTitle)
        }
    }
}

struct ErrorView: View {
    
    var message: String
    
    var body: some View {
        VStack {
            Text("ErrorView")
                .font(.largeTitle)
        }
    }
}
