//
//  UserViewModel.swift
//  COMP-49X-24-25-PhoneArt-intro-project-updated
//
//  Created by Zachary Letcher on 11/17/24.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseAuth
import Combine

// Represents a user in the application
struct User: Codable {
  let email: String
  let name: String
  let isAdmin: Bool
  let uid: String
}

// Manages user authentication and data with Firebase
class UserViewModel: ObservableObject {
  @Published var currentUser: User? 
  @Published var isGuest: Bool = false 
  private let db = Firestore.firestore() 
  private var userNameCache: [String: String] = [:] 
  
   // Creates a new user account with the provided credentials
   func createUser(email: String, password: String, name: String, isAdmin: Bool) async throws {
      do {
          let authResult = try await Auth.auth().createUser(withEmail: email, password: password)
          // Store additional user data in Firestore
          try await db.collection("users").document(authResult.user.uid).setData([
              "email": email,
              "name": name,
              "isAdmin": isAdmin,
              "uid": authResult.user.uid
          ])
      } catch {
          throw error
      }
  }
  
   // Signs in an existing user with email and password
   func signIn(email: String, password: String) async throws {
      do {
          let authResult = try await Auth.auth().signIn(withEmail: email, password: password)
          try await fetchUser(userId: authResult.user.uid)
      } catch let error as NSError {
          throw error
      }
  }
  
   // Fetches user data from Firestore and updates the currentUser
   private func fetchUser(userId: String) async throws {
      do {
          let documentSnapshot = try await db.collection("users").document(userId).getDocument()
        
          // Check if document exists
          guard documentSnapshot.exists else {
              throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User document not found"])
          }
        
          guard let userData = try? documentSnapshot.data(as: User.self) else {
              throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to decode user data"])
          }
        
          DispatchQueue.main.async {
              self.currentUser = userData
          }
      } catch {
          throw error
      }
  }
  
   // Gets a user's name from their ID, using cache when possible
   func getUserName(userId: String) async -> String? {
      // Validate userId
      guard !userId.isEmpty else { return nil }
     
      // Check cache first. Was running into issues with the cache not being updated.
      if let cachedName = userNameCache[userId], !cachedName.isEmpty {
          return cachedName
      }
     
      do {
          let documentSnapshot = try await db.collection("users").document(userId).getDocument()
          guard let data = documentSnapshot.data(),
                let name = data["name"] as? String,
                !name.isEmpty else {
              return nil
          }
         
          // Store in cache
          DispatchQueue.main.async {
              self.userNameCache[userId] = name
          }
          return name
      } catch {
          return nil
      }
  }
}
