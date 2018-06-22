//
//  LocationHelper.swift
//  PointMap
//
//  Created by Вячеслав Бельтюков on 21/06/2018.
//  Copyright © 2018 Vyacheslav Beltyukov. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit

class LocationHelper {

    private struct Constants {
        static let equatorLength = 40075.0 * 1000
    }

    //takes radius in m, assuming Earth is a sphere
    func span(for radius: Double, at point: CLLocationCoordinate2D) -> MKCoordinateSpan {
        let latRad = point.latitude * .pi / 180

        let latitudeDelta = (radius / Constants.equatorLength) * 180
        let longitudeDelta = (radius / (Constants.equatorLength * cos(latRad))) * 180

        return MKCoordinateSpan(latitudeDelta: latitudeDelta,
                                longitudeDelta: longitudeDelta)
    }
}
