//
//  CentralVC.swift
//  Relic
//
//  Created by Bryan McGuffin on 5/23/18.
//  Copyright © 2018 Bryan McGuffin. All rights reserved.
//

import UIKit
import Firebase
import GeoFire

class CentralVC: UITabBarController {
	var relicbase : DatabaseReference?
	var userbase : DatabaseReference?
	var geobase : GeoFire?
	var currentLoc : CLLocationCoordinate2D?
	var UID : String!

    override func viewDidLoad() {
        super.viewDidLoad()
		userbase = Database.database().reference(withPath: "users").child(UID)
		relicbase = Database.database().reference(withPath: "relics")
		geobase = GeoFire(firebaseRef: Database.database().reference(withPath: "geodata"))
		currentLoc = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

	
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("Now moving to \(segue.destination)")
    }
	

}
