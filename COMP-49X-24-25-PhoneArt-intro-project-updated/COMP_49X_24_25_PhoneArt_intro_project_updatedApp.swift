//
//  COMP_49X_24_25_PhoneArt_intro_project_updatedApp.swift
//  COMP-49X-24-25-PhoneArt-intro-project-updated
//
//  Created by Aditya Prakash on 11/14/24.
//

import SwiftUI

@main
struct COMP_49X_24_25_PhoneArt_intro_project_updatedApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
