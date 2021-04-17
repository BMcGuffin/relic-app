//
//  MapVC.swift
//  Relic
//
//  Created by Bryan McGuffin on 5/17/18.
//  Copyright © 2018 Bryan McGuffin. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Firebase
import GeoFire

class MapVC: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
	// MARK: - Properties
	
	@IBOutlet weak var mapView: MKMapView!
	var relicbase : DatabaseReference!
	var userbase : DatabaseReference!
	var geobase : GeoFire!
	var imageStore : StorageReference!
	var currentLoc : CLLocationCoordinate2D!
	var globalZoom = 3.0
	var usermodel : UserModelObject?
	var regionQuery : GFRegionQuery!
	
	let locationManager = CLLocationManager()
	let imageQualityJPEG : CGFloat = 0.8
	
	// MARK: - Setup
	override func viewDidLoad() {
		super.viewDidLoad()
		mapView.delegate = self
		mapView.showsUserLocation = true
		imageStore = Storage.storage(url: "gs://relic-72de3.appspot.com").reference(withPath: "images")
		relicbase = Database.database().reference(withPath: "relics")
		userbase = Database.database().reference(withPath: "users").child(Auth.auth().currentUser!.uid)
		geobase = GeoFire(firebaseRef: Database.database().reference(withPath: "geodata"))
		
		regionQuery = geobase.query(with: mapView.region)
		userbase.observe(.value, with: { snapshot in
			if let model = UserModelObject(snapshot: snapshot){
				self.usermodel = model
				self.centerMap(at: model.lastLocation)
			}
		})
		configureLocationManager()
		
		
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	// MARK: - Location Manager
	func configureLocationManager() {
		CLLocationManager.locationServicesEnabled()
		locationManager.delegate = self
		locationManager.desiredAccuracy = kCLLocationAccuracyBest
		locationManager.distanceFilter = 3
		locationManager.requestWhenInUseAuthorization()
		locationManager.requestAlwaysAuthorization()
		locationManager.startUpdatingLocation()
	}
	
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		let nextLocation = locations.last!
		currentLoc = nextLocation.coordinate
		usermodel?.lastLocation = currentLoc
		userbase.child("coord").updateChildValues([
			"latitude" : currentLoc.latitude,
			"longitude" : currentLoc.longitude
			])
	}
	
	func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
		print("CL ERROR: \(error.localizedDescription)")
	}
	
	func centerMap(at newCenter: CLLocationCoordinate2D) {
		
		let span = mapView.region.span
		let newRegion = MKCoordinateRegion(center: newCenter, span: span)
		mapView.setRegion(newRegion, animated: true)
	}
	
	
	// MARK: - Navigation
	
	// In a storyboard-based application, you will often want to do a little preparation before navigation
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let dest = segue.destination as? NewRelicViewController {
			dest.currentUser = usermodel
		}
		if let dest = segue.destination as? RelicDetailViewController, let relic = sender as? RelicModelObject {
			dest.currentUser = usermodel
			dest.currentRelic = relic
			dest.sourceView = "MapViewController"
		}
		else {
			print("ERROR: couldn't send location")
		}
	}
	
	@IBAction func cancelNewRelic(_ sender: UIStoryboardSegue){
		print("Hello from the map: CANCEL")
	}
	
	@IBAction func saveNewRelic(_ sender: UIStoryboardSegue){
		print("Hello from the map: SAVE")
		if let src = sender.source as? NewRelicViewController, let relic = src.relic {
			geobase.setLocation(CLLocation(coord: relic.coordinate), forKey: relic.generateUniqueKey())
			relicbase.child(relic.generateUniqueKey()).setValue(relic.toAnyObject())
			if relic.hasImage {
				print("Relic has image of size \(relic.image!.size)")
				guard let data = UIImageJPEGRepresentation(relic.image!, imageQualityJPEG) else {
					print("Could not cast image to data.")
					return
				}
				
				print("Casted image to data. Byte count is \(data.count)")
				
				let metadata = StorageMetadata()
				metadata.contentType = "image/jpeg"
				
				print("Uploading with metadata...")
				imageStore.child(relic.generateUniqueKey()).putData(data, metadata: metadata)
				print("Upload task completed.")
			}
			
			
			
			usermodel!.myrelics[relic.generateUniqueKey()] = true
			usermodel!.relicCount += 1
			userbase.updateChildValues(["relics" : usermodel!.myrelics,
										"relic count" : usermodel!.relicCount])
			updateRegionQuery()
		}
		else {
			print("ERROR: couldn't get a relic object")
		}
	}
	
	@IBAction func returnFromDetail(_ sender: UIStoryboardSegue){
		updateRegionQuery()
	}
	
	// MARK: - Map Stuff
	
	func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
		let view = MKMarkerAnnotationView()
		let loc1 = CLLocation(coord: annotation.coordinate)
		let loc2 = CLLocation(coord: self.currentLoc)
		let dist = loc1.distance(from: loc2)
		if let relic = annotation as? RelicModelObject{
			if relic.ownerUID == Auth.auth().currentUser?.uid {
				view.markerTintColor = .red
				view.canShowCallout = true
				let disclosureButton = UIButton(type: .detailDisclosure)
				view.rightCalloutAccessoryView = disclosureButton
			}
			else if dist < 12 {
				view.markerTintColor = .green
				view.canShowCallout = true
				let disclosureButton = UIButton(type: .detailDisclosure)
				view.rightCalloutAccessoryView = disclosureButton
			}
			else {
				view.markerTintColor = .blue
				view.canShowCallout = false
			}
			
			
		}
		else {
			return nil
		}
		
		
		return view
	}
	
	func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
		//mapView.removeAnnotations(mapView.annotations)
		updateRegionQuery()
	}
	
	func updateRegionQuery() {
		print("Updating region.")
		//if let previous = regionQuery {
		//	previous.removeAllObservers()
		//}
		
		// If we're zoomed out too far, don't do the update
		guard (mapView.region.span.latitudeDelta < 50) else {
			return
		}
		
		regionQuery.region = mapView.region
		
		regionQuery.observe(.keyExited, with: { (key, location) in
			print("Key \(key) exited region.")
			
		})

		regionQuery.observe(.keyEntered, with: { (key, location) in
			print("Key \(key) entered region.")
			self.relicbase?.queryOrderedByKey().queryEqual(toValue: key).observe(.value, with: { snapshot in
				for child in snapshot.children{
					if let childSnapshot = child as? DataSnapshot, let relic = RelicModelObject(snapshot: childSnapshot), !self.mapView.annotations.contains(where: {element in
						guard let other = element as? RelicModelObject else {
							return false
						}
						return other.generateUniqueKey() == relic.generateUniqueKey()
					}){
						DispatchQueue.main.async {
							self.mapView.addAnnotation(relic)
							print("Added a marker")
						}
					}
				}
			})
		})
		
		
	}
	func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
		performSegue(withIdentifier: "relicDetailFromMap", sender: view.annotation!)
	}
}

// MARK: - Extensions

//Generate a random float
extension CGFloat {
	static var random: CGFloat {
		return CGFloat(arc4random()) / CGFloat(UInt32.max)
	}
}

//Generate a random UIColor
extension UIColor {
	static var random: UIColor {
		return UIColor(red: .random, green: .random, blue: .random, alpha: 1.0)
	}
}

//Convenience initializer for CLLocation
extension CLLocation {
	convenience init(coord: CLLocationCoordinate2D) {
		self.init(latitude: coord.latitude, longitude: coord.longitude)
	}
}
