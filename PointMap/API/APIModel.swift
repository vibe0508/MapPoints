//
//  APIModel.swift
//  PointMap
//
//  Created by Вячеслав Бельтюков on 22/06/2018.
//  Copyright © 2018 Vyacheslav Beltyukov. All rights reserved.
//

import Foundation

struct APIModel {
    struct Container<T: Decodable>: Decodable {
        let payload: T
    }
    struct Coordinate: Decodable {
        let latitude: Double
        let longitude: Double
    }
    struct Point: Decodable {
        let location: Coordinate
        let externalId: String
        let partnerName: String?
    }
    struct Partner {
        let id: String
        let picture: String
    }
}
