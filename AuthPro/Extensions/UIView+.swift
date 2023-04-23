//
//  UIView+.swift
//  AuthPro
//
//  Created by 이주상 on 2023/04/18.
//

import UIKit

enum BorderSide: CaseIterable {
    case top, bottom, left, right
}

extension UIView {
    func vibrate() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.duration = 0.6
        animation.values = [-10.0, 10.0, -10.0, 10.0, -10.0, 10.0, -5.0, 5.0, 0.0 ]
        layer.add(animation, forKey: "shake")
    }
    
    func addBorder(side: BorderSide, color: UIColor, width: CGFloat) {
        let border = UIView()
        border.translatesAutoresizingMaskIntoConstraints = false
        border.backgroundColor = color
        self.addSubview(border)
        
        let topConstraint = topAnchor.constraint(equalTo: border.topAnchor)
        let rightConstraint = trailingAnchor.constraint(equalTo: border.trailingAnchor)
        let bottomConstraint = bottomAnchor.constraint(equalTo: border.bottomAnchor)
        let leftConstraint = leadingAnchor.constraint(equalTo: border.leadingAnchor)
        let heightConstraint = border.heightAnchor.constraint(equalToConstant: width)
        let widthConstraint = border.widthAnchor.constraint(equalToConstant: width)
        
        switch side {
        case .top:
            NSLayoutConstraint.activate([leftConstraint, topConstraint, rightConstraint, heightConstraint])
        case .right:
            NSLayoutConstraint.activate([topConstraint, rightConstraint, bottomConstraint, widthConstraint])
        case .bottom:
            NSLayoutConstraint.activate([rightConstraint, bottomConstraint, leftConstraint, heightConstraint])
        case .left:
            NSLayoutConstraint.activate([bottomConstraint, leftConstraint, topConstraint, widthConstraint])
        }
    }
    func removeBorder() {
        for sub in self.subviews{
            sub.removeFromSuperview()
        }
    }
    
    func removeRedBorder() {
        for sub in self.subviews{
            if sub.backgroundColor == .systemRed {
                sub.removeFromSuperview()
            }
        }
    }
    
    func removeFocusedBorder() {
        for sub in self.subviews{
            if sub.backgroundColor == Constants.primaryColor {
                sub.removeFromSuperview()
            }
        }
    }
}
