//
//  TodoItemEntity+CoreDataProperties.swift
//  ToDoList
//
//  Created by Anna Shuryaeva on 14.07.2023.
//
//

import Foundation
import CoreData

extension TodoItemEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TodoItemEntity> {
        return NSFetchRequest<TodoItemEntity>(entityName: "TodoItemEntity")
    }

    @NSManaged public var id: String?
    @NSManaged public var text: String?
    @NSManaged public var importance: String?
    @NSManaged public var dateCreated: Date?
    @NSManaged public var dateEdited: Date?
    @NSManaged public var isDone: Bool
    @NSManaged public var deadline: Date?

}

extension TodoItemEntity: Identifiable {

}
