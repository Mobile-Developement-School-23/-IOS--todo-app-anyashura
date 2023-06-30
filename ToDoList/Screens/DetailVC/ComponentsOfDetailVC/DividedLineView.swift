//
//  DividedLineView.swift
//  ToDoList
//
//  Created by Anna Shuryaeva on 23.06.2023.
//

import Foundation
import UIKit

final class DividedLineView: UIView {
    // MARK: - Init
    init() {
        super.init(frame: .zero)
        backgroundColor = .separatorColor
        let lineHeight = 1 / UIScreen.main.scale
        heightAnchor.constraint(equalToConstant: lineHeight).isActive = true
        leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
