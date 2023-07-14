//
//  CoreDataContainer.swift
//  ToDoList
//
//  Created by Anna Shuryaeva on 14.07.2023.
//

import Foundation
import CoreData

final class CoreDataContainer {
    static let shared = CoreDataContainer()

    var persistentContainer: NSPersistentContainer = {

        let container = NSPersistentContainer(name: "TodoItemModel")
        container.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    lazy var context: NSManagedObjectContext = persistentContainer.viewContext
}
