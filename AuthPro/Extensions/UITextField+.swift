//
//  UITextField+.swift
//  AuthPro
//
//  Created by 이주상 on 2023/04/18.
//

import UIKit

extension UITextField {
    func addLeftPadding() {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: Constants.textFieldPaddingX, height: self.frame.height))
        self.leftView = paddingView
        self.leftViewMode = ViewMode.always
    }
    func addRightPadding(padding: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: padding, height: self.frame.height))
        self.rightView = paddingView
        self.rightViewMode = ViewMode.always
    }
}
