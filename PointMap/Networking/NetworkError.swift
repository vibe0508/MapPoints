//
//  NetworkError.swift
//  PointMap
//
//  Created by Вячеслав Бельтюков on 21/06/2018.
//  Copyright © 2018 Vyacheslav Beltyukov. All rights reserved.
//

import Foundation

enum NetworkError {
    case httpError(Int)
    case noConnection
    case timeout
    case mappingError(Error?)
    case unknown(Error?)
}
