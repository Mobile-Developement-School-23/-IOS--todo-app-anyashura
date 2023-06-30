//
//  AddNewItem.swift
//  ToDoList
//
//  Created by Anna Shuryaeva on 29.06.2023.
//

import Foundation
import UIKit

final class AddNewItem: UIControl {

    // MARK: - Enum

    private enum Constants {

        static let addNewImageName: String = "plus.circle.fill"
    }

    // MARK: - Subviews

    private lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI

    private func setUpView() {
        addSubview(imageView)
        imageView.image = UIImage(systemName: Constants.addNewImageName)?.withTintColor(.saveColor)
        imageView.contentMode = .scaleAspectFill

        addConstraints()
    }

    private func addConstraints() {
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
}
