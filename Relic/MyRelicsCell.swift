//
//  MyRelicsCell.swift
//  Relic
//
//  Created by Bryan McGuffin on 5/7/18.
//  Copyright © 2018 Bryan McGuffin. All rights reserved.
//

import UIKit

class MyRelicsCell: UITableViewCell {
	
	@IBOutlet weak var relicTitle: UILabel!
	@IBOutlet weak var relicDate: UILabel!
	
	override func awakeFromNib() {
		super.awakeFromNib()
		// Initialization code
	}
	
	override func setSelected(_ selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)
		
		// Configure the view for the selected state
	}
	
}
