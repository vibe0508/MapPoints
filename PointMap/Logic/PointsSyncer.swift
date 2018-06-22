//
//  PointsSyncer.swift
//  PointMap
//
//  Created by Вячеслав Бельтюков on 22/06/2018.
//  Copyright © 2018 Vyacheslav Beltyukov. All rights reserved.
//

import Foundation
import CoreLocation
import CoreData

class PointsSyncer {

    private let locationHelper = LocationHelper()
    private let managedObjectContext = CoreDataStack.shared.generatePrivateContext()

    func syncPoints(with loadedPoints: [APIModel.Point], in radius: Double, at coordinate: CLLocationCoordinate2D) {
        managedObjectContext.perform { [unowned self] in
            let region = CLCircularRegion(center: coordinate, radius: radius, identifier: "")
            do {
                var storedPoints = try self.getAllPoints().filter { point in
                    guard let coordinate = point.coordinate else {
                        return false
                    }
                    return region.contains(coordinate)
                }
                storedPoints += self.add(loadedPoints, notIn: storedPoints)
                self.update(storedPoints, with: loadedPoints)
                self.deletePoints(from: storedPoints, notIn: loadedPoints)
                try self.managedObjectContext.save()
            } catch {}
        }
    }

    func syncLogos(with loadedPartners: [APIModel.Partner]) {
        managedObjectContext.perform { [unowned self] in
            do {
                var storedLogos = try self.getAllLogos()
                storedLogos += self.add(loadedPartners, notIn: storedLogos)
                self.update(storedLogos, with: loadedPartners)
                self.delete(storedLogos, notIn: loadedPartners)
                try self.managedObjectContext.save()
            } catch {}
        }
    }

    func applyLogosToPoints() {
        managedObjectContext.perform { [unowned self] in
            do {
                var logoById: [String: PartnerLogo] = [:]
                try self.getAllLogos().forEach {
                    guard let id = $0.partnerId else {
                        return
                    }
                    logoById[id] = $0
                }

                try self.getAllPoints(with: NSPredicate(format: "logo == nil")).forEach {
                    $0.logo = logoById[$0.partnerId ?? ""]
                }

                try self.managedObjectContext.save()
            } catch {}
        }
    }

    private func deletePoints(from storedPoints: [Point], notIn loadedPoints: [APIModel.Point]) {
        storedPoints.filter { point in
            return !loadedPoints.contains(where: { $0.externalId == point.id })
        }.forEach {
            managedObjectContext.delete($0)
        }
    }

    private func update(_ storedPoints: [Point], with loadedPoints: [APIModel.Point]) {
        storedPoints.forEach { point in
            guard let loadedPoint = loadedPoints.first(where: { $0.externalId == point.id }) else {
                return
            }
            point.coordinate = CLLocationCoordinate2D(latitude: loadedPoint.location.latitude,
                                                      longitude: loadedPoint.location.longitude)
            point.partnerId = loadedPoint.partnerName
        }
    }

    private func add(_ loadedPoints: [APIModel.Point], notIn storedPoints: [Point]) -> [Point] {
        return loadedPoints.filter { loadedPoint in
            return !storedPoints.contains(where: { loadedPoint.externalId == $0.id })
        }.map {
            let point = Point(context: managedObjectContext)
            point.id = $0.externalId
            return point
        }
    }

    private func delete(_ storedLogos: [PartnerLogo], notIn loadedPartners: [APIModel.Partner]) {
        storedLogos.filter { logo in
            return !loadedPartners.contains(where: { $0.id == logo.partnerId })
        }.forEach {
            managedObjectContext.delete($0)
        }
    }

    private func update(_ storedLogos: [PartnerLogo], with loadedPartners: [APIModel.Partner]) {
        storedLogos.forEach { logo in
            guard let loadedPartner = loadedPartners.first(where: { $0.id == logo.partnerId }) else {
                return
            }
            logo.filename = loadedPartner.picture
        }
    }

    private func add(_ loadedPartners: [APIModel.Partner], notIn storedLogos: [PartnerLogo]) -> [PartnerLogo] {
        return loadedPartners.filter { loadedPartner in
            return !storedLogos.contains(where: { loadedPartner.id == $0.partnerId })
        }.map {
            let logo = PartnerLogo(context: managedObjectContext)
            logo.partnerId = $0.id
            return logo
        }
    }

    private func getAllLogos() throws -> [PartnerLogo] {
        let fetchRequest = NSFetchRequest<PartnerLogo>()
        fetchRequest.entity = PartnerLogo.entity()
        return try fetchRequest.execute()
    }

    private func getAllPoints(with predicate: NSPredicate? = nil) throws -> [Point] {
        let fetchRequest = NSFetchRequest<Point>()
        fetchRequest.entity = Point.entity()
        fetchRequest.predicate = predicate
        return try fetchRequest.execute()
    }
}
