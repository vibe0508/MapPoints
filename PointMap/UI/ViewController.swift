//
//  ViewController.swift
//  PointMap
//
//  Created by Вячеслав Бельтюков on 21/06/2018.
//  Copyright © 2018 Vyacheslav Beltyukov. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController {

    @IBOutlet private weak var mapView: MKMapView!

    private let locationHelper = LocationHelper()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

    }
}

// Map view delegate

extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        let coordinate = userLocation.coordinate
        let span = locationHelper.span(for: Configuration.Map.defaultMapRadius,
                                       at: coordinate)
        mapView.region = MKCoordinateRegion(center: coordinate, span: span)
    }
}

