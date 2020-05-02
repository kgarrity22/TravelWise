//
//  LandmarkDetailTableViewController.swift
//  TravelWise
//
//  Created by Kathleen Garrity.
//  Copyright © 2020 Kathleen Garrity. All rights reserved.
//

import UIKit
import Firebase
import AVKit
import CoreLocation
import GooglePlaces
import MapKit

class LandmarkDetailTableViewController: UITableViewController {

    @IBOutlet weak var landmarkImageView: UIImageView!
    @IBOutlet weak var landmarkNameLabel: UILabel!
    @IBOutlet weak var landmarkHistoryTextView: UITextView!
    @IBOutlet weak var mapView: MKMapView!
    
    
    var landmark: Landmark!
    
    var regionDistance: CLLocationDistance = 100_000
    
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
        
        // if we have just chosen an image and are coming from add image
        if landmarkImage != nil {
            self.landmark.placeImage = landmarkImage
            self.landmarkNameLabel.text = landmarkName
        } else {
            landmark.loadImage {
                self.landmarkImageView.image = self.landmark.placeImage
            }
        }
        
        
        
        let region = MKCoordinateRegion(center: landmark.coordinate, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
        mapView.setRegion(region, animated: true)
        
        // if nobody has entered anything yet, put a message in there
        if landmarkHistoryTextView.text == "Nobody has entered historical information yet. Be the first to contribute!" {
            landmarkHistoryTextView.isEditable = true
        } else {
            landmarkHistoryTextView.isEditable = false
        }
        
        
        updateUserInterface()
        
        
    }
    
    
    func updateUserInterface() {
        detectCloudLandmarks(image: landmarkImage)
        
        landmarkNameLabel.text = landmark.landmarkName
        landmarkHistoryTextView.text = landmark.landmarkHistory
        landmarkImageView.image = landmark.placeImage
        
        updateMap()
    }
    
    func updateMap() {
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotation(landmark)
        mapView.setCenter(landmark.coordinate, animated: true)
    }
    
    func updateFromUserInterface() {
        landmark.landmarkName = landmarkNameLabel.text!
        landmark.landmarkHistory = landmarkHistoryTextView.text
        //landmarkImage = landmarkImageView.image
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
                self.landmark.saveImage { (success) in
                    if !success {
                        print("WARNING: Could not save image")
                    }
                    self.leaveViewController()
                }
                
            } else {
                print("*** ERROR: Couldn't leave this view controller because data wasn't saved.")
            }
        }
        
    }
    
    
    func detectCloudLandmarks(image: UIImage?) {
        guard let image = image else {return}
        
        let imageMetadata = VisionImageMetadata()
        
        //self.landmark.placeImage = image
        
        // initialize a visionimage with input image
        let visionImage = VisionImage(image: image)
        visionImage.metadata = imageMetadata
        
        // create landmark detector
        let options = VisionCloudDetectorOptions()
        options.modelType = .latest
        options.maxResults = 20
        
        // initialize landmark detector
        let cloudDetector = vision.cloudLandmarkDetector(options: options)
        
        cloudDetector.detect(in: visionImage) { landmarks, error in
            guard error == nil, let landmarks = landmarks, !landmarks.isEmpty else {
                let errorString = error?.localizedDescription ?? "unknown error"
                self.resultsText = "Cloud landmark detection failed with error \(errorString)"
                
                return
            }
            
            // recognized landmarks
            print("🏵🏵🏵🏵 Landmarks: \(landmarks)")
            
            self.landmarkNameLabel.text = landmarks[0].landmark ?? "no name"
            self.landmark.landmarkName = landmarks[0].landmark ?? "no name"
            self.landmarkName = landmarks[0].landmark ?? "no name"
//            self.landmark.landmarkName =
//            self.landmark.coordinate.latitude = CLLocationDegrees(landmarks[0].locations![0].latitude!)
//            self.landmark.coordinate.longitude = CLLocationDegrees(landmarks[0].locations![0].longitude!)
            
            // update the coordinate var
            self.landmark.coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(landmarks[0].locations![0].latitude!), longitude: CLLocationDegrees(landmarks[0].locations![0].longitude!))
            
            self.landmarkNameLabel.text = self.landmark.landmarkName
            self.landmarkHistoryTextView.text = self.landmark.landmarkHistory
            //self.landmarkImageView.image = self.landmark.placeImage
            self.updateMap()
            
            
            //print("Landmark name: \(self.landmarkNameLabel.text!)")
            print("Landmark location: 🌎 latitude: \(String(describing: landmarks[0].locations![0].latitude!)), longitude: \(String(describing: landmarks[0].locations![0].longitude!))")
            
    
            //self.landmarkName = landmarks[0].landmark ?? "Unknown Landmark"
            
        }
        
        
    }
    

}
