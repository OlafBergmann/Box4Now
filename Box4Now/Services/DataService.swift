//
//  DataService.swift
//  Box4Now
//
//  Created by Olaf Bergmann on 07/12/2018.
//  Copyright © 2018 Olaf Bergmann. All rights reserved.
//

import Foundation
import Firebase

let DB_BASE = Database.database().reference()

class DataService {
    static let instance = DataService()
    
        private var _REF_BASE = DB_BASE
        private var _REF_USERS = DB_BASE.child("users")
        private var _REF_COURIERS = DB_BASE.child("couriers")
        private var _REF_TRIPS = DB_BASE.child("trips")
    
    var REF_BASE: DatabaseReference {
        return _REF_BASE
    }
    
    var REF_USERS: DatabaseReference {
        return _REF_USERS
    }
    
    var REF_COURIERS: DatabaseReference {
        return _REF_COURIERS
    }
    
    var REF_TRIPS: DatabaseReference {
        return _REF_TRIPS
    }
    
    func createFirebaseDBUser(uid: String, userData: Dictionary<String,Any>, isCourier: Bool) {
        if isCourier {
            REF_COURIERS.child(uid).updateChildValues(userData)
        }
        else {
            REF_USERS.child(uid).updateChildValues(userData)
        }
    }
    
    func driverIsAvailable(key: String, handler: @escaping (_ status: Bool?) -> Void) {
        DataService.instance.REF_COURIERS.observeSingleEvent(of: .value, with: { (snapshot) in
            if let courierSnapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for courier in courierSnapshot {
                    if courier.key == key {
                        if courier.childSnapshot(forPath: "isPickupModeEnabled").value as? Bool == true {
                            if courier.childSnapshot(forPath: "courierIsOnTrip").value as? Bool == true {
                                handler(false)
                            } else {
                                handler(true)
                            }
                        }
                    }
                }
            }
        })
    }
    
    func courierIsOnTrip(courierKey: String, handler: @escaping(_ status: Bool?, _ courierKey: String?,_ tripKey: String?) -> Void) {
        DataService.instance.REF_COURIERS.child(courierKey).child("courierIsOnTrip").observe(.value, with: { (courierTripStatusSnapshot) in
            if let courierTripStatusSnapshot = courierTripStatusSnapshot.value as? Bool {
                if courierTripStatusSnapshot == true {
                    DataService.instance.REF_TRIPS.observeSingleEvent(of: .value, with: { (tripSnapshot) in
                        if let tripSnapshot = tripSnapshot.children.allObjects as? [DataSnapshot] {
                            for trip in tripSnapshot {
                                if trip.childSnapshot(forPath: "courierKey").value  as? String == courierKey {
                                    handler(true, courierKey, trip.key)
                                
                                } else {
                                    return
                                }
                            }
                        }
                    })
                } else {
                    handler(false, nil, nil)
                }
                
            }
        })
        
    }
    
    func userIsOnTrip(userKey: String, handler: @escaping (_ status: Bool?, _ courierKey: String?, _ tripKey: String?) -> Void) {
        DataService.instance.REF_TRIPS.observeSingleEvent(of: .value, with: { (tripSnapshot) in
            if let tripSnapshot = tripSnapshot.children.allObjects as? [DataSnapshot] {
                for trip in tripSnapshot {
                    if trip.key == userKey {
                        if trip.childSnapshot(forPath: "tripIsAccepted").value as? Bool == true {
                            let courierKey = trip.childSnapshot(forPath: "courierKey").value as? String
                            handler(true, courierKey, trip.key )
                        } else {
                            handler(false, nil, nil)
                        }
                    }
                }
            }
        })
    }
    
    func userIsCourier(userKey: String, handler: @escaping (_ status: Bool) -> Void) {
        DataService.instance.REF_COURIERS.observeSingleEvent(of: .value, with: { (courierSnapshot) in
            if let courierSnapshot = courierSnapshot.children.allObjects as? [DataSnapshot] {
                for courier in courierSnapshot {
                    if courier.key == userKey {
                        handler(true)
                    } else {
                        handler(false)
                    }
                }
            }
        })
    }

}







