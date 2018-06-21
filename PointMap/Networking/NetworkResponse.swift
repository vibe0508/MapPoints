//
//  NetworkResponse.swift
//  PointMap
//
//  Created by Вячеслав Бельтюков on 21/06/2018.
//  Copyright © 2018 Vyacheslav Beltyukov. All rights reserved.
//

import Foundation

struct NetworkResponse<T> {
    let headers: [String: String]
    let data: T
}
