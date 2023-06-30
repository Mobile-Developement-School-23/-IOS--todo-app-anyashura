//
//  ToDoListTests.swift
//  ToDoListTests
//
//  Created by Anna Shuryaeva on 11.06.2023.
//

import XCTest
@testable import ToDoList

final class ToDoListTests: XCTestCase {
    
    // MARK: - Tests for TodoItem
    // Сделала тесты только для TodoItem (в ТЗ написано только для этого)
    func testParsingJSONWithoutOptionals() throws {
        let json: [String:Any] =
        [
            "id": "id",
            "text": "text",
            "isDone": true,
            "importance": "low",
            "dateCreated": 1686945208
        ]
        guard let item = TodoItem.parse(json: json) else {
            XCTFail("Не получилось распарсить JSON в todoItem")
            return
        }
        XCTAssertEqual(item.id, "id", "Парсинг id")
        XCTAssertEqual(item.text, "text", "Парсинг текста")
        XCTAssertEqual(item.importance, TodoItem.Importance.low, "Парсинг важности")
        XCTAssertEqual(item.deadline, nil, "Парсинг даты дедлайна")
        XCTAssertEqual(item.dateCreated, 1686945208.dateFormat, "Парсинг даты создания")
        XCTAssertEqual(item.dateEdited, nil, "Парсинг даты редактирования")
        XCTAssertEqual(item.isDone, true, "Парсинг статуса готовности")
    }
    
    func testParsingJSONWithNormalImportanceAndAllFields() throws {
        let json: [String:Any] =
        [
            "id": "id",
            "text": "text",
            "isDone": false,
            "dateCreated": 1686945208,
            "dateEdited": 1686945209,
            "deadline": 1686945309
        ]
        guard let item = TodoItem.parse(json: json) else {
            XCTFail("Не получилось распарсить JSON в todoItem")
            return
        }
        XCTAssertEqual(item.id, "id", "Парсинг id")
        XCTAssertEqual(item.text, "text", "Парсинг текста")
        XCTAssertEqual(item.importance, TodoItem.Importance.normal, "Парсинг важности")
        XCTAssertEqual(item.deadline, 1686945309.dateFormat, "Парсинг даты дедлайна")
        XCTAssertEqual(item.dateCreated, 1686945208.dateFormat, "Парсинг даты создания")
        XCTAssertEqual(item.dateEdited, 1686945209.dateFormat, "Парсинг даты редактирования")
        XCTAssertEqual(item.isDone, false, "Парсинг статуса готовности")
    }
    
    func testParsingCSVWithoutOptionals() throws {
        let csvString = "5A0C0E34-B9F6-4C0B-963B-8E4838AAD99E,text,high,, true,1686946798,"
        guard let item = TodoItem.parseCSV(csvString: csvString) else {
            XCTFail("Не получилось распарсить CSV в todoItem")
            return
        }
        XCTAssertEqual(item.id, "5A0C0E34-B9F6-4C0B-963B-8E4838AAD99E", "Парсинг id")
        XCTAssertEqual(item.text, "text", "Парсинг текста")
        XCTAssertEqual(item.importance, TodoItem.Importance.high, "Парсинг важности")
        XCTAssertEqual(item.deadline, nil, "Парсинг даты дедлайна")
        XCTAssertEqual(item.dateCreated, 1686946798.dateFormat, "Парсинг даты создания")
        XCTAssertEqual(item.dateEdited, nil, "Парсинг даты редактирования")
        XCTAssertEqual(item.isDone, true, "Парсинг статуса готовности")
    }
    
    func testParsingCSVWithNormalImportanceAndAllFields() throws {
        let csvString = "id,text,,1686947257, false,1686947257,1686947257"
        guard let item = TodoItem.parseCSV(csvString: csvString) else{
            XCTFail("Не получилось распарсить CSV в todoItem")
            return
        }
        XCTAssertEqual(item.id, "id", "Парсинг id")
        XCTAssertEqual(item.text, "text", "Парсинг текста")
        XCTAssertEqual(item.importance, TodoItem.Importance.normal, "Парсинг важности")
        XCTAssertEqual(item.deadline, 1686947257.dateFormat, "Парсинг даты дедлайна")
        XCTAssertEqual(item.dateCreated, 1686947257.dateFormat, "Парсинг даты создания")
        XCTAssertEqual(item.dateEdited, 1686947257.dateFormat, "Парсинг даты редактирования")
        XCTAssertEqual(item.isDone, false, "Парсинг статуса готовности")
    }
    
    func testConvertStructToCsvWithNormalImportanceAndAllFields() {
        let deadline = Date(timeIntervalSinceNow: 86400)
        let dateCreated = Date()
        let dateEdited = Date(timeIntervalSinceNow: 3600)
        
        let item = TodoItem(
            id: "123",
            text: "text",
            importance: TodoItem.Importance.normal,
            deadline: Date(timeIntervalSinceNow: 86400),
            isDone: false,
            dateCreated: Date(),
            dateEdited: Date(timeIntervalSinceNow: 3600)
        )
        
        let csvString = item.csvString
        
        XCTAssertEqual
        (csvString, "123,text,,\(Int(deadline.timeIntervalSince1970)), false,\(Int(dateCreated.timeIntervalSince1970)),\(Int(dateEdited.timeIntervalSince1970))",
        "Получение строки из todoItem")
    }
    
    func testConvertStructToCsvWithoutOptionals() {
        let dateCreated = Date()
        
        let item = TodoItem(
            id: "123",
            text: "text",
            importance: TodoItem.Importance.high,
            isDone: true,
            dateCreated: Date()
        )
        let csvString = item.csvString
        
        XCTAssertEqual(csvString, "123,text,high,, true,\(Int(dateCreated.timeIntervalSince1970)),", "Получение строки из todoItem")
    }
    
    func testConvertStructToJsonWithNormalImportanceAndAllFields() {
        let id = "123"
        let text = "Some text"
        let importance = TodoItem.Importance.normal
        let deadline = Date(timeIntervalSinceNow: 86400)
        let isDone = false
        let dateCreated = Date()
        let dateEdited = Date(timeIntervalSinceNow: 3600)
        
        let item = TodoItem(
            id: id,
            text: text,
            importance: importance,
            deadline: deadline,
            isDone: isDone,
            dateCreated: dateCreated,
            dateEdited: dateEdited
        )
        
        let json = item.json as? [String: Any]
        XCTAssertEqual(json?[TodoItem.Constants.id] as? String, id)
        XCTAssertEqual(json?[TodoItem.Constants.text] as? String, text)
        XCTAssertEqual(json?[TodoItem.Constants.deadline] as? Int, Int(deadline.timeIntervalSince1970))
        XCTAssertNil(json?[TodoItem.Constants.importance])
        XCTAssertEqual(json?[TodoItem.Constants.isDone] as? Bool, isDone)
        XCTAssertEqual(json?[TodoItem.Constants.dateCreated] as? Int, Int(dateCreated.timeIntervalSince1970))
        XCTAssertEqual(json?[TodoItem.Constants.dateEdited] as? Int, Int(dateEdited.timeIntervalSince1970))
    }
    
    func testConvertStructToJsonWithoutOptionals() {
        let id = "123"
        let text = "Some text"
        let importance = TodoItem.Importance.low
        let deadline: Date? = nil
        let isDone = false
        let dateCreated = Date()
        let dateEdited: Date? = nil
        
        let item = TodoItem(
            id: id,
            text: text,
            importance: importance,
            deadline: deadline,
            isDone: isDone,
            dateCreated: dateCreated,
            dateEdited: dateEdited
        )
        
        let json = item.json as? [String: Any]
        XCTAssertEqual(json?[TodoItem.Constants.id] as? String, id)
        XCTAssertEqual(json?[TodoItem.Constants.text] as? String, text)
        XCTAssertNil(json?[TodoItem.Constants.deadline])
        XCTAssertNil(json?[TodoItem.Constants.dateEdited])
        XCTAssertEqual(json?[TodoItem.Constants.isDone] as? Bool, isDone)
        XCTAssertEqual(json?[TodoItem.Constants.dateCreated] as? Int, Int(dateCreated.timeIntervalSince1970))
    }
    
    func testConvertStructToCsvWithSeparatorInName() {
        let item = TodoItem(
            id: "123",
            text: "text, text, text",
            importance: TodoItem.Importance.normal,
            isDone: false,
            dateCreated: Date.now
        )
        
        let csvString = item.csvString
        
        XCTAssertEqual(csvString, "123,text~ text~ text,,, false,\(Date.now.timeStamp),", "Получение строки из todoItem со знаком сепаратора внутри")
    }
    
    func testJSONInAnotherFormat() {
        let json: [Int:Any] =
        [
            1: "id",
            2: "text"
        ]
        let item = TodoItem.parse(json: json)
        XCTAssertNil(item)
    }
    
    func testParsingJSONWithNil() throws {
        let json: [String:Any] =
        [
            "id": 1,
            "text": 1,
            "isDone": 1,
            "dateCreated": "1686945208"
        ]
        let item = TodoItem.parse(json: json)
        XCTAssertNil(item, "Неправильный формат обязательных полей")
    }
}
