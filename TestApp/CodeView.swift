//
//  CodeView.swift
//  TestApp
//
//  Created by Ibrahim Gedami on 03/03/2025.
//

import SwiftUI

//enum NavigationPath: Hashable {
//    case splash
//    case login
//    case dashboard
//}

enum OverlayPath: Hashable {
    
    case employee
    case authError(message: String)
    
}

class BaseCoordinator: ObservableObject {
    
    @Published var path: [NavigationPath] = []
    @Published var activeOverlay: OverlayPath?
    
    func navigate(to route: NavigationPath) {
        path.append(route)
    }
    
    func pop() {
        path.removeLast()
    }
    
    func showOverlay(_ overlay: OverlayPath) {
        activeOverlay = overlay
    }
    
    func dismissOverlay() {
        activeOverlay = nil
    }

}

class AppCoordinator: ObservableObject {
    static let shared = AppCoordinator()
    
    @Published var path = NavigationPath()
    @Published var isOverlayPresented = false
    @Published var activeOverlay: OverlayType?
    
    enum AppRoute: Hashable {
        
        case splash
        case login
        case dashboard
        
    }
    
    enum OverlayType: Identifiable {
        
        case employee
        case authError(message: String)
        
        var id: String {
            switch self {
            case .employee:
                return "employee"
            case .authError(let message):
                return message
            }
        }
    }
    
    func navigate(to route: AppRoute) {
        path.append(route)
    }
    
    func showOverlay(_ overlay: OverlayType) {
        self.activeOverlay = overlay
        self.isOverlayPresented = true
    }
    
    func dismissOverlay() {
        self.activeOverlay = nil
        self.isOverlayPresented = false
    }
    
    func loginSuccess() {
        showOverlay(.employee)
    }
    
    func authEmployeeSuccess() {
        dismissOverlay()
        navigate(to: .dashboard)
    }
    
    func startApp() {
        navigate(to: .splash)
    }

}
