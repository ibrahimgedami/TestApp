//
//  TestAppApp.swift
//  TestApp
//
//  Created by Ibrahim Gedami on 14/05/2024.
//

import SwiftUI
import AppBase
import CombineNetwork

//@main
//struct TestAppApp: App {
//    
//    var body: some Scene {
//        WindowGroup {
//        }
//    }
//    
//}

@main
struct MyApp: App {
    
    @StateObject var coordinator = AppCoordinator.shared
    
    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $coordinator.path) {
                SplashView()
                    .environmentObject(coordinator)
                    .navigationDestination(for: AppCoordinator.AppRoute.self) { route in
                        switch route {
                        case .splash:
                            SplashView()
                                .environmentObject(coordinator)
                        case .login:
                            LoginView()
                                .environmentObject(coordinator)
                        case .dashboard:
                            DashboardView()
                                .environmentObject(coordinator)
                        }
                    }
            }
            .modifier(OverlayModifier(coordinator: coordinator))
            .onAppear {
                coordinator.startApp()
            }
        }
    }

}



