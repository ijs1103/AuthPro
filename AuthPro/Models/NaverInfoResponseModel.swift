//
//  NaverInfoResponseModel.swift
//  AuthPro
//
//  Created by 이주상 on 2023/04/21.
//

import Foundation

struct NaverInfoResponseModel: Codable {
    let resultcode, message: String
    let response: Response
}

struct Response: Codable {
    let nickname: String
    let profileImage: String
    let id: String

    enum CodingKeys: String, CodingKey {
        case nickname
        case profileImage = "profile_image"
        case id
    }
}
