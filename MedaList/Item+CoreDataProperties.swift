//
//  Item+CoreDataProperties.swift
//  MedaList
//
//  Created by 전민섭 on 2017/07/21.
//  Copyright © 2017年 JeonMinseop. All rights reserved.
//

import Foundation
import CoreData


extension Item {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Item> {
        return NSFetchRequest<Item>(entityName: "Item")
    }

    @NSManaged public var checkImage: String?
    @NSManaged public var title: String?
    @NSManaged public var detail: String?
    @NSManaged public var notiSet: String?
    @NSManaged public var hour: Int16
    @NSManaged public var minute: Int16

}
