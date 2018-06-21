//
//  LoadedArea.swift
//  PointMap
//
//  Created by Вячеслав Бельтюков on 21/06/2018.
//  Copyright © 2018 Vyacheslav Beltyukov. All rights reserved.
//

import CoreData
import CoreLocation

class LoadedArea: NSManagedObject {

    @NSManaged var dateLoaded: Date?
    @NSManaged private var t_center: Data?
    @NSManaged private var t_radius: NSNumber?

    var center: CLLocationCoordinate2D? {
        set {
            t_center = newValue?.serialize()
        }
        get {
            return t_center.flatMap { CLLocationCoordinate2D(data: $0) }
        }
    }

    var radius: Double? {
        set {
            t_radius = newValue as NSNumber?
        }
        get {
            return t_radius?.doubleValue
        }
    }
}
