//
//  CLLocationCoordinate2D+Serialize.swift
//  PointMap
//
//  Created by Вячеслав Бельтюков on 21/06/2018.
//  Copyright © 2018 Vyacheslav Beltyukov. All rights reserved.
//

import CoreLocation

extension CLLocationCoordinate2D {
    init?(data: Data) {
        guard data.count == MemoryLayout<CLLocationCoordinate2D>.size else {
            return nil
        }
        self = (data as NSData).bytes.load(as: CLLocationCoordinate2D.self)
    }

    func serialize() -> Data {
        var copy = self
        return Data(bytes: &copy, count: MemoryLayout<CLLocationCoordinate2D>.size)
    }
    
}
