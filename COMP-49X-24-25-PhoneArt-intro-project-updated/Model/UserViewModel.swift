import Foundation
import Firebase
import FirebaseFirestore
import FirebaseAuth


struct User: Codable {
   let email: String
   let name: String
   let isAdmin: Bool
   let uid: String
}


class UserViewModel: ObservableObject {
   @Published var currentUser: User?
   private let db = Firestore.firestore()
  
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
  
   func signIn(email: String, password: String) async throws {
       do {
           print("Attempting sign in for email: \(email)")
           let authResult = try await Auth.auth().signIn(withEmail: email, password: password)
           print("Auth successful for user: \(authResult.user.uid)")
          
           try await fetchUser(userId: authResult.user.uid)
           print("User fetched successfully: \(String(describing: currentUser))")
       } catch let error as NSError {
           print("Sign in error: \(error.localizedDescription)")
           throw error
       }
   }
  
   private func fetchUser(userId: String) async throws {
       do {
           let documentSnapshot = try await db.collection("users").document(userId).getDocument()
          
           // Check if document exists
           guard documentSnapshot.exists else {
               print("No user document found for ID: \(userId)")
               throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User document not found"])
           }
          
           // Print the raw data for debugging
           if let data = documentSnapshot.data() {
               print("Raw Firestore data: \(data)")
           }
          
           guard let userData = try? documentSnapshot.data(as: User.self) else {
               print("Failed to decode user data for ID: \(userId)")
               print("Document data: \(documentSnapshot.data() ?? [:])")
               throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to decode user data"])
           }
          
           DispatchQueue.main.async {
               self.currentUser = userData
           }
       } catch {
           print("Error fetching user: \(error.localizedDescription)")
           throw error
       }
   }
}
