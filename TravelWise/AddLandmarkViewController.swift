//
//  ViewController.swift
//  TravelWise
//
//  Created by Kathleen Garrity on 4/25/20.
//  Copyright © 2020 Kathleen Garrity. All rights reserved.
//

import UIKit
import AVFoundation
import Firebase

class AddLandmarkViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var libraryButton: UIButton!
    @IBOutlet weak var identifyButton: UIButton!
    
    var imagePicker = UIImagePickerController()

    var resultsTest = ""
    
    var imageToPass: UIImage!
    
    // I don't think this is necessary but unsure
    //    let options = VisionCloudDetectorOptions()
    //    options.modelType = .latest
    //    options.maxResults = 20
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // if we have chosen an image, change the buttons
        // otherwise keep them as is
        identifyButton.isHidden = true
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        // grab the image and store it in selectedImage
        let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        // update the image after the shift
        imageView.image = selectedImage
        
        dismiss(animated: true, completion: nil)
        identifyButton.isHidden = false
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    
    
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        present(alertController, animated: true, completion: nil)
        
    }
    
    @IBAction func libraryPressed(_ sender: UIButton) {
        
        
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        
        present(imagePicker, animated: true, completion: nil)
        
        
    }
    
    @IBAction func cameraPressed(_ sender: UIButton) {
        
        
        // check if camera is available, then present
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.sourceType = .camera
            imagePicker.delegate = self
            present(imagePicker, animated: true, completion: nil)
            
        } else {
            showAlert(title: "Camera Not Available", message: "This device does not have a camera")
        }
       
    
    }
    // image stuff here could potentially cause an issue
    @IBAction func identifyButtonPressed(_ sender: UIButton) {
        
        self.imageToPass = imageView.image
//        performSegue(withIdentifier: "AddLandmark", sender: self)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var viewController = segue.destination as! LandmarkDetailTableViewController
        viewController.landmarkImage = self.imageToPass
//        viewController.detectCloudLandmarks(image: self.imageToPass)
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        leaveViewController()
    }
    
    func leaveViewController() {
        let isPresentingInAddMode = presentingViewController is UINavigationController
        if isPresentingInAddMode {
            dismiss(animated: true, completion: nil)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
}




