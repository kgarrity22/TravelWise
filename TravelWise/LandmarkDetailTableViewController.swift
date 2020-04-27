//
//  LandmarkDetailTableViewController.swift
//  TravelWise
//
//  Created by Kathleen Garrity on 4/27/20.
//  Copyright © 2020 Kathleen Garrity. All rights reserved.
//

import UIKit
import Firebase
import AVKit

class LandmarkDetailTableViewController: UITableViewController {

    @IBOutlet weak var landmarkImageView: UIImageView!
    @IBOutlet weak var landmarkNameLabel: UILabel!
    @IBOutlet weak var landmarkHistoryTextView: UITextView!
    
    
    var landmark: Landmark!
    
    // will need an outlet for the map view

    // this is the variable that will recieve the chosen image when we click "Identify" in the addlandarkviewcontroller
    // this is the only item that this viewcontroller needs to recieve
    var landmarkImage: UIImage!
    
    
    
    var landmarkName = ""
    
    
    // initialize firebase vision instance
    var vision = Vision.vision()
    
    var resultsText = ""
    
        
    override func viewDidLoad() {
        super.viewDidLoad()

        if landmark == nil {
            landmark = Landmark()
        }
        updateUserInterface()
        
        
    }
    
    // don't think I need this function if I run the UI updates in the detection function
    func updateUserInterface() {
        // still need to update the image and the the map here, but don't have those set up yet
        landmarkNameLabel.text = landmark.landmarkName
        landmarkHistoryTextView.text = landmark.landmarkHistory
    }
    
    func updateFromUserInterface() {
        landmark.landmarkName = landmarkNameLabel.text!
        landmark.landmarkHistory = landmarkHistoryTextView.text
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
    
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        
        updateFromUserInterface()
        landmark.saveData { success in
            if success {
                self.leaveViewController()
            } else {
                print("*** ERROR: Couldn't leave this view controller because data wasn't saved.")
            }
        }
        
    }
    
    
    func detectCloudLandmarks(image: UIImage?) {
        guard let image = image else {return}
        
        let imageMetadata = VisionImageMetadata()
        
        // initialize a visionimage with input image
        let visionImage = VisionImage(image: image)
        visionImage.metadata = imageMetadata
        
        // create landmark detector
        let options = VisionCloudDetectorOptions()
        options.modelType = .latest
        options.maxResults = 5
        
        // initialize landmark detector
        let cloudDetector = vision.cloudLandmarkDetector(options: options)
        
        cloudDetector.detect(in: visionImage) { landmarks, error in
            guard error == nil, let landmarks = landmarks, !landmarks.isEmpty else {
                let errorString = error?.localizedDescription ?? "unknown error"
                self.resultsText = "Cloud landmark detection failed with error \(errorString)"
                // showResults()
                return
            }
            
            // recognized landmarks
            print("🏵🏵🏵🏵 Landmarks: \(landmarks)")
            self.landmarkNameLabel.text = landmarks[0].landmark ?? "no name"
            
            
            //print("Landmark name: \(self.landmarkNameLabel.text!)")
            print("Landmark location: 🌎 latitude: \(String(describing: landmarks[0].locations![0].latitude!)), longitude: \(String(describing: landmarks[0].locations![0].longitude!))")
            
            
            self.landmarkName = landmarks[0].landmark ?? "Unknown Landmark"
            
            
        }
    }
    

}
