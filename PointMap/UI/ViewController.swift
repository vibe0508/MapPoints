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

    private func setupMapView() {
//        mapView
    }
}

// IB Actions

extension ViewController {
    @IBAction private func onPlusButton() {

    }

    @IBAction private func onMinusButton() {

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
}

// Annotation consumer
extension ViewController: AnnotationConsumer {
    func add(_ annotations: [Annotation]) {
        mapView.addAnnotations(annotations)
    }

    func remove(_ annotation: Annotation) {
        mapView.removeAnnotation(annotation)
    }

    func reload(_ annotation: Annotation) {
//        mapView.
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
