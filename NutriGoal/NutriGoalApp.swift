//
//  NutriGoalApp.swift
//  NutriGoal
//
//  Created by Amirali Javadi on 6/7/25.
//

import SwiftUI

@main
struct NutriGoalApp: App {
    @StateObject private var diContainer = DIContainer.shared
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(diContainer)
        }
    }
}
