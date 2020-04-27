//
//  LandmarkInfoViewController.swift
//  TravelWise
//
//  Created by Kathleen Garrity on 4/26/20.
//  Copyright © 2020 Kathleen Garrity. All rights reserved.
//

import UIKit
import Firebase
import AVKit

class LandmarkInfoViewController: UIViewController {
    
    @IBOutlet weak var landmarkImageView: UIImageView!
    @IBOutlet weak var landmarkNameLabel: UILabel!
    @IBOutlet weak var landmarkDefinitionLabel: UILabel!
    @IBOutlet weak var landmarkHistoryTextView: UITextView!
    
    // to recieve chosen image from camera/library
    var landmarkImage: UIImage!
    
    // initialize firebase vision instance
    var vision = Vision.vision()
    
    // we'll see about this
    var resultsText = ""
    
    var landmarkName = ""
    
    var word = Word()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // receiving the chosen image from the camera or library
        landmarkImageView.image = landmarkImage
        
        detectCloudLandmarks(image: landmarkImage)
        
        // want to update the definition label after we've run the
        if self.landmarkName != "Unknown Landmark" {
            word.getData(wordToDefine: self.landmarkName) {
                DispatchQueue.main.async {
                    self.landmarkDefinitionLabel.text = self.word.definition
                }
            }
        }
        
    }
    
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//    }
    
    // view will appear?
    
    // view will disappear?
    
    
    
    func detectCloudLandmarks(image: UIImage?) {
        guard let image = image else {return}
        
        let imageMetadata = VisionImageMetadata()
        // the following is a function that we don't have access to.. do we need it?
        //imageMetadata.orientation = UIUtilities.
        
        // initialize a visionimage with input image
        let visionImage = VisionImage(image: image)
        visionImage.metadata = imageMetadata
        
        // create landmark detector
        // don't think I really need these options
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
            //let landmarkDict: [String: String] = [:]
            
            print("Landmark name: \(self.landmarkNameLabel.text!)")
            print("Landmark location: 🌎 latitude: \(String(describing: landmarks[0].locations![0].latitude!)), longitude: \(String(describing: landmarks[0].locations![0].longitude!))")
            
            self.landmarkNameLabel.text = landmarks[0].landmark ?? "no name"
            self.landmarkName = landmarks[0].landmark ?? "Unknown Landmark"
            
            
        }
    }
    
    
    
    func formatResults() {
        // update name label
        // update definition
        // update history
        
    }
    
    
}

