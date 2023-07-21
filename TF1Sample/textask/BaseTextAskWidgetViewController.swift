//
//  BaseTextAskWidgetViewController.swift
//  TF1Sample
//
//  Created by Changdeo Jadhav on 21/07/23.
//

import Foundation
import EngagementSDK

class BaseTextAskWidgetViewController: Widget {
let widgetView: CustomTextAskView = {
    let view = CustomTextAskView()
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
}()

var textViewPlaceholder: String = "Type Something...." {
    didSet {
        self.setPlaceholderIfNeeded()
    }
}

var askTheme: Theme.TextAskWidget {
    theme.widgets.textAsk
}

let characterLimit: Int = 240

override func viewDidLoad() {
    super.viewDidLoad()
    
    view.addSubview(widgetView)
    
    NSLayoutConstraint.activate([
        widgetView.topAnchor.constraint(equalTo: view.topAnchor),
        widgetView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
        widgetView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        widgetView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ])
    
    widgetView.characterCountLabel.text = "\(characterLimit)"
    widgetView.userReplyTextView.returnKeyType = .done
    widgetView.userReplyTextView.delegate = self
    widgetView.submitReplyButton.addTarget(self, action: #selector(submitReplyButtonSelected(_:)), for: .touchUpInside)
    setPlaceholderIfNeeded()
    setSubmitButtonIsEnabled(false)
}

@objc func submitReplyButtonSelected(_ sender: UIButton) {
    widgetView.userReplyTextView.isEditable = false
    setSubmitButtonIsEnabled(false)
}

private func setPlaceholderIfNeeded() {
    if
        !self.widgetView.userReplyTextView.hasText,
        self.widgetView.userReplyTextView.text != self.textViewPlaceholder
    {
        self.widgetView.userReplyTextView.text = textViewPlaceholder
//        widgetView.userReplyTextView.theme(askTheme.placeholder)
    }
}


func setSubmitButtonIsEnabled(_ isEnabled: Bool) {
    widgetView.submitReplyButton.isEnabled = isEnabled
    if isEnabled {
        widgetView.submitReplyButton.titleLabel?.font = askTheme.submitTextEnabled.font
    } else {
        widgetView.submitReplyButton.titleLabel?.font = askTheme.submitTextDisabled.font
    }
}
}

extension BaseTextAskWidgetViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if self.widgetView.userReplyTextView.text == self.textViewPlaceholder {
            self.widgetView.userReplyTextView.text = nil
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        setPlaceholderIfNeeded()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // Dismiss keyboard when user hits return key
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        
        // Prevent user from typing after server enforced character limit reached
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        if newText == " " {
            return false
        }
        
        if newText.utf8.count > characterLimit {
            return false
        }
        
        widgetView.characterCountLabel.text = "\(characterLimit - newText.count)"
        
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        self.setSubmitButtonIsEnabled(!textView.text.isEmpty)
    }
}
