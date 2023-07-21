//
//  IsDoneCircleControlSUI.swift
//  ToDoList
//
//  Created by Anna Shuryaeva on 19.07.2023.
//

import Foundation
import SwiftUI

struct IsDoneCircleControlSUI: View {
    @State var isSelected: Bool
    @State var isHighImportance: Bool
    
    var body: some View {
        
        Image(isSelected ? "done" : (isHighImportance ? "circleRed" : "circleGray"))
            .onTapGesture {
                isSelected.toggle()
            }
    }
}

struct IsDoneCircleControlSUI_Previews: PreviewProvider {
    static var previews: some View {
        IsDoneCircleControlSUI(isSelected: false, isHighImportance: true)
    }
}
