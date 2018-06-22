//
//  Annotation.swift
//  PointMap
//
//  Created by Вячеслав Бельтюков on 21/06/2018.
//  Copyright © 2018 Vyacheslav Beltyukov. All rights reserved.
//

import MapKit

class Annotation: NSObject, MKAnnotation {
    let coordinate: CLLocationCoordinate2D
    let imageName: String?

    init(coordinate: CLLocationCoordinate2D, imageName: String?) {
        self.coordinate = coordinate
        self.imageName = imageName
        super.init()
    }

    override var hash: Int {
        return coordinate.latitude.hashValue ^ coordinate.longitude.hashValue
    }
}
