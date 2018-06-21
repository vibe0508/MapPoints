//
//  Point.swift
//  PointMap
//
//  Created by Вячеслав Бельтюков on 21/06/2018.
//  Copyright © 2018 Vyacheslav Beltyukov. All rights reserved.
//

import CoreData
import CoreLocation

class Point: NSManagedObject {

    @NSManaged var id: String?
    @NSManaged var partnerId: String?
    @NSManaged private var t_coordinate: Data?

    var coordinate: CLLocationCoordinate2D? {
        set {
            t_coordinate = newValue?.serialize()
        }
        get {
            return t_coordinate.flatMap { CLLocationCoordinate2D(data: $0) }
        }
    }
}
