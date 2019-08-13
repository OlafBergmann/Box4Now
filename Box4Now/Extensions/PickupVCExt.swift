//
//  PickupVCExt.swift
//  Box4Now
//
//  Created by Olaf Bergmann on 23/12/2018.
//  Copyright © 2018 Olaf Bergmann. All rights reserved.
//

import MapKit

extension PickupVC: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation)
        -> MKAnnotationView? {
        let identifier = "pickupPoint"
        var annoationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            if annoationView == nil {
                annoationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            } else {
                annoationView?.annotation = annotation
            }
            annoationView?.image = UIImage(named: "currentLocationAnnotation")
            return annoationView
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        pickupMapView.setRegion(coordinateRegion, animated: true)
    }
    
    func dropPinFor(placemark: MKPlacemark) {
        pin = placemark
        
        for annotation in pickupMapView.annotations {
            pickupMapView.removeAnnotation(annotation)
        }
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        
        pickupMapView.addAnnotation(annotation)
    }
}
