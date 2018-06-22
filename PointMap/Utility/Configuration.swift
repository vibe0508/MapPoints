//
//  Configuration.swift
//  PointMap
//
//  Created by Вячеслав Бельтюков on 21/06/2018.
//  Copyright © 2018 Vyacheslav Beltyukov. All rights reserved.
//

import Foundation

struct Configuration {

    struct Policies {
        static let allowedCacheAge: TimeInterval = 3600 * 24
        static let cacheProbeDensity: Double = 50 //in meters
        static let maxRetryCount = 4
    }

    struct Networking {
        static let apiBaseUrl = URL(string: "https://api.tinkoff.ru/v1/")!
        static let contentBaseUrl = URL(string: "")!
    }
    struct Map {
        static let defaultMapRadius: Double = 1000
    }
    struct Storage {
        static let modelUrl = Bundle.main.url(forResource: "PointMap", withExtension: "momd")!
        static let storeFilename = "PointMap.sqlite"
    }
}
