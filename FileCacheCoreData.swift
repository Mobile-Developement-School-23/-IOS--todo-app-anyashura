//
//  FileCacheCoreData.swift
//  ToDoList
//
//  Created by Anna Shuryaeva on 14.07.2023.
//

import Foundation
import CoreData
import CocoaLumberjackSwift

final class FileCacheCoreData: FileCacheDBService {
    private(set) public var todoItems: [TodoItem] = []
    
    private let context: NSManagedObjectContext
    
    init() {
        context = CoreDataContainer.shared.persistentContainer.viewContext
    }
    
    func load(completion: @escaping (Swift.Result<[TodoItem], Error>) -> Void) {
        DispatchQueue.global().async  { [weak self] in
            guard let self = self else { return }
            do {
                try  self.loadItemsFromCoreData()
                completion(.success(self.todoItems))
            } catch let error {
                completion(.failure(error))
            }
        }
    }
    
    func save(items: [TodoItem], completion: @escaping (Swift.Result<[TodoItem], Error>) -> Void) {
        DispatchQueue.global().async  { [weak self] in
            do {
                try self?.saveItemsIntoCoreData(items: items)
                print("Saved")
                completion(.success(items))
                
            } catch let error {
                completion(.failure(error))
                
            }
        }
    }
    
    func insert(item: TodoItem, completion: @escaping (Swift.Result<TodoItem, Error>) -> Void) {
        DispatchQueue.global().async  { [weak self] in
            guard let self = self else { return }
            do {
                try self.insertItemIntoCoreData(item: item)
                print("Created item")
                completion(.success(item))
            } catch let error {
                completion(.failure(error))
            }
        }
    }
    
    func replace(item: TodoItem, completion: @escaping (Swift.Result<TodoItem, Error>) -> Void) {
        DispatchQueue.global().async  { [weak self] in
            guard let self = self else { return }
            do {
                try self.updateItemIntoCoreData(item: item)
                print("Updated item")
                completion(.success(item))
            } catch let error {
                completion(.failure(error))
            }
        }
    }
    
    func delete(_ id: String, completion: @escaping (Swift.Result<Void, Error>) -> Void) {
        DispatchQueue.global().async  { [weak self] in
            guard let self = self else { return }
            do {
                try self.delete(id: id)
                print("Item was deleted")
                completion(.success(()))
            } catch let error {
                completion(.failure(error))
            }
        }
    }
    
    private func loadItemsFromCoreData()  throws {
        let fetchRequest: NSFetchRequest<TodoItemEntity> = TodoItemEntity.fetchRequest()
        do {
            let entities = try context.fetch(fetchRequest)
            for entity in entities {
                if let item = TodoItem.parseCoreData(entity: entity) {
                    todoItems.append(item)
                    print(todoItems)
                }
            }
            return
        } catch {
            DDLogError(error.localizedDescription)
            return
        }
    }
    
    private func saveItemsIntoCoreData(items: [TodoItem]) throws {
        do {
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = TodoItemEntity.fetchRequest()
            let deleteAllRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            
            try context.execute(deleteAllRequest)
            for item in items {
                if let itemEntity = item.coreDataEntity {
                    context.insert(itemEntity)
                }
            }
            try context.save()
            return
        } catch {
            DDLogError(error.localizedDescription)
            return
        }
    }
    
    private func insertItemIntoCoreData(item: TodoItem) throws {
        guard let entity = item.coreDataEntity
        else { return }
        context.insert(entity)
        
        do {
            try context.save()
            todoItems.append(item)
            print(todoItems)
        } catch {
            DDLogError(error.localizedDescription)
        }
    }
    
    private func updateItemIntoCoreData(item: TodoItem) throws {
        let fetchRequest: NSFetchRequest<TodoItemEntity> = TodoItemEntity.fetchRequest()
        do {
            guard let todoItemDB = try context.fetch(fetchRequest).first(where: { $0.id == item.id })
            else { return }
            
            guard let itemEntity = item.coreDataEntity
            else { return  }
            
            todoItemDB.text = itemEntity.text
            todoItemDB.dateCreated = itemEntity.dateCreated
            todoItemDB.importance = itemEntity.importance
            todoItemDB.deadline = itemEntity.deadline
            todoItemDB.dateEdited = itemEntity.dateEdited
            todoItemDB.isDone = itemEntity.isDone
            
            try context.save()
            todoItems.removeAll(where: { $0.id == item.id })
            todoItems.append(item)
            return
        } catch {
            DDLogError(error.localizedDescription)
            return
        }
    }
    
    private func delete(id: String) throws {
        let fetchRequest: NSFetchRequest<TodoItemEntity> = TodoItemEntity.fetchRequest()
        do {
            if let item = try context.fetch(fetchRequest).first(where: { $0.id == id }) {
                context.delete(item)
                try context.save()
                todoItems.removeAll(where: { $0.id == id })
            }
            return
        } catch {
            DDLogError(error.localizedDescription)
            return
        }
    }
}

