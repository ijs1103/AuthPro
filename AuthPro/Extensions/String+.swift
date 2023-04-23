//
//  String+.swift
//  AuthPro
//
//  Created by 이주상 on 2023/04/19.
//

import Foundation

extension String {
    func isTextRegexValid(formType: FormType) -> Bool {
        switch formType {
        case .id:
            return range(of: Constants.regex.email, options: .regularExpression) != nil
        case .password, .passwordCheck:
            return range(of: Constants.regex.password, options: .regularExpression) != nil
        case .birth:
            return true
        }
    }

}
