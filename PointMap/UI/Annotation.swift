//
//  Annotation.swift
//  PointMap
//
//  Created by Вячеслав Бельтюков on 21/06/2018.
//  Copyright © 2018 Vyacheslav Beltyukov. All rights reserved.
//

import MapKit

class Annotation: NSObject, MKAnnotation {
    let id: String
    let coordinate: CLLocationCoordinate2D
    let partnerId: String?

    init(id: String, coordinate: CLLocationCoordinate2D, partnerId: String?) {
        self.id = id
        self.coordinate = coordinate
        self.partnerId = partnerId
        super.init()
    }

    override var hash: Int {
        return coordinate.latitude.hashValue ^ coordinate.longitude.hashValue
    }
}

extension Annotation {
    override var hashValue: Int {
        return hash
    }
    static func ==(l: Annotation, r: Annotation) -> Bool {
        return l.id == r.id
    }
}
