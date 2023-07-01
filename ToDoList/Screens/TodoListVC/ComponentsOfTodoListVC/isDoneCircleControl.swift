//
//  isDoneCircleControl.swift
//  ToDoList
//
//  Created by Anna Shuryaeva on 29.06.2023.
//

import Foundation
import UIKit

final class IsDoneCircleControl: UIControl {

    // MARK: - Properties

    private lazy var isDoneImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "doneGray")
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private var isHighImportance = false

    override var isSelected: Bool {
        didSet {
            if isSelected {
                isDoneImageView.image = UIImage(named: "done")
            } else {
                if isHighImportance {
                    isDoneImageView.image = UIImage(named: "circleRed")
                } else {
                    isDoneImageView.image = UIImage(named: "circleGray")
                }
            }
        }
    }

    // MARK: - Init

    init() {
        super.init(frame: .zero)
        configureUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Methods

    private func configureUI() {
        addSubview(isDoneImageView)
        isDoneImageView.image = UIImage(named: "circleGray")

        NSLayoutConstraint.activate([
            isDoneImageView.topAnchor.constraint(equalTo: topAnchor),
            isDoneImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            isDoneImageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            isDoneImageView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }

    // MARK: - Public functions

    func setRedColorForCircle(isHighImportance: Bool) {
        self.isHighImportance = isHighImportance
    }
}
