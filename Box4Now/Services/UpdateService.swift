//
//  UpdateService.swift
//  Box4Now
//
//  Created by Olaf Bergmann on 20/12/2018.
//  Copyright © 2018 Olaf Bergmann. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import Firebase

class UpdateService {
    static var instance = UpdateService()
    
    func updateUserLocation(withCoordinate coordinate: CLLocationCoordinate2D) {
        DataService.instance.REF_USERS.observeSingleEvent(of: .value, with: { (snapshot) in
            if let userSnapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for user in userSnapshot {
                    if user.key == Auth.auth().currentUser?.uid {
                        DataService.instance.REF_USERS.child(user.key).updateChildValues(["coordinate":[coordinate.latitude, coordinate.longitude]])
                    }
                }
            }
        })
    }
    func updateCourierLocation(withCoordinate coordinate: CLLocationCoordinate2D) {
        DataService.instance.REF_COURIERS.observeSingleEvent(of: .value, with: {(snapshot) in
            if let courierSnapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for courier in courierSnapshot {
                    if courier.key == Auth.auth().currentUser?.uid {
                        if courier.childSnapshot(forPath: "isPickupModeEnabled").value as? Bool == true {
                            DataService.instance.REF_COURIERS.child(courier.key).updateChildValues(["coordinate": [coordinate.latitude, coordinate.longitude]])
                        }
                    }
                }
            }
        })
    }
    
    func observeTrips(handler: @escaping(_ coordinateDict: Dictionary<String, Any>?) -> Void) {
        DataService.instance.REF_TRIPS.observe(.value) { (snapshot) in
            if let tripSnapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for trip in tripSnapshot {
                    if trip.hasChild("userKey") && trip.hasChild("tripIsAccepted") {
                        if let tripDict = trip.value as? Dictionary<String, AnyObject> {
                            handler(tripDict)
                        }
                    }
                }
            }
        }
    }
    
    func updateTripsWithCoordinatesUponRequest() {
        DataService.instance.REF_USERS.observeSingleEvent(of: .value, with: { (snapshot) in
            if let userSnapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for user in userSnapshot {
                    if user.key == Auth.auth().currentUser?.uid {
                        if !user.hasChild("userIsDriver") {
                            if let userDict = user.value as? Dictionary<String, AnyObject> {
                                let pickupArray = userDict["coordinate"] as! NSArray
                                let destinationArray = userDict["tripCoordinate"] as! NSArray
                                
                                DataService.instance.REF_TRIPS.child(user.key).updateChildValues(["pickupCoordinate": [pickupArray[0], pickupArray[1]], "destinationCoordinate": [destinationArray[0], destinationArray[1]], "userKey": user.key, "tripIsAccepted": false])
                                //"destinationCoordinate": [destinationArray[0], destinationArray[1]],
                            }
                        }
                    }
                }
            }
        })
    }
    
    func acceptTrip(withPackageKey packageKey: String, forCourierKey courierKey: String) {
        DataService.instance.REF_TRIPS.child(packageKey).updateChildValues(["courierKey": courierKey, "tripIsAccepted": true])
        DataService.instance.REF_COURIERS.child(courierKey).updateChildValues(["courierIsOnTrip": true])
    }
    
    func cancelTrip(withPackageKey packageKey: String, forCourierKey courierKey: String?) {
        DataService.instance.REF_TRIPS.child(packageKey).removeValue()
        DataService.instance.REF_USERS.child(packageKey).child("tripCoordinate").removeValue()
        if courierKey != nil {
            DataService.instance.REF_COURIERS.child(courierKey!).updateChildValues(["courierIsOnTrip": false])
        }
    }
}
