//
//  ViewController.swift
//  ToDoList
//
//  Created by Anna Shuryaeva on 11.06.2023.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        
        let fileCache = FileCache()

        do {
            try fileCache.add(todoItem: TodoItem(id: "id",text: "text, text, text", importance: .normal, deadline: Date.now, isDone: true, dateEdited: Date.now))
        } catch {
            print(error.localizedDescription)
        }

        do {
            try fileCache.saveToSCV(file: "122.csv")
            try fileCache.loadFromCSV(file: "122.csv")
            try fileCache.save(file: "todo.json")
            try fileCache.load(file: "todo.json")
        } catch {
            print(error.localizedDescription)
        }
    }


}

