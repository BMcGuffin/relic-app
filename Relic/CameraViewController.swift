//
//  CameraVC.swift
//  Relic
//
//  Created by Bryan McGuffin on 6/6/18.
//  Copyright © 2018 Bryan McGuffin. All rights reserved.
//

import UIKit
import AVKit

class CameraVC: UIViewController, AVCapturePhotoCaptureDelegate {
	
	@IBOutlet weak var previewView: UIView!
	var captureSession: AVCaptureSession?
	var capturePhotoOutput: AVCapturePhotoOutput?
	var videoPreviewLayer: AVCaptureVideoPreviewLayer?
	var capturedImage : UIImage?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Do any additional setup after loading the view.
		
		guard let captureDevice = AVCaptureDevice.default(for: AVMediaType.video) else {
			return
		}
		var input : AVCaptureDeviceInput!
		
		do {
			input  = try AVCaptureDeviceInput(device: captureDevice)
			
			// Get an instance of ACCapturePhotoOutput class
			capturePhotoOutput = AVCapturePhotoOutput()
			capturePhotoOutput?.isHighResolutionCaptureEnabled = true
			
			
		}
		catch {
			print("\n\nSomething went wrong...\n\n\n")
			return
		}
		
		captureSession = AVCaptureSession()
		captureSession?.addInput(input)
		// Set the output on the capture session
		captureSession?.addOutput(capturePhotoOutput!)
		
		videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
		videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
		videoPreviewLayer?.frame = view.layer.bounds
		previewView.layer.addSublayer(videoPreviewLayer!)
		captureSession?.startRunning()
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	@IBAction func cameraCapture(_ sender: UIButton) {
		// Make sure capturePhotoOutput is valid
		guard let capturePhotoOutput = self.capturePhotoOutput else {
			return
		}
		// Get an instance of AVCapturePhotoSettings class
		let photoSettings = AVCapturePhotoSettings()
		// Set photo settings for our need
		photoSettings.isAutoStillImageStabilizationEnabled = true
		photoSettings.isHighResolutionPhotoEnabled = true
		photoSettings.flashMode = .auto
		// Call capturePhoto method by passing our photo settings and a
		// delegate implementing AVCapturePhotoCaptureDelegate
		capturePhotoOutput.capturePhoto(with: photoSettings, delegate: self)
	}
	
	
	// MARK: - Navigation
	
	// In a storyboard-based application, you will often want to do a little preparation before navigation
	/*
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
	// Get the new view controller using segue.destinationViewController.
	// Pass the selected object to the new view controller.
	}
	*/
	@IBAction func backButton(_ sender: UIButton) {
		performSegue(withIdentifier: "cancelledPhoto", sender: self)
	}
	
	
	
	
	
	func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
		//print("Got a photo!")
		guard let imageData = photo.cgImageRepresentation() else {
			print("Error parsing photo")
			return
		}
		
		//print("Captured data has metadata: \(photo.metadata)")
		
		let CGImg = imageData.takeUnretainedValue()
				
		let rawImage = UIImage.init(cgImage: CGImg)
		
		//print("Raw image has size \(rawImage.size)")
		
		//This is just a hack. The imported image is sideways, so this should force it to be upright again
		capturedImage = UIImage(cgImage: rawImage.cgImage!, scale: rawImage.scale, orientation: UIImageOrientation.right)
		
		//print("Final image has size \(String(describing: capturedImage?.size))")
		
		performSegue(withIdentifier: "tookPhoto", sender: self)
	}
}
