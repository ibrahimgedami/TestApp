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

enum AppRoute: Hashable {
    
    case splash
    case login
    case dashboard
    
}

enum OverlayType: Identifiable, Hashable {
    
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

class AppCoordinator: ObservableObject {
    
    static let shared = AppCoordinator()
    
    @Published var path: [AppRoute] = []
    @Published var activeOverlay: OverlayType?
    
    func navigate(to route: AppRoute) {
        path.append(route)
    }
    
    func pop() {
        if !path.isEmpty {
            path.removeLast()
        }
    }
    
    func showOverlay(_ overlay: OverlayType) {
        activeOverlay = overlay
    }
    
    func dismissOverlay() {
        activeOverlay = nil
    }
    
    // MARK: - Business Logic
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
