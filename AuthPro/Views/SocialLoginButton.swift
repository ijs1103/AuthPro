//
//  SocialLoginButton.swift
//  AuthPro
//
//  Created by 이주상 on 2023/04/17.
//
import SnapKit
import UIKit

enum Provider {
    case apple
    case google
    case kakao
    case naver
    var buttonTitle: String {
        switch self {
        case .apple:
            return "Apple로 로그인"
        case .google:
            return "Google로 로그인"
        case .kakao:
            return "Kakao로 로그인"
        case .naver:
            return "Naver로 로그인"
        }
    }
    var buttonImageName: String {
        switch self {
        case .apple:
            return "logo_apple"
        case .google:
            return "logo_google"
        case .kakao:
            return "logo_kakao"
        case .naver:
            return "logo_naver"
        }
    }
    var buttonBgColor: UIColor {
        switch self {
        case .apple:
            return .systemOrange
        case .google:
            return .systemBlue
        case .kakao:
            return .systemYellow
        case .naver:
            return .systemGreen
        }
    }
}

protocol SocialLoginButtonDelegate: AnyObject {
    func didTappedSocialLoginButton(provider: Provider)
}

final class SocialLoginButton: UIView {
    weak var delegate: SocialLoginButtonDelegate?
    
    let provider: Provider
    
    private let text: String
    
    private let imageName: String
    
    private lazy var buttonimageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: imageName)
        imageView.isUserInteractionEnabled = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private lazy var buttonTitleLabel: UILabel = {
        let uiLabel = UILabel()
        uiLabel.text = text
        uiLabel.font = .systemFont(ofSize: 18.0, weight: .bold)
        uiLabel.textColor = .systemGray4
        return uiLabel
    }()
    
    init(provider: Provider) {
        self.text = provider.buttonTitle
        self.imageName = provider.buttonImageName
        self.provider = provider
        super.init(frame: .zero)
        self.backgroundColor = provider.buttonBgColor
        setupViews()
        setupGesture()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
extension SocialLoginButton {
    private func setupGesture() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTappedSocialLoginButton))
        self.addGestureRecognizer(tapGestureRecognizer)
    }
    
    private func setupViews() {
                
        [buttonimageView, buttonTitleLabel].forEach {
            addSubview($0)
        }
        
        buttonimageView.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(20)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(40)
        }
        
        buttonTitleLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
    
    @objc func didTappedSocialLoginButton() {
        delegate?.didTappedSocialLoginButton(provider: provider)
    }
}
