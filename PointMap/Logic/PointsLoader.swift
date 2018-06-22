//
//  PointsLoader.swift
//  PointMap
//
//  Created by Вячеслав Бельтюков on 21/06/2018.
//  Copyright © 2018 Vyacheslav Beltyukov. All rights reserved.
//

import Foundation
import CoreData
import CoreLocation

private let lastPartnersLoadKey = "lastPartnersLoadKey"

class PointsLoader {
    private let network: NetworkManager = .shared
    private let cacheValidator: CacheValidator = CacheValidator()
    private let pointsSyncer: PointsSyncer = PointsSyncer()

    func loadPoints(at coordinate: CLLocationCoordinate2D, radius: Double) {
        DispatchQueue.global(qos: .background).async {
            self._loadPoints(at: coordinate, radius: radius)
        }
    }

    private func _loadPoints(at coordinate: CLLocationCoordinate2D, radius: Double, retryCount: Int = 0) {
        guard !cacheValidator.validCacheExists(for: coordinate, with: radius),
            retryCount < Configuration.Policies.maxRetryCount else {
            return
        }

        let requestBuilder = APIRouter.points(latitude: coordinate.latitude,
                                              longitude: coordinate.longitude,
                                              radius: Int(radius))

        typealias PointsResponse = NetworkResponse<APIModel.Container<[APIModel.Point]>>

        network.performRequest(with: requestBuilder, success: { [weak self] (response: PointsResponse) in
            self?.pointsSyncer.syncPoints(with: response.data.payload, in: radius, at: coordinate)
            self?.cacheValidator.markAreaCached(coordinate: coordinate, radius: radius)
        }, failure: { [weak self] error in
            print("Loading points failed due to error: \(error)")
            self?._loadPoints(at: coordinate, radius: radius, retryCount: retryCount + 1)
        })
    }
}
