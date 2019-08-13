//
//  MenuPanelVC.swift
//  Box4Now
//
//  Created by Olaf Bergmann on 24/11/2018.
//  Copyright © 2018 Olaf Bergmann. All rights reserved.
//

import UIKit
import Firebase

class MenuPanelVC: UIViewController {
    
    let appDelegate = AppDelegate.getAppDelegate()
    
    var currentUserId = Auth.auth().currentUser?.uid
    
    @IBOutlet weak var pickupModeSwitch: UISwitch!
    @IBOutlet weak var pickupModeLbl: UILabel!
    @IBOutlet weak var userImageView: RoundImageView!
    @IBOutlet weak var userEmailLbl: UILabel!
    @IBOutlet weak var userAccountTypeLbl: UILabel!
    @IBOutlet weak var loginOutBtn: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        pickupModeSwitch.isOn = false
        pickupModeSwitch.isHidden = true
        pickupModeLbl.isHidden = true
        
        observeClientsAndCouriers()
        
        if Auth.auth().currentUser == nil {
            userEmailLbl.text = ""
            userAccountTypeLbl.text = ""
            userImageView.isHidden = true
            loginOutBtn.setTitle("Sign Up / Login", for: .normal)
        } else {
            userEmailLbl.text = Auth.auth().currentUser?.email
            userAccountTypeLbl.text = ""
            userImageView.isHidden = false
            pickupModeSwitch.isOn = false
            loginOutBtn.setTitle("Logout", for: .normal)
        }
    }
    
    
    func observeClientsAndCouriers() {
        DataService.instance.REF_USERS.observeSingleEvent(of: .value, with: { (snapshot) in
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshot {
                    if snap.key == Auth.auth().currentUser?.uid {
                        self.userAccountTypeLbl.text = "CUSTOMER"
                    }
                }
            }
        })
        DataService.instance.REF_COURIERS.observeSingleEvent(of: .value, with: {(snapshot) in
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshot {
                    if snap.key == Auth.auth().currentUser?.uid {
                        self.userAccountTypeLbl.text = "COURIER"
                        self.pickupModeSwitch.isHidden = false
                        let switchStatus = snap.childSnapshot(forPath: "isPickupModeEnabled").value as! Bool
                        if switchStatus == true {
                            self.pickupModeLbl.text = "COURIER MODE ENABLED"
                            self.pickupModeSwitch.isOn = true
                        } else {
                            self.pickupModeLbl.text = "COURIER MODE DISABLED"
                            self.pickupModeSwitch.isOn = false
                        }
                        self.pickupModeLbl.isHidden = false
                    }
                }
            }
            
        })
    }
    //"9U86Mn8IhbfSnk3kFS86qRdHFIB2"
    @IBAction func switchWasToggled(_ sender: Any) {
        if pickupModeSwitch.isOn {
            let currentUserId = Auth.auth().currentUser?.uid
            pickupModeLbl.text = "COURIER MODE ENABLED"
            appDelegate.MenuContainerVC.toggleLeftPanel()
            DataService.instance.REF_COURIERS.child(currentUserId!).updateChildValues(["isPickupModeEnabled": true])
        } else {
            pickupModeLbl.text = "COURIER MODE DISABLED"
            appDelegate.MenuContainerVC.toggleLeftPanel()
            if currentUserId != nil { //tymczasowe
                DataService.instance.REF_COURIERS.child(currentUserId!).updateChildValues(["isPickupModeEnabled": false])
            }
            
        }
    }
    
    @IBAction func signUpLoginBtnWasPressed(_ sender: Any) {
        if Auth.auth().currentUser == nil {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginVC") as? LoginVC
        present(loginVC!,animated: true, completion: nil)
        } else {
            do {
                try Auth.auth().signOut()
               
                userEmailLbl.text = ""
                userAccountTypeLbl.text = ""
                userImageView.isHidden = true
                pickupModeLbl.text = ""
                pickupModeSwitch.isHidden = true
                loginOutBtn.setTitle("Sign Up / Login", for: .normal)
            
            } catch (let error) {
                print(error)
            }
        }
        
    }
    
}
