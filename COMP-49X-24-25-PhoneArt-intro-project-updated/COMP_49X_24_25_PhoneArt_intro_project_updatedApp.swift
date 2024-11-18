//
//  COMP_49X_24_25_PhoneArt_intro_project_updatedApp.swift
//  COMP-49X-24-25-PhoneArt-intro-project-updated
//
//  Created by Aditya Prakash on 11/17/24.
//


import SwiftUI
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore


@main
struct COMP_49X_24_25_PhoneArt_intro_project_updatedApp: App {
   // Initialize Firebase when app launches
   init() {
       FirebaseApp.configure()
      
       // Create test users when app launches
       Task {
           do {
               let db = Firestore.firestore()
              
               // Check if test user exists in Firestore
               let testUserSnapshot = try await db.collection("users")
                   .whereField("email", isEqualTo: "test@example.com")
                   .getDocuments()
              
               if testUserSnapshot.documents.isEmpty {
                   // Create regular test user
                   try await UserViewModel().createUser(
                       email: "test@example.com",
                       password: "password123",
                       name: "Test User",
                       isAdmin: false
                   )
                  
                   if let uid = Auth.auth().currentUser?.uid {
                       try await db.collection("users").document(uid).setData([
                           "email": "test@example.com",
                           "name": "Test User",
                           "isAdmin": false,
                           "uid": uid
                       ])
                       print("Regular test user created successfully")
                   }
               }
              
               // Check if admin user exists in Firestore
               let adminUserSnapshot = try await db.collection("users")
                   .whereField("email", isEqualTo: "admin@example.com")
                   .getDocuments()
              
               if adminUserSnapshot.documents.isEmpty {
                   // Create admin test user
                   try await UserViewModel().createUser(
                       email: "admin@example.com",
                       password: "admin123",
                       name: "Admin User",
                       isAdmin: true
                   )
                  
                   if let uid = Auth.auth().currentUser?.uid {
                       try await db.collection("users").document(uid).setData([
                           "email": "admin@example.com",
                           "name": "Admin User",
                           "isAdmin": true,
                           "uid": uid
                       ])
                       print("Admin test user created successfully")
                   }
               }
              
           } catch {
               print("Error handling test users: \(error)")
           }
       }
   }
  
   var body: some Scene {
       WindowGroup {
           ContentView()
       }
   }
}
