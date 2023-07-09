//
//  TextView.swift
//  ToDoList
//
//  Created by Anna Shuryaeva on 20.06.2023.
//

import Foundation
import UIKit

protocol TextViewDelegate: AnyObject {
    @MainActor func textViewDidChange(with text: String)
}

final class TextView: UITextView {

    // MARK: - Enum
    enum Constants {
        static let textViewCornerRadius: CGFloat = 16.0
    }

    // MARK: - Properties

    private let textView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()

    weak var delegateForText: TextViewDelegate?

    // MARK: - Init
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        setUpPlaceholder()
        addTextViewGesture()

        delegate = self
        backgroundColor = .subviewsBackground
        layer.cornerRadius = Constants.textViewCornerRadius
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private methods
    private func addTextViewGesture() {
        isUserInteractionEnabled = true
        let gesture = UITapGestureRecognizer(target: self, action: #selector(textViewTapped))
        addGestureRecognizer(gesture)
    }

    @objc private func textViewTapped() {
        becomeFirstResponder()
    }

    private func setUpPlaceholder() {
        textColor = .placeholderText
        font = .toDoBody
        text = ConstantsText.whatToDo
    }
}

// MARK: - Extension
extension TextView: UITextViewDelegate {

    func textViewDidChange(_ textView: UITextView) {
        guard let text = textView.text else { return }
        delegateForText?.textViewDidChange(with: text)

        if textView.text == nil || textView.text?.isEmpty == true || textView.text == ConstantsText.whatToDo {
            textView.text = ConstantsText.whatToDo
            let start = textView.beginningOfDocument
            textView.selectedTextRange = textView.textRange(from: start, to: start)
            setUpPlaceholder()
        } else {
            textColor = .text
        }
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == ConstantsText.whatToDo {
            let start = textView.beginningOfDocument
            textView.selectedTextRange = textView.textRange(from: start, to: start)
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        let text = textView.text

        if text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true {
            textView.text = ConstantsText.whatToDo
            setUpPlaceholder()
        } else {
            textColor = .text
        }
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if textView.text == ConstantsText.whatToDo {
            textView.text = ""
            textColor = .text
        }
        return true
    }
}
