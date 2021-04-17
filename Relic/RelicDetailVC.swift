//
//  RelicDetailVC.swift
//  Relic
//
//  Created by Bryan McGuffin on 5/29/18.
//  Copyright © 2018 Bryan McGuffin. All rights reserved.
//

import UIKit
import Firebase
import FirebaseUI
import GeoFire

class RelicDetailVC: UIViewController {
	// MARK: - Properties
	var userbase : DatabaseReference!
	var relicbase : DatabaseReference!
	var geobase : DatabaseReference!
	var imageStore : StorageReference!
	var currentUser : UserModelObject!
	var currentRelic : RelicModelObject!
	var sourceView : String!

	@IBOutlet weak var titleText: UILabel!
	@IBOutlet weak var authorText: UILabel!
	@IBOutlet weak var dateText: UILabel!
	@IBOutlet weak var bodyText: UITextView!
	@IBOutlet weak var deleteButton: UIButton!
	@IBOutlet weak var imageView: UIImageView!
	// MARK: - Setup and load
	
	override func viewDidLoad() {
        super.viewDidLoad()
		
		titleText.text = currentRelic.name
		bodyText.text = currentRelic.text
		dateText.text = "Date: " + currentRelic.date
        // Do any additional setup after loading the view.
		userbase = Database.database().reference().child("users").child(currentRelic.ownerUID)
		relicbase = Database.database().reference().child("relics")
		geobase = Database.database().reference().child("geodata")
		imageStore = Storage.storage(url: "gs://relic-72de3.appspot.com").reference(withPath: "images")
		
		userbase.observeSingleEvent(of: .value) {snapshot in
			if let model = UserModelObject(snapshot: snapshot){
				self.authorText.text = "Placed by " + model.username
			}
		}
		//print("Current user is \(Auth.auth().currentUser!.uid)")
		//print("Relic belongs to \(currentRelic.ownerUID)")
		
		//print("Current user is \(currentUser.username)")
		
		if currentRelic.ownerUID != Auth.auth().currentUser!.uid {
			//print("Button should be hidden.")
			deleteButton.isHidden = true
		}
		
		if currentRelic.hasImage {
			
			let imgRef = imageStore.child(currentRelic.generateUniqueKey())
			
			guard let downloadTask = imageView.sd_setImage(with: imgRef) else {
				return
			}
			
			downloadTask.observe(.failure, handler: {snapshot in
				print("Download failure:")
				guard let errorCode = (snapshot.error as NSError?)?.code, let error = StorageErrorCode(rawValue: errorCode) else {
					return
				}
				switch (error) {
				case .objectNotFound:
					// File doesn't exist
					print("File not found.")
					break
				case .unauthorized:
					// User doesn't have permission to access file
					print("Access denied.")
					break
				case .cancelled:
					// User cancelled the download
					print("Download was cancelled.")
					break
				
				case .bucketNotFound:
					print("Bucket not found.")
					break
					
				case .downloadSizeExceeded:
					print("File was too big.")
					break
					
				case .nonMatchingChecksum:
					print("Bad checksum.")
					break
					
				case .retryLimitExceeded:
					print("Retry limit exceeded.")
					break
					
				case .projectNotFound:
					print("Project not found.")
					break
					
				case .unauthenticated:
					print("User is not authenticated.")
					break
					
				case .unknown:
					// Unknown error occurred, inspect the server response
					print("Unknown error.")
					break
				default:
					// Another error occurred. This is a good place to retry the download.
					print("Other error.")
					break
				}
			})
		}
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

	
    // MARK: - Navigation
	
	// In a storyboard-based application, you will often want to do a little preparation before navigation
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		// Get the new view controller using segue.destinationViewController.
		// Pass the selected object to the new view controller.
		
		if segue.identifier == "showPhotoDetail", let dest = segue.destination as? ImageCloseupVC, let img = self.imageView.image {
			dest.image = img
		}
	}
	
	@IBAction func returnFromPhotoDetail(_ sender: UIStoryboardSegue){
	}

	@IBAction func backButtonPressed(_ sender: UIBarButtonItem) {
		if sourceView == "MapVC" {
			performSegue(withIdentifier: "returnToMapFromDetail", sender: self)
		}
		else if sourceView == "MyRelicsTVC" {
			performSegue(withIdentifier: "returnToMyRelics", sender: self)
		}
	}
	
	// MARK: - Actions
	
	@IBAction func deleteRelic(_ sender: UIButton) {
		let relicName = currentRelic.generateUniqueKey()
		currentUser.myrelics.removeValue(forKey: relicName)
		currentUser.relicCount -= 1
		userbase.updateChildValues(["relics" : currentUser.myrelics,
									"relic count" : currentUser.relicCount])
		geobase.child(relicName).removeValue()
		relicbase.child(relicName).removeValue()
		if currentRelic.hasImage {
			imageStore.child(relicName).delete {error in
				if let _ = error {
					print("Error in attempt to delete image.")
				}
			}
		}
		
		if sourceView == "MapVC" {
			performSegue(withIdentifier: "returnToMapFromDetail", sender: self)
		}
		else if sourceView == "MyRelicsTVC" {
			performSegue(withIdentifier: "returnToMyRelics", sender: self)
		}
	}
	
	
	@IBAction func photoTapped(_ sender: UITapGestureRecognizer) {
		guard let _ = self.imageView.image else {
			return
		}
		performSegue(withIdentifier: "showPhotoDetail", sender: self)
	}
	
}
