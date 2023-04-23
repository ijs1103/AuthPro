//
//  SignupViewController.swift
//  AuthPro
//
//  Created by 이주상 on 2023/04/21.
//

import UIKit
import FirebaseAuth

class SignupViewController: UIViewController {
    
    private lazy var emailInput = FormInput(formType: .id)
    
    private lazy var pwInput = FormInput(formType: .password)
    
    private lazy var pwCheckInput = FormInput(formType: .passwordCheck)
    
    private lazy var birthInput = FormInput(formType: .birth) //🌟 할것 : 피커뷰 붙이기

    private lazy var signupButton = SubmitButton(type: .signup)
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [emailInput, pwInput, pwCheckInput, birthInput, signupButton])
        stackView.spacing = 16.0
        stackView.axis = .vertical
        stackView.alignment = .fill
        return stackView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationTitle()
        setupNavigationItem()
        setupViews()
        setupDelegates()
    }

}

extension SignupViewController {
    private func setupNavigationItem() {
        navigationItem.backButtonTitle = nil
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true) //textField 제외한 영역 누르면 키보드 끄기
    }
    private func setupViews() {
        view.addSubview(stackView)
        
        signupButton.snp.makeConstraints {
            $0.height.equalTo(40)
        }
        
        stackView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.centerY.equalToSuperview()
        }
        //스택뷰 내에서 커스텀하게 spacing 설정
        stackView.setCustomSpacing(48.0, after: birthInput)
    }
    private func setupDelegates() {
        emailInput.formInputDelegate = self
        pwInput.formInputDelegate = self
        pwCheckInput.formInputDelegate = self
        birthInput.formInputDelegate = self
        signupButton.delegate = self
    }
    private func pushToLoginViewController(id: String) {
        navigationController?.popViewController(animated: true)
        let loginViewController = LoginViewController(id: id)
        navigationController?.pushViewController(loginViewController, animated: false)        
    }
}

extension SignupViewController: FormInputDelegate {
    func textFieldEditingDidEnd(_ textField: UITextField) {
        // extraCheck: 비밀번호와 비밀번호체크 같은지 검사
        formValidCheck(textField: textField, button: signupButton, formInputArr: [emailInput, pwInput, pwCheckInput, birthInput], extraCheck: { [unowned self] in

            if self.pwInput.textField.text == self.pwCheckInput.textField.text {
                self.pwCheckInput.errorLabel.text = ""
                self.pwCheckInput.errorLabel.isHidden = true
                return true
            } else {
                self.pwCheckInput.errorLabel.text = Constants.errMsg.invalidPwCheck
                self.pwCheckInput.errorLabel.isHidden = false
                return false
            }
        })
    }
}

extension SignupViewController: SubmitButtonDelegate {
    func didTappedSubmitButton(type: SubmitButtonType) {
        guard let email = emailInput.textField.text
                , let password = pwInput.textField.text else { return }
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] _, error in
            guard let self = self else { return }
            if let error = error {
                let code = (error as NSError).code
                switch code {
                case 17007: //이미 가입한 계정일 때
                    self.messageAlert(message: "이미 가입한 계정입니다.")
                default:
                    self.messageAlert(message: error.localizedDescription)
                }
            } else {
                self.messageAlert(message: "회원가입 성공. 로그인 화면으로 이동합니다.") {
                    self.pushToLoginViewController(id: email)
                }
            }
        }
    }
}
