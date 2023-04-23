//
//  Constants.swift
//  AuthPro
//
//  Created by 이주상 on 2023/04/18.
//

import UIKit

struct Constants {
    static let textFieldPaddingX: CGFloat = 10.0 // leading or trailing padding
    static let primaryColor: UIColor = UIColor(red: 0.36, green: 0.09, blue: 0.77, alpha: 1.00)
    struct regex {
        static let email: String = "^([a-zA-Z0-9._-])+@[a-zA-Z0-9.-]+.[a-zA-Z]{3,20}$"
        static let phone: String = "^01[0-1,7][0-9]{7,8}$"
        static let password: String = "^(?=.*[a-zA-Z])(?=.*[0-9])(?=.*[!@#$%^&*()_+=-]).{8,16}$"
    }
    struct errMsg {
        static let empty: String = "해당란을 입력해주세요"
        static let invalidPwCheck: String = "입력한 비밀번호와 다릅니다"
        static let invalidEmail: String = "올바른 이메일 패턴이 아닙니다"
        static let invalidPw: String = "비밀번호는 8~16자의 문자,숫자,특수기호 조합입니다"
    }
}
