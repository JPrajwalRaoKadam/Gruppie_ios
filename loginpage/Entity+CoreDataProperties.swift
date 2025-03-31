//
//  Entity+CoreDataProperties.swift
//  
//
//  Created by apple on 17/03/25.
//
//

import Foundation
import CoreData


extension Entity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Entity> {
        return NSFetchRequest<Entity>(entityName: "Entity")
    }

    @NSManaged public var phone: String?
    @NSManaged public var password: String?

}
