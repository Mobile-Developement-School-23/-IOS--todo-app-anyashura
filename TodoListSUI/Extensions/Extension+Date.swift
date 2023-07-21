//
//  Extension + Date.swift
//  ToDoList
//
//  Created by Anna Shuryaeva on 21.06.2023.
//

import Foundation

// convert Date to Int
extension Date {
    var timeStamp: Int {
        Int(self.timeIntervalSince1970)
    }
}
