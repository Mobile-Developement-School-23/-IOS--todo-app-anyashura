//
//  SelectedCell.swift
//  ToDoList
//
//  Created by Anna Shuryaeva on 20.07.2023.
//

import Foundation
import SwiftUI

struct SelectedCell: View {
    var item: TodoItem
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                circle
                VStack(alignment: .leading) {
                    HStack(alignment: .top, spacing: 5) {
                        importance
                        VStack(alignment: .leading, spacing: 2) {
                            text
                            deadline
                        }
                    }
                }
                Spacer()
                Image(systemName: "chevron.right")
            }
            .padding(.horizontal)
            .padding(.vertical, 20)
            Divider().padding(.leading, 52)
        }.background(Color(UIColor.subviewsBackground))
    }
    
    @ViewBuilder
    var circle: some View {
        Button {
        } label: {
            IsDoneCircleControlSUI(isSelected: item.isDone ? true : false, isHighImportance: item.importance == .important ? true : false)
        }
    }
    
    @ViewBuilder
    var importance: some View {
        if !item.isDone {
            if item.importance == .important {
                Image("highImportance")
                    .padding(.top, 2)
            } else if item.importance == .low {
                Image("lowImportance")
                    .padding(.top, 2)
            }
        }
    }
    
    @ViewBuilder
    var text: some View {
        if item.isDone {
            Text(item.text)
                .font(Font(UIFont.toDoBody))
                .foregroundColor(Color(.placeholderText))
                .strikethrough(true)
        } else {
            Text(item.text)
                .font(Font(UIFont.toDoBody))
                .foregroundColor(Color(.text))
                .lineLimit(3)
        }
    }
    
    @ViewBuilder
    var deadline: some View {
        if !item.isDone {
            if let date = item.deadline {
                HStack(spacing: 2) {
                    Image(systemName: "calendar")
                    Text(formatDate(date: date))
                        .font(Font(UIFont.toDoFootnote))
                }.foregroundColor(Color(.placeholderText))
            }
        }
    }
    
    private func formatDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy"
        let dateString = formatter.string(from: date)
        return dateString
    }
}







struct SelectedCell_Previews: PreviewProvider {
    static var previews: some View {
        SelectedCell(item: MockData().mock.first!)
    }
}
