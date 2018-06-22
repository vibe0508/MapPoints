//
//  CacheValidator.swift
//  PointMap
//
//  Created by Вячеслав Бельтюков on 22/06/2018.
//  Copyright © 2018 Vyacheslav Beltyukov. All rights reserved.
//

import Foundation
import CoreData
import CoreLocation

private let lastLoadPartnersKey = "lastLoadPartnersKey"

class CacheValidator {

    let locationHelper = LocationHelper()

    private let managedObjectContext: NSManagedObjectContext = CoreDataStack.shared.generatePrivateContext()

    func validCacheExists(for coordinate: CLLocationCoordinate2D, with radius: Double) -> Bool {
        let areas = getValidAreas(for: coordinate, with: radius)
        return check(areas, coverCircleWith: coordinate, and: radius)
    }

    func markAreaCached(coordinate: CLLocationCoordinate2D, radius: Double) {
        managedObjectContext.perform { [unowned self] in
            let newArea = LoadedArea(context: self.managedObjectContext)
            newArea.center = coordinate
            newArea.radius = radius
            newArea.dateLoaded = Date()
            try? self.managedObjectContext.save()
        }
    }

    func markLoadedPartners() {
        UserDefaults.standard.set(Date().timeIntervalSince1970 as NSNumber,
                                  forKey: lastLoadPartnersKey)
        UserDefaults.standard.synchronize()
    }

    func validPartnersCacheExists() -> Bool {
        guard let timeInterval = (UserDefaults.standard
            .object(forKey: lastLoadPartnersKey) as? NSNumber)?.doubleValue else {
                return false
        }
        return Date(timeIntervalSince1970: timeInterval).timeIntervalSinceNow > -Configuration.Policies.allowedCacheAge
    }

    private func getValidAreas(for coordinate: CLLocationCoordinate2D, with radius: Double) -> [LoadedArea] {
        let fetchRequest = NSFetchRequest<LoadedArea>()
        fetchRequest.entity = LoadedArea.entity()
        let centerA = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let borderlineDate = NSDate(timeIntervalSinceNow: -Configuration.Policies.allowedCacheAge)
        fetchRequest.predicate = NSPredicate(format: "dateLoaded > %@", borderlineDate)

        let group = DispatchGroup()
        var results: [LoadedArea] = []
        group.enter()
        managedObjectContext.perform {
            defer { group.leave() }
            do {
                try results = fetchRequest.execute().filter { area -> Bool in
                    guard let areaRadius = area.radius,
                        let center = area.center else {
                            return false
                    }
                    let centerB = CLLocation(latitude: center.latitude, longitude: center.longitude)
                    return centerA.distance(from: centerB) < (radius + areaRadius)
                }
            } catch {}
        }

        group.wait()
        return results
    }

    private func check(_ areas: [LoadedArea], coverCircleWith center: CLLocationCoordinate2D, and radius: Double) -> Bool {
        let span = locationHelper.span(for: radius, at: center)
        let singleSpan = locationHelper.span(for: Configuration.Policies.cacheProbeDensity,
                                             at: center)
        let latitudeProbesCount = Int(span.latitudeDelta / singleSpan.latitudeDelta)
        let longitudeProbesCount = Int(span.longitudeDelta / singleSpan.longitudeDelta)
        let startLatitude = center.latitude - span.latitudeDelta / 2
        let startLongitude = center.longitude - span.longitudeDelta / 2
        var probes: [[(CLLocationCoordinate2D, Bool)]] = (0..<latitudeProbesCount).map { latIndex in
            let latitude = startLatitude + singleSpan.latitudeDelta * Double(latIndex)
            return (0..<longitudeProbesCount).map { longIndex in
                let longitude = startLongitude + singleSpan.longitudeDelta * Double(longIndex)
                return (CLLocationCoordinate2D(latitude: latitude, longitude: longitude), false)
            }
        }

        areas.forEach { area in
            guard let center = area.center, let radius = area.radius else {
                return
            }
            let region = CLCircularRegion(center: center, radius: radius, identifier: "")
            probes = probes.map {
                $0.map {
                    guard !$0.1 else {
                        return $0
                    }
                    return ($0.0, region.contains($0.0))
                }
            }
        }

        let region = CLCircularRegion(center: center, radius: radius, identifier: "")

        var covers = true
        var i = 0
        while covers && i < probes.count {
            let subprobes = probes[i]
            var j = 0
            while covers && j < subprobes.count {
                defer { j += 1 }
                let value = subprobes[j]
                guard region.contains(value.0) else {
                    continue
                }
                covers = covers && value.1
            }
            i += 1
        }

        return covers
    }
}
