//
//  RequestBuilder.swift
//  PointMap
//
//  Created by Вячеслав Бельтюков on 21/06/2018.
//  Copyright © 2018 Vyacheslav Beltyukov. All rights reserved.
//

import Foundation

enum HTTPMethod: String {
    case get = "GET"
    case head = "HEAD"
}

protocol RequestBuilder {
    var baseUrl: URL { get }
    var method: HTTPMethod { get }
    var path: String { get }
    var parameters: [String: Any] { get }

    var request: URLRequest { get }
}

extension RequestBuilder {
    var baseUrl: URL {
        return Configuration.Networking.baseUrl
    }
    var method: HTTPMethod {
        return .get
    }
    var parameters: [String: Any] {
        return [:]
    }

    var request: URLRequest {
        let escapedPath = path.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)
        var urlString = baseUrl.appendingPathComponent(escapedPath ?? "").absoluteString
        if !parameters.isEmpty {
            let parametersString = "?\(parameters.map { "\($0.key)=\($0.value)" }.joined(separator: "&"))"
            urlString.append(parametersString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")
        }
        let url = URL(string: urlString)!
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue

        return request
    }
}
