//
//  RootViewController.swift
//  AuthPro
//
//  Created by 이주상 on 2023/04/17.
//

import UIKit
import SnapKit
import GoogleSignIn
import FirebaseAuth
import FirebaseCore
import AuthenticationServices
import CryptoKit
import KakaoSDKAuth
import KakaoSDKUser
import NaverThirdPartyLogin
import Alamofire

final class RootViewController: UIViewController {
    
    private lazy var googleButton = SocialLoginButton(provider: .google)
    private lazy var appleButton = SocialLoginButton(provider: .apple)
    private lazy var kakaoButton = SocialLoginButton(provider: .kakao)
    private lazy var naverButton = SocialLoginButton(provider: .naver)
    private lazy var loginButton = SubmitButton(type: .login, isEnabled: true)
    private lazy var signupButton = SubmitButton(type: .signup, isEnabled: true)
    
    private lazy var loginSignupStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [loginButton, signupButton])
        stackView.spacing = 16.0
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        return stackView
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [googleButton, appleButton, kakaoButton, naverButton, loginSignupStackView])
        stackView.spacing = 16.0
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        return stackView
    }()
    
    fileprivate var currentNonce: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationTitle()
        setupViews()
        setupDelegates()
        setupGoogleConfig()
    }
}

extension RootViewController {
    private func setupViews() {
        view.addSubview(stackView)
        
        [googleButton, appleButton, kakaoButton, naverButton, loginSignupStackView].forEach {
            $0.snp.makeConstraints { constraintMaker in
                constraintMaker.height.equalTo(50)
            }
        }
        
        stackView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.centerY.equalToSuperview()
        }
    }
    
    private func setupDelegates() {
        googleButton.delegate = self
        appleButton.delegate = self
        kakaoButton.delegate = self
        naverButton.delegate = self
        loginButton.delegate = self
        signupButton.delegate = self
    }
}

extension RootViewController: SocialLoginButtonDelegate {
    func didTappedSocialLoginButton(provider: Provider) {
        switch provider {
        case .google:
            googleLogin()
        case .apple:
            appleLogin()
        case .kakao:
            kakaoLogin()
        case .naver:
            naverLogin()
        }
    }
}

extension RootViewController: SubmitButtonDelegate {
    func didTappedSubmitButton(type: SubmitButtonType) {
        switch type {
        case .login:
            let LoginViewController = LoginViewController()
            navigationController?.pushViewController(LoginViewController, animated: false)
        case .signup:
            let SignupViewController = SignupViewController()
            navigationController?.pushViewController(SignupViewController, animated: false)
        case .logout:
            break
        }
    }
}
// MARK: - Google Sign in
extension RootViewController {
    private func setupGoogleConfig() {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
    }
    
    private func googleLogin() {
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [unowned self] result, error in
            guard error == nil else {
                print("구글 로그인 에러")
                navigationController?.popToRootViewController(animated: true)
                return
            }
            
            guard let user = result?.user, let idToken = user.idToken?.tokenString else {
                print("유저 정보 및 토큰 에러")
                navigationController?.popToRootViewController(animated: true)
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: user.accessToken.tokenString)
            Auth.auth().signIn(with: credential) { _, error in
                if let error = error {
                    self.messageAlert(message: error.localizedDescription)
                    return
                }
                let id = user.profile?.name ?? "구글 유저"
                let imageURL = user.profile?.imageURL(withDimension: 120)
                self.pushToProfileViewController(id: id, imageURL: imageURL)
            }
        }
    }
}

// MARK: - Apple Sign in
extension RootViewController {
    @available(iOS 13, *)
    func appleLogin() {
        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    @available(iOS 13, *)
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            return String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
    
    // Adapted from https://auth0.com/docs/api-auth/tutorials/nonce#generate-a-cryptographically-random-nonce
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError(
                        "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
                    )
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }
}

@available(iOS 13.0, *)
extension RootViewController: ASAuthorizationControllerDelegate {
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            // Initialize a Firebase credential, including the user's full name.
            let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: nonce)
            
            // Sign in with Firebase.
            Auth.auth().signIn(with: credential) { [unowned self](authResult, error) in
                if (error != nil) {
                    self.messageAlert(message: error?.localizedDescription ?? "파이어베이스 에러")
                    return
                }
                let id = "애플 유저"
                self.pushToProfileViewController(id: id)
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("Sign in with Apple errored: \(error)")
    }
    
}

extension RootViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}
// MARK: - kakao Sign in
extension RootViewController {
    private func kakaoSigninNormally() {
        if UserApi.isKakaoTalkLoginAvailable() { // 간편 로그인: 카카오톡으로 로그인
            UserApi.shared.loginWithKakaoTalk { [unowned self] _, error in
                if error != nil {
                    print(error?.localizedDescription ?? "로그인 에러")
                } else { // 로그인 성공, userId 발급
                    UserApi.shared.me(completion: { user, error in
                        guard let user = user
                        else {
                            print(error?.localizedDescription ?? "로그인 에러")
                            return
                        }
                        let nickname = user.kakaoAccount?.name ?? "카카오 유저"
                        let imageUrl = user.kakaoAccount?.profile?.thumbnailImageUrl
                        self.pushToProfileViewController(id: nickname, imageURL: imageUrl)
                    })
                }
            }
        } else { // 카카오톡 설치 안되어 있을때 카카오계정으로 로그인
            UserApi.shared.loginWithKakaoAccount { _, error in
                if error != nil {
                    print(error?.localizedDescription ?? "로그인 에러")
                } else { // 로그인 성공, userId 발급
                    UserApi.shared.me(completion: { user, error in
                        guard let user = user
                        else {
                            print(error?.localizedDescription ?? "로그인 에러")
                            return
                        }
                        let nickname = user.kakaoAccount?.profile?.nickname ?? "카카오 유저"
                        let imageUrl = user.kakaoAccount?.profile?.thumbnailImageUrl
                        self.pushToProfileViewController(id: nickname, imageURL: imageUrl)
                    })
                }
            }
        }
    }
    
    private func kakaoLogin() {
        if (AuthApi.hasToken()) { // 토큰이 있으면
            UserApi.shared.accessTokenInfo { [unowned self] _, error in
                if let error = error { // 토큰 만료
                    print("토큰 만료: ", error.localizedDescription)
                } else {
                    self.kakaoSigninNormally()
                }
            }
        } else { // 토큰이 없으면
            kakaoSigninNormally()
        }
    }
}
// MARK: - naver Sign in
extension RootViewController {
    private func naverLogin() {
        let loginInstance = NaverThirdPartyLoginConnection.getSharedInstance()
        loginInstance?.delegate = self
        loginInstance?.requestThirdPartyLogin()
        
    }
    private func getNaverUserInfo() {
        let loginInstance = NaverThirdPartyLoginConnection.getSharedInstance()
        guard let isValidAccessToken = loginInstance?.isValidAccessTokenExpireTimeNow() else { return }
        
        if !isValidAccessToken {
            return
        }
        guard let tokenType = loginInstance?.tokenType else { return }
        guard let accessToken = loginInstance?.accessToken else { return }
        let url = URL(string: "https://openapi.naver.com/v1/nid/me")!
        let authorization = "\(tokenType) \(accessToken)"
        
        AF.request(url, method: .get, parameters: nil, headers: ["Authorization": authorization]).responseDecodable(of: NaverInfoResponseModel.self) { [unowned self] response in
            switch response.result {
            case let .success(result):
                let id = result.response.nickname
                let imageURL = URL(string: result.response.profileImage)
                self.pushToProfileViewController(id: id, imageURL: imageURL)
            case let .failure(error):
                print("naver-info-api fetch error: ", error)
                self.pushToProfileViewController(id: "네이버 유저")
            }
        }
        .resume()
    }
}

extension RootViewController: NaverThirdPartyLoginConnectionDelegate {
    // 로그인 버튼을 눌렀을 경우 열게 될 브라우저
    func oauth20ConnectionDidOpenInAppBrowser(forOAuth request: URLRequest!) {
        
    }
    
    // 로그인에 성공했을 경우 호출
    func oauth20ConnectionDidFinishRequestACTokenWithAuthCode() {
        print("[Success] : Success Naver Login")
        getNaverUserInfo()
    }
    
    // 접근 토큰 갱신
    func oauth20ConnectionDidFinishRequestACTokenWithRefreshToken() {
        
    }
    
    // 로그아웃 할 경우 호출(토큰 삭제)
    func oauth20ConnectionDidFinishDeleteToken() {
        NaverThirdPartyLoginConnection.getSharedInstance()?.requestDeleteToken()
    }
    
    // 모든 Error
    func oauth20Connection(_ oauthConnection: NaverThirdPartyLoginConnection!, didFailWithError error: Error!) {
        print("[Error] :", error.localizedDescription)
    }
    
}
