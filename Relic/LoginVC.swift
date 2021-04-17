//
//  LoginVC.swift
//  Relic
//
//  Created by Bryan McGuffin on 5/23/18.
//  Copyright © 2018 Bryan McGuffin. All rights reserved.
//

import UIKit
import Firebase
import MapKit

class LoginVC: UIViewController {
	
	@IBOutlet weak var emailField: UITextField!
	@IBOutlet weak var passwordField: UITextField!
	override func viewDidLoad() {
		super.viewDidLoad()
		Auth.auth().addStateDidChangeListener() { auth, user in
			// 2
			if user != nil {
				// 3
				Database.database().reference(withPath: "users").child(Auth.auth().currentUser!.uid).updateChildValues([
					"currently online" : true,
					])
				
				self.performSegue(withIdentifier: "loggedIn", sender: nil)
				self.emailField.text = nil
				self.passwordField.text = nil
			}
		}
		// Do any additional setup after loading the view.
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	
	
	// MARK: - Navigation
	
	// In a storyboard-based application, you will often want to do a little preparation before navigation
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let central = segue.destination as? CentralVC {
			UserModelObject.removeSingleton()
			central.UID = Auth.auth().currentUser!.uid
		}
	}
	
	@IBAction func signUpButton(_ sender: Any) {
		Auth.auth().createUser(withEmail: self.emailField.text!, password: self.passwordField.text!) { user, error in
			if error == nil {
				Auth.auth().signIn(withEmail: self.emailField.text!, password: self.passwordField.text!)
				let user = Auth.auth().currentUser!
				let userbase = Database.database().reference(withPath: "users")
				let noloc = CLLocationCoordinate2D()
				userbase.child(user.uid).setValue(UserModelObject(UID: user.uid, user: "new user", email: user.email!, location: noloc, relicCount: 0, score: 0, online: true).toAnyObject())
			}
		}
	}
	@IBAction func loginButton(_ sender: Any) {
		guard
			let email = self.emailField.text,
			let password = self.passwordField.text,
			email.count > 0,
			password.count > 0
			else {
				return
		}
		
		Auth.auth().signIn(withEmail: email, password: password) { user, error in
			if let error = error, user == nil {
				let alert = UIAlertController(title: "Sign In Failed", message: error.localizedDescription, preferredStyle: .alert)
				alert.addAction(UIAlertAction(title: "OK", style: .default))
				self.present(alert, animated: true, completion: nil)
			}
		}
	}
	
	@IBAction func logout(_ sender: UIStoryboardSegue){
	}
}
