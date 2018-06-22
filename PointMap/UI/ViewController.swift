//
//  ViewController.swift
//  PointMap
//
//  Created by Вячеслав Бельтюков on 21/06/2018.
//  Copyright © 2018 Vyacheslav Beltyukov. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController {

    @IBOutlet private weak var mapView: MKMapView!

    private let locationHelper = LocationHelper()
    private let annotationProvider = AnnotationProvider()
    private let locationManager = CLLocationManager()
    private let pointsLoader = PointsLoader()
    private let imageLoader = ImageLoader()

    private let imageAnnotationReuseId = "zxddc"
    private let annotationReuseId = "zxc"

    private var cachedImages: [String: UIImage] = [:]
    private var loadingImages: [String: [Annotation]] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()
        annotationProvider.consumer = self
        annotationProvider.start()
        locationManager.delegate = self
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if CLLocationManager.authorizationStatus() != .authorizedWhenInUse
            && CLLocationManager.authorizationStatus() != .authorizedAlways {
            locationManager.requestWhenInUseAuthorization()
        } else {
            locationManager.requestLocation()
        }
    }

    private func loadImage(for annotation: Annotation) {
        guard let partnerId = annotation.partnerId else {
            return
        }
        if let waitingList = loadingImages[partnerId] {
            loadingImages[partnerId] = waitingList + [annotation]
            return
        }
        loadingImages[partnerId] = []
        imageLoader.loadImage(with: partnerId) { [weak self] image in
            DispatchQueue.main.async {
                self?.cachedImages[partnerId] = image
                self?.loadingImages[partnerId]?.forEach {
                    self?.mapView.removeAnnotation($0)
                    self?.mapView.addAnnotation($0)
                }
                self?.loadingImages[partnerId] = nil
            }
        }
    }
}

// IB Actions

extension ViewController {
    @IBAction private func onPlusButton() {
        var region = mapView.region
        region.span.latitudeDelta /= Configuration.Map.zoomStep
        region.span.longitudeDelta /= Configuration.Map.zoomStep
        mapView.setRegion(region, animated: true)
    }

    @IBAction private func onMinusButton() {
        var region = mapView.region
        region.span.latitudeDelta *= Configuration.Map.zoomStep
        region.span.longitudeDelta *= Configuration.Map.zoomStep
        mapView.setRegion(region, animated: true)
    }

    @IBAction private func onLocButton() {
        locationManager.requestLocation()
    }
}

// Map view delegate

extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {

    }
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        pointsLoader.loadPoints(at: mapView.centerCoordinate,
                                radius: mapView.region.span.latitudeDelta * 55500)
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let image = cachedImages[(annotation as? Annotation)?.partnerId ?? ""] {
            let view = mapView.dequeueReusableAnnotationView(withIdentifier: imageAnnotationReuseId)
                ?? MKAnnotationView(annotation: annotation, reuseIdentifier: imageAnnotationReuseId)
            view.image = image
            return view
        }
        return nil

    }
}

// Annotation consumer
extension ViewController: AnnotationConsumer {
    func add(_ annotations: [Annotation]) {
        mapView.addAnnotations(annotations)

        annotations.forEach {
            if let partnerId = $0.partnerId, cachedImages[partnerId] == nil {
                loadImage(for: $0)
            }
        }
    }

    func removeAnnotation(with id: String) {
        guard let annotation = mapView.annotations
            .first(where: { ($0 as? Annotation)?.id == id }) else {
                return
        }
        mapView.removeAnnotation(annotation)
    }

    func reload(_ annotation: Annotation) {
        guard let oldAnnotation = mapView.annotations
            .first(where: { ($0 as? Annotation)?.id == annotation.id }) else {
                return
        }
        if let partnerId = annotation.partnerId, cachedImages[partnerId] == nil {
            loadImage(for: annotation)
        }
        mapView.removeAnnotation(oldAnnotation)
        mapView.addAnnotation(annotation)
    }
}

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            return
        }
        let coordinate = location.coordinate
        let span = locationHelper.span(for: Configuration.Map.defaultMapRadius,
                                       at: coordinate)
        mapView.region = MKCoordinateRegion(center: coordinate, span: span)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        guard status == .authorizedAlways || status == .authorizedWhenInUse else {
            return
        }
        locationManager.requestLocation()
    }
}
