//
//  ProfileViewController.swift
//  AuthPro
//
//  Created by 이주상 on 2023/04/19.
//

import UIKit
import SnapKit
import FirebaseAuth
import Kingfisher
import KakaoSDKUser
import KakaoSDKAuth
import NaverThirdPartyLogin

final class ProfileViewController:UIViewController {
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.borderWidth = 4
        imageView.layer.borderColor = Constants.primaryColor.cgColor
        imageView.layer.cornerRadius = 60
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private lazy var idLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 18)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var logoutButton = SubmitButton(type: .logout, isEnabled: true)
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [imageView, idLabel, logoutButton])
        stackView.spacing = 20.0
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        return stackView
    }()

    func updateProfile(id: String, imageURL: URL? = nil) {
        self.imageView.kf.setImage(with: imageURL, placeholder: UIImage(systemName: "person.fill"))
        self.idLabel.text = id
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()
        setupViews()
        setupDelegates()
    }
}

extension ProfileViewController {
    private func setupNavigation() {
        navigationItem.hidesBackButton = true
        navigationItem.title = "프로필"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    private func setupViews() {
        imageView.snp.makeConstraints {
            $0.width.height.equalTo(120)
        }
        logoutButton.snp.makeConstraints {
            $0.width.equalTo(200)
        }
        [stackView].forEach {
            view.addSubview($0)
        }
        stackView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            $0.centerX.equalToSuperview()
        }
    }
    private func setupDelegates() {
        logoutButton.delegate = self
    }
    private func firebaseLogout() {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            messageAlert(message: signOutError.localizedDescription)
        }
    }
    private func kakaoLogout() {
        UserApi.shared.logout {(error) in
            if let error = error {
                print("카카오 로그아웃 실패", error.localizedDescription)
            }
        }
    }
    private func naverLogout() {
        let loginInstance = NaverThirdPartyLoginConnection.getSharedInstance()
        loginInstance?.requestDeleteToken()
    }
}

extension ProfileViewController: SubmitButtonDelegate {
    func didTappedSubmitButton(type: SubmitButtonType) {
        // 카카오 accessToken이 존재하면
        if AuthApi.hasToken() {
            print("카카오 로그아웃")
            kakaoLogout()
        }
        // 파이어베이스로 로그인한 유저가 존재하면
        if Auth.auth().currentUser != nil {
            print("파이어베이스 로그아웃")
            firebaseLogout()
        }
        // 네이버 accessToken이 존재하면
        if ((NaverThirdPartyLoginConnection.getSharedInstance()?.accessToken) != nil) {
            print("네이버 로그아웃")
            naverLogout()
        }
        navigationController?.popToRootViewController(animated: true)
    }
}
