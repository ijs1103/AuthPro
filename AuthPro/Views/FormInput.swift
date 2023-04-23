//
//  FormInput.swift
//  AuthPro
//
//  Created by 이주상 on 2023/04/18.
//

import UIKit
import SnapKit

enum FormType: Int {
    case id = 0
    case password, passwordCheck, birth
    var label: String {
        switch self {
        case .id:
            return "아이디"
        case .password:
            return "비밀번호"
        case .passwordCheck:
            return "비밀번호 확인"
        case .birth:
            return "생년월일"
        }
    }
    var errorMsg: String {
        switch self {
        case .id:
            return "올바른 이메일 패턴이 아닙니다"
        case .password, .passwordCheck:
            return "비밀번호는 8~16자의 문자,숫자,특수기호 조합입니다"
        case .birth:
            return ""
        }
    }
}

protocol FormInputDelegate: AnyObject {
    func textFieldEditingDidEnd(_ textField: UITextField)
}

final class FormInput: UIView {
    
    weak var formInputDelegate: FormInputDelegate?
    
    let formType: FormType
            
    private let isPassword: Bool
    
    private let isBirth: Bool

    private lazy var textLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        return label
    }()
    
    lazy var checkMark: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "checkmark.seal.fill")
        imageView.tintColor = .systemGreen
        imageView.isHidden = true
        return imageView
    }()
    
    lazy var textField: UITextField = {
        var textField = UITextField()
        textField.backgroundColor = #colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        textField.textColor = .white
        textField.tintColor = Constants.primaryColor
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.spellCheckingType = .no
        textField.keyboardType = .emailAddress
        textField.isSecureTextEntry = isPassword
        textField.clearsOnBeginEditing = isPassword
        textField.delegate = self
        textField.addLeftPadding()
        let rightPadding = isPassword ? 50.0 : Constants.textFieldPaddingX
        textField.addRightPadding(padding: rightPadding)
        textField.addTarget(self, action: #selector(textFieldEditingDidEnd(_:)), for: .editingDidEnd)
        if isBirth {
            textField.inputView = datePicker
            textField.inputAccessoryView = toolBar
        }
        return textField
    }()
    // 패스워드 보이기 on/off 버튼
    private lazy var passwordToggleButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "eye"), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(togglePasswordView), for: .touchUpInside)
        return button
    }()
    
    lazy var errorLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .red
        label.isHidden = true
        return label
    }()
    
    private lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.datePickerMode = .date
        datePicker.locale = Locale(identifier: "ko-KR")
        datePicker.timeZone = .autoupdatingCurrent
        var components = DateComponents()
        components.year = 1
        let maxYear = Calendar.autoupdatingCurrent.date(byAdding: components, to: Date())
        components.year = -40
        let minYear = Calendar.autoupdatingCurrent.date(byAdding: components, to: Date())
        datePicker.maximumDate = maxYear
        datePicker.minimumDate = minYear
        datePicker.addTarget(self, action: #selector(handleDatePicker(_:)), for: .valueChanged)
        return datePicker
    }()
    
    private lazy var toolBar: UIToolbar = {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let okButton = UIBarButtonItem(title: "확인", style: .done, target: self, action: #selector(didTappedOkButton))
        okButton.tintColor = Constants.primaryColor
        toolbar.setItems([okButton], animated: true)
        toolbar.isUserInteractionEnabled = true
        return toolbar
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [textLabel, textField])
        stackView.spacing = 4
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        return stackView
    }()
    
    init(formType: FormType) {
        self.isBirth = formType == .birth
        self.isPassword = [.password, .passwordCheck].contains(formType)
        self.formType = formType
        super.init(frame: .zero)
        textLabel.text = formType.label
        textField.tag = formType.rawValue
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension FormInput {
    private func setupViews() {
        [ stackView, checkMark, errorLabel ].forEach {
            addSubview($0)
        }
        textField.snp.makeConstraints {
            $0.height.equalTo(40)
        }
        stackView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
        }
        checkMark.snp.makeConstraints {
            $0.width.height.equalTo(20)
            $0.trailing.equalTo(textField.snp.trailing)
            $0.bottom.equalTo(textField.snp.top).inset(-10)
        }
        errorLabel.snp.makeConstraints {
            $0.leading.equalTo(textField.snp.leading)
            $0.top.equalTo(textField.snp.bottom).offset(4)
            $0.bottom.equalToSuperview().offset(10)
        }
        
        if isPassword {
            addSubview(passwordToggleButton)
            passwordToggleButton.snp.makeConstraints {
                $0.centerY.equalTo(textField)
                $0.trailing.equalTo(textField).inset(20)
            }
        }
    }
    @objc private func togglePasswordView() {
        textField.isSecureTextEntry.toggle()
        let imageName = textField.isSecureTextEntry ? "eye" : "eye.slash"
        passwordToggleButton.setImage(UIImage(systemName: imageName), for: .normal)
    }
    private func addPrimaryBorder() {
        BorderSide.allCases.forEach {
            textField.addBorder(side: $0, color: Constants.primaryColor, width: 1.0)
        }
    }
    @objc private func textFieldEditingDidEnd(_ textField: UITextField) {
        formInputDelegate?.textFieldEditingDidEnd(textField)
    }
    @objc private func handleDatePicker(_ sender: UIDatePicker) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 MM월 dd일"
        formatter.locale = Locale(identifier: "ko_KR")
        textField.text = formatter.string(from: datePicker.date)
    }
    
    @objc private func didTappedOkButton() {
        textField.resignFirstResponder()
    }
}

extension FormInput: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.backgroundColor = .clear
        textField.removeRedBorder()
        addPrimaryBorder()
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.backgroundColor = #colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        textField.removeFocusedBorder()
    }
}

