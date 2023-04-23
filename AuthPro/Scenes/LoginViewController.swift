//
//  LoginViewController.swift
//  AuthPro
//
//  Created by 이주상 on 2023/04/17.
//

import UIKit
import SnapKit
import FirebaseAuth

final class LoginViewController: UIViewController {
    
    private lazy var idInput = FormInput(formType: .id)
    
    private lazy var pwInput = FormInput(formType: .password)
    
    private lazy var signUpLabel: UILabel = {
        let label = UILabel()
        label.text = "회원가입 하러가기"
        label.textColor = Constants.primaryColor
        label.font = UIFont.systemFont(ofSize: 18)
        label.isUserInteractionEnabled = true
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTappedSignUpLabel))
        label.addGestureRecognizer(tapGestureRecognizer)
        return label
    }()
    
    private lazy var loginButton = SubmitButton(type: .login)
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [idInput, pwInput, signUpLabel, loginButton])
        stackView.spacing = 32.0
        stackView.axis = .vertical
        stackView.alignment = .fill
        return stackView
    }()
    
    init(id: String? = nil) {
        super.init(nibName: nil, bundle: nil)
        self.idInput.textField.text = id
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationTitle()
        setupNavigationItem()
        setupViews()
        setupDelegates()
    }
}

extension LoginViewController {
    private func setupViews() {
        view.addSubview(stackView)
        
        loginButton.snp.makeConstraints {
            $0.height.equalTo(40)
        }
        
        stackView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.centerY.equalToSuperview()
        }
    }
    private func setupNavigationItem() {
        navigationItem.backButtonTitle = nil
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true) //textField 제외한 영역 누르면 키보드 끄기
    }
    
    @objc func didTappedSignUpLabel() {
        navigationController?.popViewController(animated: true)
        let signupViewController = SignupViewController()
        navigationController?.pushViewController(signupViewController, animated: false)
    }
    private func setupDelegates() {
        idInput.formInputDelegate = self
        pwInput.formInputDelegate = self
        loginButton.delegate = self
    }
    
    private func login(withEmail email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) {[weak self] _, error in
            guard let self = self else { return }
            if let error = error {
                self.messageAlert(message: error.localizedDescription)
            } else {
                self.messageAlert(message: "로그인 성공") {
                    self.pushToProfileViewController(id: email)
                }
            }
        }
    }
}

extension LoginViewController: FormInputDelegate {
    func textFieldEditingDidEnd(_ textField: UITextField) {
        formValidCheck(textField: textField, button: loginButton, formInputArr: [idInput, pwInput])
    }
}

extension LoginViewController: SubmitButtonDelegate {
    func didTappedSubmitButton(type: SubmitButtonType) {
        let email = idInput.textField.text ?? ""
        let password = pwInput.textField.text ?? ""
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] _, error in
            guard let self = self else { return }
            if let error = error {
                let code = (error as NSError).code
                switch code {
                case 17007: //이미 가입한 계정일 때
                    self.login(withEmail: email, password: password)
                default:
                    self.messageAlert(message: error.localizedDescription)
                }
            } else {
                self.messageAlert(message: "로그인 성공") {
                    self.pushToProfileViewController(id: email)
                }
            }
        }
    }
}

















