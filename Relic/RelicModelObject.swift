//
//  RelicModelObject.swift
//  Relic
//
//  Created by Bryan McGuffin on 5/7/18.
//  Copyright © 2018 Bryan McGuffin. All rights reserved.
//

import Foundation
import MapKit
import Firebase

class RelicModelObject : NSObject, MKAnnotation {
	var name: String
	var text: String
	var ownerUID: String
	var date: String
	var coordinate: CLLocationCoordinate2D
	var hasImage: Bool
	var image: UIImage?
	
	init(name: String, ownerUID: String, coord: CLLocationCoordinate2D, text: String, image: UIImage?) {
		self.name = name
		self.text = text
		self.ownerUID = ownerUID
		let currentDate = Date()
		let df = DateFormatter()
		df.dateFormat = "yyyy-MM-dd_HH:mm:ss"
		self.date = df.string(from: currentDate)
		self.coordinate = coord
		self.hasImage = false
		if let img = image {
			self.image = img
			self.hasImage = true
		}
	}
	
	init?(snapshot : DataSnapshot) {
		let snap = snapshot.value as! [String: AnyObject]
		self.name = snap["name"] as! String
		self.text = snap["text"] as! String
		self.ownerUID = snap["ownerUID"] as! String
		self.date = snap["date"] as! String
		let coord = snap["coordinate"] as! [String : AnyObject]
		self.coordinate = CLLocationCoordinate2D(latitude: coord["latitude"] as! Double, longitude: coord["longitude"] as! Double)
		self.hasImage = snap["hasImage"] as! Bool
	}
	
	func toAnyObject() -> Any {
		return [
			"name" : name,
			"text" : text,
			"ownerUID" : ownerUID,
			"date" : date,
			"coordinate" : [
				"latitude" : coordinate.latitude,
				"longitude" : coordinate.longitude
			],
			"hasImage" : hasImage
		]
	}
	
	func generateUniqueKey() -> String {
		return ownerUID + "_" + date
	}
	
	var title : String? {
		return name
	}
}
