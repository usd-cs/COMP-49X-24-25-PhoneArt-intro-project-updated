//
//  Comment+CoreDataProperties.swift
//  COMP-49X-24-25-PhoneArt-intro-project-updated
//
//  Created by Aditya Prakash on 11/14/24.
//
//

import Foundation
import CoreData


extension Comment {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Comment> {
        return NSFetchRequest<Comment>(entityName: "Comment")
    }

    @NSManaged public var created_at: Date?
    @NSManaged public var post_id: Int64
    @NSManaged public var user_id: Int64
    @NSManaged public var context: String?
    @NSManaged public var id: Int64
    @NSManaged public var user: User?
    @NSManaged public var post: Post?

}

extension Comment : Identifiable {

}
