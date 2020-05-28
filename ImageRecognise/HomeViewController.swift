//
//  ViewController.swift
//  ImageRecognise
//
//  Created by Qrati Labs on 5/27/20.
//  Copyright © 2020 Qrati Labs. All rights reserved.
//

import UIKit
import CoreML
import Vision

class HomeViewController: UIViewController {

    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var pickedImageView: UIImageView!
    
    @IBAction func cameraButtonTask(_ sender: UIBarButtonItem) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    let imagePicker = UIImagePickerController()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
    }

}

extension HomeViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    
    func detect(image: CIImage) {
        guard let model = try? VNCoreMLModel(for: CustomAnimalImageRecogniser().model) else { fatalError("Loading Core ML Model Faileds")}
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("Model failed to process image")
            }
            if let firstResult = results.first {
                print(firstResult)
                self.navigationItem.title = firstResult.identifier
            }
        }
        let handler = VNImageRequestHandler(ciImage: image)
        do {
            try handler.perform([request])
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let userPickedImage = info[.originalImage] as? UIImage {
            pickedImageView.image = userPickedImage
            guard let ciImage = CIImage(image: userPickedImage) else {
                fatalError("Unable to Convert to CIImage")
            }
            detect(image: ciImage)
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
}
