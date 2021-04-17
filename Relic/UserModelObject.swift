//
//  UserModelObject.swift
//  Relic
//
//  Created by Bryan McGuffin on 5/7/18.
//  Copyright © 2018 Bryan McGuffin. All rights reserved.
//

import Foundation
import MapKit
import Firebase

class UserModelObject {
	
	static var singletonObject : UserModelObject?
	
	var lastLocation : CLLocationCoordinate2D
	var username : String
	var email : String
	var relicCount : Int
	var score : Double
	var currentlyOnline : Bool
	var myrelics : [String : Bool]
	
	
	init(UID: String, user: String, email: String, location: CLLocationCoordinate2D, relicCount: Int, score: Double, online: Bool) {
		self.username = user
		self.email = email
		self.lastLocation = location
		self.relicCount = relicCount
		self.score = score
		self.currentlyOnline = online
		self.myrelics = [:]
	}
	
	init?(snapshot : DataSnapshot) {
		let snap = snapshot.value as! [String: AnyObject]
		self.username = snap["username"] as! String
		self.email = snap["email"] as! String
		self.relicCount = snap["relic count"] as! Int
		self.score = snap["score"] as! Double
		self.currentlyOnline = snap["currently online"] as! Bool
		let coord = snap["coord"] as! [String : AnyObject]
		self.lastLocation = CLLocationCoordinate2D(latitude: coord["latitude"] as! Double, longitude: coord["longitude"] as! Double)
		if let relics = snap["relics"] as? [String : Bool]
		{
			self.myrelics = relics
		}
		else {
			self.myrelics = [:]
		}
		
	}
	
	static func getSingleton(snapshot : DataSnapshot) -> UserModelObject? {
		if let singleton = singletonObject {
			//print("User already exists. Handing over reference to current user.")
			//print("Current user is \(singleton.username)")
			return singleton
		}
		else if let newObject = UserModelObject.init(snapshot: snapshot) {
			//print("Generated new user.")
			singletonObject = newObject
			//print("Current user is \(newObject.username)")
			return singletonObject!
		}
		else {
			print("ERROR: No current user; user generation failed")
			return nil
		}
	}
	
	static func removeSingleton() {
		//print("Removed existing user.")
		singletonObject = nil
	}
	
	func toAnyObject() -> Any {
		return [
			"username" : username,
			"email" : email,
			"coord" : [
				"latitude" : lastLocation.latitude,
				"longitude" : lastLocation.longitude,
			],
			"relic count" : relicCount,
			"score" : score,
			"currently online" : currentlyOnline,
			"relics" : myrelics
		]
	}
	
}
