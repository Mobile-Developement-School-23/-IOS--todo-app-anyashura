//
//  DatePickerView.swift
//  TodoListSUI
//
//  Created by Anna Shuryaeva on 20.07.2023.
//

import Foundation
import SwiftUI

struct DatePickerView: View {
    let initialSelectedDate: Date
    @State private var selectedDate: Date

    init(initialSelectedDate: Date) {
        self.initialSelectedDate = initialSelectedDate
        _selectedDate = State(initialValue: initialSelectedDate)
    }

    var body: some View {
        VStack {
            DatePicker("", selection: $selectedDate, in: Date()..., displayedComponents: .date)
                .labelsHidden()
                .datePickerStyle(.graphical)
        }
        .onAppear {
            selectedDate = initialSelectedDate
        }
    }
}

