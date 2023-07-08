//
//  TodoListCellViewModel.swift
//  ToDoList
//
//  Created by Anna Shuryaeva on 29.06.2023.
//

import Foundation
import UIKit

struct TodoCellViewModel {

    // MARK: - Properties

    let id: String
    var text: NSMutableAttributedString
    var importance: TodoItem.Importance
    var deadline: NSMutableAttributedString?
    var isDone: Bool {
        didSet {
            text = TodoCellViewModel.getStrikeThroughTextIfNeeded(for: text, isDone: isDone)
        }
    }

    // MARK: - Init

    init(from item: TodoItem) {
        self.id = item.id
        self.importance = item.importance
        self.isDone = item.isDone

        let textMutableString = TodoCellViewModel.getImportantTextIfNeeded(for: item.text, importance: item.importance)
        text = TodoCellViewModel.getStrikeThroughTextIfNeeded(for: textMutableString, isDone: item.isDone)

        guard let deadline = item.deadline else { return }
        let dateString = TodoCellViewModel.dateToString(from: deadline)
        self.deadline = TodoCellViewModel.addCalendar(string: dateString)
    }

    // MARK: - Methods
    private static func getImportantTextIfNeeded(for text: String, importance: TodoItem.Importance) -> NSMutableAttributedString {
        let fullTextString: NSMutableAttributedString = NSMutableAttributedString(string: "")
        let taskTextMutableString = NSMutableAttributedString(string: text)
        if importance == .high {
            let imageImportanceAttachment = NSTextAttachment()
            imageImportanceAttachment.image = UIImage(named: "highImportance")
            let imageString = NSAttributedString(attachment: imageImportanceAttachment)
            let spaceString = NSAttributedString(string: " ")
            fullTextString.append(imageString)
            fullTextString.append(spaceString)
        }
        fullTextString.append(taskTextMutableString)
        return fullTextString
    }

    private static func getStrikeThroughTextIfNeeded(for string: NSMutableAttributedString, isDone: Bool) -> NSMutableAttributedString {
        if isDone {
            string.addAttributes(
                [
                    .foregroundColor: UIColor.placeholderText,
                    .strikethroughStyle: 1
                ],
                range: NSRange(location: 0, length: string.length)
            )
        } else {
            string.removeAttribute(.strikethroughStyle, range: NSRange(location: 0, length: string.length))
        }
        return string
    }

    private static func addCalendar(string: String) -> NSMutableAttributedString {
        let fullString = NSMutableAttributedString(string: "")

        let imageCalendarAttachment = NSTextAttachment()
        imageCalendarAttachment.image = UIImage(systemName: "calendar")?.withTintColor(.placeholderText)
        let imageString = NSAttributedString(attachment: imageCalendarAttachment)

        fullString.append(imageString)
        fullString.append(NSAttributedString(string: " " + string))

        fullString.addAttributes(
            [
                .font: UIFont.toDoBody,
                .foregroundColor: UIColor.placeholderText
            ],
            range: NSRange(location: 0, length: fullString.length)
        )

        return fullString
    }

    private static func dateToString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM"
        let dateString = formatter.string(from: date)
        return dateString
    }
}
