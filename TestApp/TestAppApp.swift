//
//  TestAppApp.swift
//  TestApp
//
//  Created by Ibrahim Gedami on 14/05/2024.
//

import SwiftUI
import AppBase
import CombineNetwork

@main
struct TestAppApp: App {
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                MediaViewer()
            }
        }
    }
    
}
