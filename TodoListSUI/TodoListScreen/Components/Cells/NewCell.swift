//
//  NewCell.swift
//  ToDoList
//
//  Created by Anna Shuryaeva on 20.07.2023.
//

import Foundation
import SwiftUI

struct NewCell: View {
    var body: some View {
        HStack {
            Text(ConstantsText.new)
                .font(Font(UIFont.toDoBody))
                .foregroundColor(Color(.placeholderText))
                .padding(.leading, 52)
            Spacer()
        }
        .padding(.vertical, 20)
        .background(Color(.subviewsBackground))
    }
}

struct NewCell_Previews: PreviewProvider {
    static var previews: some View {
        NewCell()
    }
}
