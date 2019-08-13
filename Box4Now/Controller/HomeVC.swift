//
//  HomeVC.swift
//  Box4Now
//
//  Created by Olaf Bergmann on 23/11/2018.
//  Copyright © 2018 Olaf Bergmann. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import RevealingSplashView
import Firebase

class HomeVC: UIViewController, MKMapViewDelegate {

    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var actionButton: RoundedShadowButton!
    @IBOutlet weak var centerMapBtn: UIButton!
    @IBOutlet weak var destinationTextField: UITextField!
    @IBOutlet weak var destinationCircle: CircleView!
    @IBOutlet weak var cancelBtn: UIButton!

    
    var delegate: CenterVCDelegate?
    
    var manager = CLLocationManager()
    
    var regionRadius: CLLocationDistance = 1000
    
    let testCordinates = CLLocationCoordinate2D(latitude: 0.24, longitude: 0.55)
    
    let revealingSplashView = RevealingSplashView(iconImage: UIImage(named: "Box4Now2")!, iconInitialSize: CGSize(width: 80, height: 80), backgroundColor: UIColor.white)
    
    var tableView = UITableView()
    
    var matchingItems: [MKMapItem] = [MKMapItem]()
    
    //var currentUserId = Auth.auth().currentUser?.uid
    
    var route: MKRoute!
    
    var selectedItemPlacemark: MKPlacemark? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView?.delegate = self
        destinationTextField.delegate = self
        
        manager = CLLocationManager()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        
        checkLocationAuthStatus()
        
        centerMapOnUserLocation()
        
        DataService.instance.REF_COURIERS.observe(.value) { (snapshot) in
            self.loadCourierAnnotationsFromFB()

        }
        
        loadCourierAnnotationsFromFB()
        
        self.view.addSubview(revealingSplashView)
        revealingSplashView.animationType = SplashAnimationType.heartBeat
        revealingSplashView.startAnimation()
        revealingSplashView.heartAttack = true
        
        UpdateService.instance.observeTrips { (tripDict) in
            if let tripDict = tripDict {
                let pickupCoordinateArray = tripDict["pickupCoordinate"] as! NSArray
                let destinationCoordinateArray = tripDict["destinationCoordinate"] as! NSArray
                let tripKey = tripDict["userKey"] as! String
                let acceptanceStatus = tripDict["tripIsAccepted"] as! Bool
                
                if acceptanceStatus == false {
                    let currentUserId = Auth.auth().currentUser?.uid
                    if currentUserId != nil { //tymczasowe
                        DataService.instance.driverIsAvailable(key: currentUserId!, handler: { (available) in
                            if let available = available {
                                if available == true {
                                    let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                                    let pickupVC = storyboard.instantiateViewController(withIdentifier: "PickupVC") as? PickupVC
                                    pickupVC?.initData(pickupCoordinate: CLLocationCoordinate2D(latitude: pickupCoordinateArray[0] as! CLLocationDegrees, longitude: pickupCoordinateArray[1] as! CLLocationDegrees), destinationCoordinate: CLLocationCoordinate2D(latitude: destinationCoordinateArray[0] as! CLLocationDegrees, longitude: destinationCoordinateArray[1] as! CLLocationDegrees), userKey: tripKey)
                                    self.present(pickupVC!, animated: true, completion: nil)
                                    //destCoordinate: CLLocationCoordinate2D(latitude: destinationCoordinateArray[0] as! CLLocationDegrees, longitude: destinationCoordinateArray[1] as! CLLocationDegrees)
                                }
                            }
                        })
                    }

                    
                }
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let currentUserId = Auth.auth().currentUser?.uid

            DataService.instance.driverIsAvailable(key: currentUserId!, handler:  { (status) in
                if status == false {
                    DataService.instance.REF_TRIPS.observeSingleEvent(of: .value, with: { (tripSnapshot) in
                        if let tripSnapshot = tripSnapshot.children.allObjects as? [DataSnapshot] {
                            for trip in tripSnapshot {
                                if trip.childSnapshot(forPath: "courierKey").value as? String == currentUserId {
                                    let pickupCoordinateArray = trip.childSnapshot(forPath: "pickupCoordinate").value as! NSArray
                                    let pickupCoordinate = CLLocationCoordinate2D(latitude: pickupCoordinateArray[0] as! CLLocationDegrees, longitude: pickupCoordinateArray[1] as! CLLocationDegrees)
                                    let pickupPlacemark = MKPlacemark(coordinate: pickupCoordinate)
                                    self.dropPinFor(placemark: pickupPlacemark)
                                    self.searchMapKitForResultsWithPolyLine(forMapItem: MKMapItem(placemark: pickupPlacemark))
                                }
                            }
                        }
                    })
                }
            })
        
        DataService.instance.REF_TRIPS.observe(.childRemoved, with: { (removedTripSnapshot) in
        let removedTripDict = removedTripSnapshot.value as? [String: AnyObject]
            if removedTripDict?["courierKey"] != nil {
                DataService.instance.REF_COURIERS.child(removedTripDict?["courierKey"] as! String).updateChildValues(["courierIsOnTrip": false])
            }
            
            let currentUserId = Auth.auth().currentUser?.uid
                
            DataService.instance.userIsCourier(userKey: currentUserId!, handler: { (IsCourier) in
            if IsCourier == true {
                        //remove overlays and annotations / hide request ride btn and cancel btn
            } else {
                //self.cancelBtn.fadeTo(alphaValue: 0.0, withDuration: 0.2)
                self.actionButton.animateButton(shouldLoad: false, withMessage: "ORDER")
                
                self.destinationTextField.isUserInteractionEnabled = true
                self.destinationTextField.text = ""
                    //remove all map annotations and overlays
                self.centerMapOnUserLocation()
                }
            })


        })
    
}
    
    func checkLocationAuthStatus() {
        if CLLocationManager.authorizationStatus() == .authorizedAlways {
            manager.delegate = self
            manager.desiredAccuracy = kCLLocationAccuracyBest
            manager.startUpdatingLocation()
        } else {
            manager.requestAlwaysAuthorization()
        }
    }
    
    func loadCourierAnnotationsFromFB() {
        DataService.instance.REF_COURIERS.observeSingleEvent(of: .value, with: { (snapshot) in
            if let courierSnapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for courier in courierSnapshot {
                    if courier.hasChild("userIsCourier") {
                        if courier.hasChild("coordinate") {
                            if courier.childSnapshot(forPath: "isPickupModeEnabled").value as? Bool == true {
                                if let courierDict = courier.value as? Dictionary<String, AnyObject> {
                                    let coordinateArray = courierDict["coordinate"] as! NSArray
                                    let courierCoordinate = CLLocationCoordinate2D(latitude: coordinateArray[0] as! CLLocationDegrees, longitude: coordinateArray[1] as! CLLocationDegrees)
                                    
                                    let annotation = CourierAnnotation(coordinate: courierCoordinate, withKey: courier.key)
                                    var courierIsVisible: Bool {
                                        return self.mapView.annotations.contains(where: { (annotation) -> Bool in
                                            if let courierAnnotation = annotation as? CourierAnnotation {
                                                if courierAnnotation.key == courier.key {
                                                    courierAnnotation.update(annotationPosition: courierAnnotation, withCoordinate: courierCoordinate)
                                                    return true
                                                }
                                            }
                                            return false
                                        })
                                    }
                                    if !courierIsVisible {
                                        self.mapView.addAnnotation(annotation)
                                    }
                                }
                            } else {
                                for annotation in self.mapView.annotations {
                                    if annotation.isKind(of: CourierAnnotation.self) {
                                        if let annotation = annotation as? CourierAnnotation {
                                            if annotation.key == courier.key {
                                                self.mapView.removeAnnotation(annotation)
                                            }
                                        }
                                    }
                                        
                                }
                            }
                        }
                    }
                   
                }
            }
        })
    }
    
    func centerMapOnUserLocation() {
        let cordinateRegion = MKCoordinateRegion(center: mapView?.userLocation.coordinate ?? testCordinates, latitudinalMeters: regionRadius * 2.0, longitudinalMeters: regionRadius * 2.0)
        mapView?.setRegion(cordinateRegion, animated: true)
    }
    
    
    
    @IBAction func actionButtonWasPressed(_ sender: Any) {
        
        let spinner = UIActivityIndicatorView()
        spinner.style = .whiteLarge
        spinner.color = UIColor.darkGray
        spinner.alpha = 0.0
        spinner.hidesWhenStopped = true
        spinner.tag = 21
        
        if Auth.auth().currentUser?.uid == nil {
            showAlert("Please create account first, you can do it in left up corner menu")
        } else if destinationTextField.text!.isEmpty {
            showAlert("Destination can't be empty")
        } else {
            UpdateService.instance.updateTripsWithCoordinatesUponRequest()
            
            //actionButton.animateButton(shouldLoad: true, withMessage: nil)
            actionButton.layer.cornerRadius = actionButton.frame.height / 2
            actionButton.frame = CGRect(x: actionButton.frame.midX - (actionButton.frame.height/2), y: actionButton.frame.origin.y, width: actionButton.frame.height, height: actionButton.frame.height)
            actionButton.addSubview(spinner)
            spinner.startAnimating()
            spinner.center = CGPoint(x: actionButton.frame.width / 2 + 1, y: actionButton.frame.width / 2 + 1)
            
            spinner.fadeTo(alphaValue: 1.0, withDuration: 0.2)
            self.view.endEditing(true)
            destinationTextField.isUserInteractionEnabled = false
        }
        
    }
    
    @IBAction func cancelBtnWasPressed(_ sender: Any) {
        //sprawdzanie czy paczka została już odebrana
        let currentUserId = Auth.auth().currentUser?.uid
        guard currentUserId == nil else {
            DataService.instance.courierIsOnTrip(courierKey: currentUserId!) { (isOnTrip, courierKey, tripKey) in
                if isOnTrip == true {
                    UpdateService.instance.cancelTrip(withPackageKey: tripKey!, forCourierKey: courierKey!)
                }
            }
            DataService.instance.userIsOnTrip(userKey: currentUserId!) { (isOnTrip, courierKey, tripKey) in
                if isOnTrip == true {
                    
                    //UpdateService.instance.cancelTrip(withPackageKey: currentUserId!, forcourierKey: courierKey!)
                } else {
                    UpdateService.instance.cancelTrip(withPackageKey: currentUserId!, forCourierKey: nil)
                }
            }
            return
        }
    }
    
    
    @IBAction func menuButtonWasPressed(_ sender: Any) {
        self.view.endEditing(true)
        delegate?.toggleLeftPanel()
    }
    
    
    @IBAction func centerMapBtnWasPressed(_ sender: Any) {
        DataService.instance.REF_USERS.observeSingleEvent(of: .value) { (snapshot) in
            if let userSnapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for user in userSnapshot {
                    if user.key == Auth.auth().currentUser?.uid {
                        if user.hasChild("tripCoordinate") {
                            self.zoom(toFitAnnotationsFromMapView: self.mapView)
                            self.centerMapBtn.fadeTo(alphaValue: 0.0, withDuration: 0.2)
                        } else {
                            self.centerMapOnUserLocation()
                            self.centerMapBtn.fadeTo(alphaValue: 0.0, withDuration: 0.2)
                        }
                    } else {
                        self.centerMapOnUserLocation()
                        self.centerMapBtn.fadeTo(alphaValue: 0.0, withDuration: 0.2)
                    }
                }
            }
        }
    }
    
}
