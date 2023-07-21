//
//  TodoList.swift
//  ToDoList
//
//  Created by Anna Shuryaeva on 20.07.2023.
//

import Foundation


import SwiftUI

struct TodoList: View {
    
    enum Constants {
        static let addNewImageName: String = "plus.circle.fill"
    }
    
    @State private var doneItemIsHidden: Bool = true
    @State private var selectedItem: TodoItem? = nil
    @State private var showNewDetailScreen = false
    private var mockData = MockData()
    
    var body: some View {
        NavigationView {
            ZStack {
                ScrollView{
                    VStack {
                        header
                        LazyVStack(spacing: 0) {
                            ForEach(showItems()) { item in
                                SelectedCell(item: item)
                                    .onTapGesture { selectedItem = item }
                                    .swipeActions(edge: .leading, content: {
                                        Button {
                                            //
                                        } label: {
                                            Label("", systemImage: "checkmark.circle.fill")
                                        }
                                        .background(Color(.systemGreen))
                                        .tint(Color(.systemGreen))
                                    })
                                    .swipeActions(edge: .trailing, content: {
                                        Button {
                                            //
                                        } label: {
                                            Label("", systemImage: "trash.fill")
                                        }
                                        .tint(Color(.redColor))
                                    })
                                
                            }
                            NewCell()
                                .onTapGesture { showNewDetailScreen.toggle() }
                        }

                        .sheet(item: $selectedItem) { item in
                            DetailScreen(item: item)
                        }
                        .sheet(isPresented: $showNewDetailScreen) {
                            DetailScreen(item: nil)
                        }
                        .cornerRadius(16)
                        .padding(.horizontal)
                    }
                    
                }
                .background(Color(.background))
                .navigationTitle(ConstantsText.myTasks)
                .navigationBarTitleDisplayMode(.large)
                .scrollIndicators(.never)
                .scrollContentBackground(.hidden)
                
                VStack {
                    Spacer()
                    addNewItemView
                }
            }
        }
    }
    
    @ViewBuilder
    var header: some View {
        HStack {
            Text(ConstantsText.isDone + "\(mockData.mock.filter({ $0.isDone}).count)")
                .foregroundColor(Color(.placeholderText))
                .font(Font(UIFont.toDoBody))
                .padding(.leading)
            
            Spacer()
            
            Button(action: {
                doneItemIsHidden.toggle()
            }) {
                Text(doneItemIsHidden ? ConstantsText.hide : ConstantsText.show)
                    .foregroundColor(Color(.saveColor))
                    .font(Font(UIFont.toDoHeadline))
            }
            .background(Color.clear)
            .padding(.trailing)
        }
        .padding()
        .onAppear {
            doneItemIsHidden = !doneItemIsHidden
        }
    }
    
    @ViewBuilder
    var addNewItemView: some View {
        Button {
            showNewDetailScreen.toggle()
        } label: {
            Image(systemName: Constants.addNewImageName)
                .resizable()
                .foregroundColor(Color(UIColor.saveColor))
                .frame(width: 44, height: 44)
                .padding(.bottom, 20)
        }
    }
    
    // MARK: - Methods
    func showItems() -> [TodoItem] {
        var items = [TodoItem]()
        if doneItemIsHidden {
            items = mockData.mock
        } else { items = mockData.mock.filter({ !$0.isDone }) }
        return items
    }
}






struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        TodoList()
    }
}

