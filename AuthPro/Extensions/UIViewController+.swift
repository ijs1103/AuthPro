//
//  UIViewController+.swift
//  AuthPro
//
//  Created by 이주상 on 2023/04/18.
//

import UIKit

extension UIViewController {
    func setupNavigationTitle() {
        let image = UIImage(named: "Netflix_Logo.png")
        let imageView = UIImageView(image: image)
        let width = navigationController?.navigationBar.frame.size.width
        let height = navigationController?.navigationBar.frame.size.height
        imageView.frame = CGRect(x: 0.0, y: 0.0, width: width!, height: height!)
        imageView.contentMode = .scaleAspectFit
        navigationItem.titleView = imageView
    }
    func messageAlert(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "확인", style: .default)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }
    func messageAlert(message: String, completion: @escaping () -> Void) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "확인", style: .default) { okTappped in
            completion()
        }
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }
    func pushToProfileViewController(id: String, imageURL: URL? = nil) {
        let profileViewController = ProfileViewController()
        profileViewController.updateProfile(id: id, imageURL: imageURL)
        navigationController?.pushViewController(profileViewController, animated: false)
    }
    // MARK: - form 유효성 검사
    func formValidCheck(textField: UITextField, button: SubmitButton, formInputArr: [FormInput], extraCheck: (() -> Bool)? = nil) {
        if !isFormFilled(textField: textField, formInputArr: formInputArr) {
            textField.vibrate()
            button.toggleEnabled(isEnabled: false)
            return
        }
        if !isFormRegexValid(textField: textField, formInputArr: formInputArr) {
            textField.vibrate()
            button.toggleEnabled(isEnabled: false)
            return
        }
        
        hideAllErrorMessage(formInputArr: formInputArr)
        
        if let extraCheck = extraCheck {
            if !extraCheck() {
                button.toggleEnabled(isEnabled: false)
                return
            }
        }
        
        if !isAllFormFilled(formInputArr: formInputArr) {
            button.toggleEnabled(isEnabled: false)
            return
        }
        
        // 검사를 전부 통과하면, 버튼 활성화
        button.toggleEnabled(isEnabled: true)
    }
    private func hideAllErrorMessage(formInputArr: [FormInput]) {
        formInputArr.forEach {
            $0.errorLabel.isHidden = true
        }
    }
    private func addRedBorder(textField: UITextField) {
        BorderSide.allCases.forEach {
            textField.addBorder(side: $0, color: .systemRed, width: 1.0)
        }
    }
    private func removeBorder(textField: UITextField) {
        textField.removeBorder()
//        textField.removeRedBorder()
//        textField.removeFocusedBorder()
    }
    private func isFormFilled(textField: UITextField, formInputArr: [FormInput]) -> Bool {
        if textField.text?.count == 1, textField.text?.first == " " {
            textField.text = ""
            return false
        }
        if let text = textField.text, !text.isEmpty {
            removeBorder(textField: textField)
            return true
        } else {
            if let currentInput = formInputArr.first(where: {
                $0.formType.rawValue == textField.tag
            }) {
                currentInput.checkMark.isHidden = true
                currentInput.errorLabel.text = Constants.errMsg.empty
                currentInput.errorLabel.isHidden = false
            }
            addRedBorder(textField: textField)
            return false
        }
    }
    private func isFormRegexValid(textField: UITextField, formInputArr: [FormInput]) -> Bool {
        guard (textField.text != nil) else { return false }
        if let currentInput = formInputArr.first(where: {
            $0.formType.rawValue == textField.tag
        }) {
            if let currentInputText = currentInput.textField.text {
                if !(currentInputText.isTextRegexValid(formType: currentInput.formType)) {
                    currentInput.checkMark.isHidden = true
                    currentInput.errorLabel.isHidden = false
                    currentInput.errorLabel.text = currentInput.formType.errorMsg
                    addRedBorder(textField: textField)
                    return false
                } else {
                    removeBorder(textField: textField)
                    currentInput.checkMark.isHidden = false
                }
            }
        }
        
        return true
    }
    
    private func isAllFormFilled(formInputArr: [FormInput]) -> Bool {
        return formInputArr.allSatisfy {
            $0.textField.text != ""
        }
    }
    
}
