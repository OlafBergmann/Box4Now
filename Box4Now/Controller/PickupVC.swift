//
//  PickupVC.swift
//  Box4Now
//
//  Created by Olaf Bergmann on 23/12/2018.
//  Copyright © 2018 Olaf Bergmann. All rights reserved.
//

import UIKit
import MapKit
import Firebase
import AudioToolbox

class PickupVC: UIViewController {
    
    @IBOutlet weak var pickupMapView: RoundMapView!
    
    var regionRadius: CLLocationDistance = 2000
    
    var pin: MKPlacemark? = nil
    
    var pickupCoordinate: CLLocationCoordinate2D!
    
    var destinationCoordinate: CLLocationCoordinate2D!
    
    var userKey: String = ""
    
    var locationPlacemark: MKPlacemark!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pickupMapView.delegate = self
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        locationPlacemark = MKPlacemark(coordinate: pickupCoordinate)
        dropPinFor(placemark: locationPlacemark)
//      locationPlacemark = MKPlacemark(coordinate: destinationCoordinate)
//      dropPinFor(placemark: locationPlacemark)
        centerMapOnLocation(location: locationPlacemark.location!)
        
        DataService.instance.REF_TRIPS.child(userKey).observe(.value, with: { (tripSnapshot) in
            if tripSnapshot.exists() {
                if tripSnapshot.childSnapshot(forPath: "tripIsAccepted").value as? Bool == true {
                    self.dismiss(animated: true, completion: nil)
                }
            } else {
                self.dismiss(animated: true, completion: nil)
            }
        })
    }
    
    func initData(pickupCoordinate: CLLocationCoordinate2D, destinationCoordinate: CLLocationCoordinate2D, userKey: String) {
        //,destCoordinate: CLLocationCoordinate2D
        self.pickupCoordinate = pickupCoordinate
       // self.destinationCoordinate = destCoordinate
        self.userKey = userKey
    }

    @IBAction func cancelBtnWasPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func acceptPackageBtnWasPressed(_ sender: Any) {
        let currentUserId = Auth.auth().currentUser?.uid
        if currentUserId != nil {
            UpdateService.instance.acceptTrip(withPackageKey: userKey, forCourierKey: currentUserId!)
            presentingViewController?.shouldPresentLoadingView(true)
        }
    
    }
    
}
