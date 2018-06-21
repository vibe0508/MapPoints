//
//  Configuration.swift
//  PointMap
//
//  Created by Вячеслав Бельтюков on 21/06/2018.
//  Copyright © 2018 Vyacheslav Beltyukov. All rights reserved.
//

import Foundation

struct Configuration {
    struct Networking {
        static let baseUrl = URL(string: "")!
    }
    struct Map {
        static let defaultMapRadius: Double = 1
    }
    struct Storage {
        static let modelUrl = Bundle.main.url(forResource: "PointMap", withExtension: "momd")!
        static let storeFilename = "PointMap.sqlite"
    }
}
