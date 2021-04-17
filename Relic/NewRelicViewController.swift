//
//  NewRelicVC.swift
//  Relic
//
//  Created by Bryan McGuffin on 5/28/18.
//  Copyright © 2018 Bryan McGuffin. All rights reserved.
//

import UIKit
import MapKit
import Firebase

class NewRelicVC: UIViewController, UITextFieldDelegate, UITextViewDelegate {

	var relic : RelicModelObject?
	var currentUser : UserModelObject!
	
	@IBOutlet weak var titleText: UITextField!
	@IBOutlet weak var bodyText: UITextView!
	@IBOutlet weak var latitudeLabel: UILabel!
	@IBOutlet weak var longitudeLabel: UILabel!
	@IBOutlet weak var doneButton: UIBarButtonItem!
	@IBOutlet weak var imageView: UIImageView!
	
	
	
	override func viewDidLoad() {
        super.viewDidLoad()
		doneButton.isEnabled = false
		titleText.delegate = self
		bodyText.delegate = self
		
		latitudeLabel.text = String(currentUser.lastLocation.latitude)
		longitudeLabel.text = String(currentUser.lastLocation.longitude)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	//MARK: Text Field Stuff
	
	func textFieldDidBeginEditing(_ textField: UITextField) {
		// Disable the Save button while editing.
		doneButton.isEnabled = false
	}
	
	func textFieldDidEndEditing(_ textField: UITextField) {
		//Save button can be enabled as long as title text isn't empty
		doneButton.isEnabled = !(titleText.text!.isEmpty)
	}
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		return true
	}

	@IBAction func endedEditing(_ sender: UITextField) {
		doneButton.isEnabled = !(sender.text!.isEmpty)
		sender.resignFirstResponder()
	}
	
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SaveNewRelic"
		{
			relic = RelicModelObject(name: titleText.text!, ownerUID: Auth.auth().currentUser!.uid, coord: currentUser.lastLocation, text: bodyText.text, image: imageView.image)
		}
    }
	
	@IBAction func photoWasTaken(_ sender: UIStoryboardSegue){
		guard let cameraVC = sender.source as? CameraViewController,  let img = cameraVC.capturedImage else {
			print ("Failed to capture from camera.")
			return
		}
		
		imageView.image = img
		
		//print("A photo was acquired.")
		//print("The photo has size \(String(describing: imageView.image))")
	}
	
	@IBAction func cancelledPhoto(_ sender: UIStoryboardSegue){
		print("Didn't get a photo.")
	}

}
