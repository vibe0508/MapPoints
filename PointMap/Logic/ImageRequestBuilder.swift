//
//  ImageRequestBuilder.swift
//  PointMap
//
//  Created by Вячеслав Бельтюков on 22/06/2018.
//  Copyright © 2018 Vyacheslav Beltyukov. All rights reserved.
//

import Foundation

enum ImageRequestBuilder: RequestBuilder {
    case check(filename: String)
    case load(filename: String)

    var baseUrl: URL {
        return Configuration.Networking.contentBaseUrl
    }

    var path: String {
        switch self {
        case .check(let filename), .load(let filename):
            return filename
        }
    }

    var method: HTTPMethod {
        switch self {
        case .check:
            return .head
        case .load:
            return .get
        }
    }
}
