//
//  DetailScreen.swift
//  TodoListSUI
//
//  Created by Anna Shuryaeva on 20.07.2023.
//

import Foundation
import SwiftUI

struct DetailScreen: View {
    @Environment(\.presentationMode) private var presentationMode
    
    var item: TodoItem?
    
    @State private var toggle = false
    @State private var segmentOfPicker = 1
    @State private var showCalendar = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.background).ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 16) {
                        text
                        importance
                        deleteButton
                    }.padding(.vertical)
                    
                }.padding(.horizontal)
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(ConstantsText.task)
            .navigationBarItems(leading: cancelButton, trailing: saveButton)
        }
    }
    
    @ViewBuilder
    var cancelButton: some View {
        Button {
            presentationMode.wrappedValue.dismiss()
        } label: {
            Text(ConstantsText.cancel)
                .foregroundColor(item != nil ? Color(.saveColor) :  Color(.placeholderText))
        }
    }
    
    @ViewBuilder
    var saveButton: some View {
        Button {
            presentationMode.wrappedValue.dismiss()
        } label: {
            Text(ConstantsText.save)
                .foregroundColor(item != nil ? Color(.saveColor) :  Color(.placeholderText))
        }
    }
    
    @ViewBuilder
    var text: some View {
        HStack {
            ZStack {
                if let item = item {
                    Text(item.text)
                        .font(Font(UIFont.toDoBody))
                        .foregroundColor(Color(.text))
                } else {
                    Text(ConstantsText.whatToDo)
                        .foregroundColor(Color(.placeholderText))
                    
                }
            }
            .padding(.top, 12)
            .padding(.bottom, 72)
            .padding(.horizontal)
            Spacer()
        }
        .background(Color(.subviewsBackground))
        .cornerRadius(16)
    }
    
    @ViewBuilder
    var importance: some View {
        VStack(spacing: 0) {
            HStack {
                Text(ConstantsText.importance)
                Spacer()
                Picker("", selection: $segmentOfPicker) {
                    Image("lowImportance").tag(0)
                    Text("нет").tag(1)
                        .foregroundColor(Color(.text))
                    Image("highImportance").tag(2)
                }
                .pickerStyle(.segmented)
                .frame(width: 150)
                .background(Color(.segmentSelected))
                .onAppear{
                    segmentOfPicker = choosePickerSegment()
                }
            }
            .padding(.vertical, 20)
            Divider()
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(ConstantsText.deadlineBefore)
                    if let item = item {
                        if let date = item.deadline {
                            Button {
                                showCalendar.toggle()
                            } label: {
                                Text(formatDate(date: date))
                                    .font(Font(UIFont.toDoFootnote))
                                    .foregroundColor(Color(.saveColor))
                            }
                        }
                    }
                }
                Toggle("", isOn: $toggle)
                    .onAppear{
                        toggle = item?.deadline != nil
                    }
                Spacer()
            }
            .padding(.vertical, paddingForDeadline())
            if showCalendar {
                if let item = item, let date = item.deadline {
                    DatePickerView(initialSelectedDate: date)
                }
            }
        }
        .padding(.leading)
        .padding(.trailing, 12)
        .background(Color(.subviewsBackground))
        .cornerRadius(16)
    }
    
    @ViewBuilder
    var deleteButton: some View {
        Button {
            presentationMode.wrappedValue.dismiss()
        } label: {
            HStack {
                Spacer()
                Text(ConstantsText.delete)
                    .foregroundColor(item != nil ? Color(.redColor) : Color(.placeholderText) )
                Spacer()
            }
            .padding(.vertical, 20)
            .background(Color(.subviewsBackground))
            .cornerRadius(16)
        }
    }
    
    
    private func paddingForDeadline() -> CGFloat {
        var padding: CGFloat = 20
        if let item = item, item.deadline != nil {
            padding = 12
        }
        return padding
    }
    
    private func choosePickerSegment() -> Int {
        var segment = 1
        if let item = item {
            switch item.importance {
            case .low:
                segment = 0
            case .basic:
                segment = 1
            case .important:
                segment = 2
            }
        }
        return segment
    }
    
    private func formatDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy"
        let dateString = formatter.string(from: date)
        return dateString
    }
}







struct DetailScreen_Previews: PreviewProvider {
    static var previews: some View {
        DetailScreen(item: MockData().mock.last)
    }
}
