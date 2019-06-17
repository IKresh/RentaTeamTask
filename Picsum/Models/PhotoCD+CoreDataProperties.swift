//
//  PhotoCD+CoreDataProperties.swift
//  Picsum
//
//  Created by Ivan on 16/06/2019.
//  Copyright © 2019 Ivan. All rights reserved.
//
//

import Foundation
import CoreData


extension PhotoCD {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PhotoCD> {
        return NSFetchRequest<PhotoCD>(entityName: "PhotoCD")
    }

    @NSManaged public var height: Int32
    @NSManaged public var width: Int32
    @NSManaged public var author: String?
    @NSManaged public var downloadUrl: String?
    @NSManaged public var id: String?
    @NSManaged public var url: String?
    @NSManaged public var date: NSDate?

}
