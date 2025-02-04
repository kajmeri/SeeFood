//
//  ViewController.swift
//  SeeFood
//
//  Created by Krishna Ajmeri on 9/12/19.
//  Copyright © 2019 Krishna Ajmeri. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

	@IBOutlet weak var imageView: UIImageView!

	let imagePicker = UIImagePickerController()

	override func viewDidLoad() {
		super.viewDidLoad()

		imagePicker.delegate = self
		imagePicker.allowsEditing = false

		imagePicker.sourceType = .photoLibrary
//		imagePicker.sourceType = .camera
	}

	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

		if let userImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {

			imageView.image = userImage

			guard let ciImage = CIImage(image: userImage) else {
				fatalError("Could not convert image to CIImage")
			}

			detect(image: ciImage)

		}

		imagePicker.dismiss(animated: true, completion: nil)

	}

	func detect(image: CIImage) {

		guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {
			fatalError("Loading CoreML Model failed")
		}

		let request = VNCoreMLRequest(model: model) { (request, error) in
			guard let results = request.results as? [VNClassificationObservation] else {
				fatalError("Model failed to process image")
			}

			if let firstResult = results.first {
				if firstResult.identifier.contains("hotdog") {
					self.navigationItem.title = "Hotdog!"
				} else {
					self.navigationItem.title = "Not a hotdog!"
				}
			}
		}

		let handler = VNImageRequestHandler(ciImage: image)

		do {
			try handler.perform([request])
		} catch {
			print(error)
		}
	}

	@IBAction func cameraTapped(_ sender: UIBarButtonItem) {

		present(imagePicker, animated: true, completion: nil)

	}

}

