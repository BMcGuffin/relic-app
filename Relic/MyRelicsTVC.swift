//
//  MyRelicsTVC.swift
//  Relic
//
//  Created by Bryan McGuffin on 5/7/18.
//  Copyright © 2018 Bryan McGuffin. All rights reserved.
//

import UIKit
import Firebase

class MyRelicsTVC: UITableViewController {
	
	// MARK: - Properties
	
	var user : UserModelObject?
	var relicbase : DatabaseReference!
	var userbase : DatabaseReference!
	var relics : [RelicModelObject] = []
	
	// MARK: - Setup and load
	
	override func viewDidLoad() {
		super.viewDidLoad()
		relicbase = Database.database().reference(withPath: "relics")
		userbase = Database.database().reference(withPath: "users").child(Auth.auth().currentUser!.uid)
		userbase.observeSingleEvent(of: .value, with: { snapshot in
			if let model = UserModelObject.getSingleton(snapshot: snapshot){
				self.user = model
				self.reloadRelicList()
			}
		})
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		reloadRelicList()
	}
	
	
	// MARK: - Table view data source
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		//print("Expected \(relics.count) relics.")
		return relics.count
	}
	
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cellIdentifier = "MyRelicsCell"
		
		guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? MyRelicsCell  else {
			fatalError("The dequeued cell is not an instance of MyRelicsCell.")
		}
		
		let relic = relics[indexPath.row]
		
		// Configure the cell...
		cell.relicTitle.text = relic.name
		cell.relicDate.text = relic.date
		
		return cell
	}
	
	func reloadRelicList() {
		//print("Attempting to reload relic list...")
		
		//If no one is logged in, clear the table.
		guard let _ = Auth.auth().currentUser?.uid else {
			self.relics = []
			tableView.reloadData()
			//print("No user. Emptied list.")
			return
		}
		
		//If we don't have a user yet, don't do anything.
		guard self.user != nil else {
			//print("No user. Aborted.")
			return
		}
		
		//print("Starting with \(self.relics.count) relics. Hoping to find \(String(describing: self.user?.relicCount)).")
		//If no relics have been added or removed, don't do anything.
		if self.relics.count == self.user?.relicCount {
			//print("Relic list contains all items. Aborted.")
			return
		}
		
		self.relics = []
		
		for relic in self.user!.myrelics {
			//print("Searching for relic \(relic.key)")
			self.relicbase.child(relic.key).observeSingleEvent(of: .value, with: {snapshot in
				if let newRelic = RelicModelObject(snapshot: snapshot) {
					//print("Returned a query with relic \(newRelic.generateUniqueKey())")
					if !self.relics.contains(newRelic) {
						self.relics.append(newRelic)
						//print("Added a relic for user \(Auth.auth().currentUser!.uid)")
						self.tableView.reloadData()
					}
				}
			})
		}
	}
	
	// MARK: - Navigation
	
	// In a storyboard-based application, you will often want to do a little preparation before navigation
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let dest = segue.destination as? RelicDetailVC, let selectedRelicCell = sender as? MyRelicsCell, let indexPath = tableView.indexPath(for: selectedRelicCell) {
			dest.currentUser = user
			dest.currentRelic = relics[indexPath.row]
			dest.sourceView = "MyRelicsTVC"
		}
		else {
			print("ERROR: couldn't send location")
		}
	}
	
	@IBAction func returnToMyRelics(_ sender: UIStoryboardSegue){
		//print("Unwound.")
	}
	
	
}
