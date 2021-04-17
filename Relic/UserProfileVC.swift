//
//  UserProfileVC.swift
//  Relic
//
//  Created by Bryan McGuffin on 5/23/18.
//  Copyright © 2018 Bryan McGuffin. All rights reserved.
//

import UIKit
import Firebase
import MapKit

class UserProfileVC: UIViewController, UITextFieldDelegate {
	// MARK: - Properties
	var userbase : DatabaseReference!
	var counter = 0
	var usermodel : UserModelObject!
	
	@IBOutlet weak var userEmail: UILabel!
	@IBOutlet weak var relicCount: UILabel!
	//@IBOutlet weak var score: UILabel!
	@IBOutlet weak var usernameText: UITextField!
	
	// MARK: - Setup
	override func viewDidLoad() {
        super.viewDidLoad()
		usernameText.delegate = self
		userbase = Database.database().reference().child("users").child(Auth.auth().currentUser!.uid)
	
		userbase.observe(.value, with: { snapshot in
			if let model = UserModelObject.getSingleton(snapshot: snapshot){
				self.usermodel = model
				self.userEmail.text = self.usermodel.email
				self.relicCount.text = String(self.usermodel.relicCount)
				//self.score.text = String(self.usermodel.score)
				self.usernameText.text = self.usermodel.username
			}
		})

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK: - Text field editing
	@IBAction func updateUsername(_ sender: UITextField) {
		usermodel.username = sender.text!
		sender.resignFirstResponder()
	}
	
	func textFieldDidEndEditing(_ textField: UITextField) {
		if(textField.text!.isEmpty)
		{
			textField.text = usermodel.username
		}
		else {
			usermodel.username = textField.text!
			userbase.updateChildValues(["username" : usermodel.username])
		}
	}
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		return true
	}
	
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
	
	// MARK: - Actions

	@IBAction func logoutButton(_ sender: UIButton) {
		do {
			userbase.updateChildValues(["currently online" : false])
			UserModelObject.removeSingleton()
			try Auth.auth().signOut()
			//performSegue(withIdentifier: "logout", sender: self)
			self.dismiss(animated: true, completion: nil)
		} catch (let error) {
			print("Auth sign out failed: \(error)")
		}
	}
}
