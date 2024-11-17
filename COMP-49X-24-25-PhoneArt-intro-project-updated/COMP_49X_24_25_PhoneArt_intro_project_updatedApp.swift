//
//  COMP_49X_24_25_PhoneArt_intro_project_updatedApp.swift
//  COMP-49X-24-25-PhoneArt-intro-project-updated
//
//  Created by Aditya Prakash on 11/17/24.
//

import SwiftUI
import FirebaseCore

@main
struct COMP_49X_24_25_PhoneArt_intro_project_updatedApp: App {
    // Initialize Firebase when app launches
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
