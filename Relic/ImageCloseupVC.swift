//
//  ImageCloseupViewController.swift
//  Relic
//
//  Created by Bryan McGuffin on 6/10/18.
//  Copyright © 2018 Bryan McGuffin. All rights reserved.
//

import UIKit

class ImageCloseupVC: UIViewController {

	@IBOutlet weak var imageView: UIImageView!
	var image : UIImage!
	
	override func viewDidLoad() {
        super.viewDidLoad()
		imageView.image = self.image

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
