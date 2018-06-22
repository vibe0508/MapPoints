//
//  APIRouter.swift
//  PointMap
//
//  Created by Вячеслав Бельтюков on 21/06/2018.
//  Copyright © 2018 Vyacheslav Beltyukov. All rights reserved.
//

import Foundation

enum APIRouter: RequestBuilder {
    //radius in meters
    case points(latitude: Double, longitude: Double, radius: Int)
    case partners

    var baseUrl: URL {
        return Configuration.Networking.apiBaseUrl
    }

    var path: String {
        switch self {
        case .points:
            return "deposition_points"
        case .partners:
            return "deposition_partners"
        }
    }

    var parameters: [String : Any] {
        switch self {
        case .points(let latitude, let longitude, let radius):
            return [
                "latitude": latitude,
                "longitude": longitude,
                "radius": radius
            ]
        case .partners:
            return ["accountType": "Credit"]
        }
    }
}
