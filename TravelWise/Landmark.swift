//
//  Landmark.swift
//  TravelWise
//
//  Created by Kathleen Garrity on 4/27/20.
//  Copyright © 2020 Kathleen Garrity. All rights reserved.
//

import Foundation
import CoreLocation
import Firebase
import MapKit

class Landmark: NSObject, MKAnnotation {
    var landmarkName: String
    var landmarkHistory: String
    var coordinate: CLLocationCoordinate2D
    var placeImage: UIImage
    var placeImageUUID: String
    var createdOn: Date
    var postingUserID: String
    var documentID: String
    
    var latitude: CLLocationDegrees {
        return coordinate.latitude
    }

    var longitude: CLLocationDegrees {
        return coordinate.longitude
    }
    
    var title: String? {
        return landmarkName
    }
    
    
    
    var dictionary: [String: Any] {
        let timeIntervalDate = createdOn.timeIntervalSince1970
        return ["landmarkName": landmarkName, "landmarkHistory": landmarkHistory, "latitude": latitude, "longitude": longitude, "placeImageUUID": placeImageUUID,"createdOn": timeIntervalDate, "postingUserID": postingUserID, "documentID": documentID]
    }
    
    init(landmarkName: String, landmarkHistory: String, coordinate: CLLocationCoordinate2D, placeImage: UIImage, placeImageUUID: String, createdOn: Date, postingUserID: String, documentID: String) {
        self.landmarkName = landmarkName
        self.landmarkHistory = landmarkHistory
        self.coordinate = coordinate
        self.placeImage = placeImage
        self.placeImageUUID = placeImageUUID
        self.createdOn = createdOn
        self.postingUserID = postingUserID
        self.documentID = documentID
        
    }
    convenience init(dictionary: [String: Any]) {
        let landmarkName = dictionary["landmarkName"] as! String? ?? ""
        let landmarkHistory = dictionary["landmarkHistory"] as! String? ?? ""
        let latitude = dictionary["latitude"] as! CLLocationDegrees? ?? 0.0
        let longitude = dictionary["longitude"] as! CLLocationDegrees? ?? 0.0
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let placeImage = dictionary["placeImage"] as! String? ?? ""
        let placeImageUUID = dictionary["placeImageUUID"] as! String? ?? ""
        let timeIntervalDate = dictionary["createdOn"] as! TimeInterval? ?? TimeInterval()
        let createdOn = Date(timeIntervalSince1970: timeIntervalDate)
        let postingUserID = dictionary["postingUserID"] as! String? ?? ""
        
        
        self.init(landmarkName: landmarkName, landmarkHistory: landmarkHistory, coordinate: coordinate, placeImage: UIImage(), placeImageUUID: placeImageUUID,createdOn: createdOn, postingUserID: postingUserID, documentID: "")
    }
    
    convenience override init() {
        self.init(landmarkName: "", landmarkHistory: "", coordinate: CLLocationCoordinate2D(), placeImage: UIImage(), placeImageUUID: "", createdOn: Date(), postingUserID: "", documentID: "")
    }
    
    
    
    func saveData(completion: @escaping (Bool) -> ())  {
        let db = Firestore.firestore()
        // Grab the user ID
        guard let postingUserID = (Auth.auth().currentUser?.uid) else {
            print("*** ERROR: Could not save data because we don't have a valid postingUserID")
            return completion(false)
        }
        self.postingUserID = postingUserID
        // Create the dictionary representing data we want to save
        let dataToSave: [String: Any] = self.dictionary
        // if we HAVE saved a record, we'll have an ID
        if self.documentID != "" {
            let ref = db.collection("landmarks").document(self.documentID)
            ref.setData(dataToSave) { (error) in
                if let error = error {
                    print("ERROR: updating document \(error.localizedDescription)")
                    completion(false)
                } else { // It worked!
                    completion(true)
                }
            }
        } else { // Otherwise create a new document via .addDocument
            var ref: DocumentReference? = nil // Firestore will creat a new ID for us
            ref = db.collection("landmarks").addDocument(data: dataToSave) { (error) in
                if let error = error {
                    print("ERROR: adding document \(error.localizedDescription)")
                    completion(false)
                } else { // It worked! Save the documentID in Landmark’s documentID property
                    self.documentID = ref!.documentID
                    completion(true)
                }
            }
        }
    }
    
    func saveImage(completed: @escaping (Bool) -> ()) {
        let db = Firestore.firestore()
        let storage = Storage.storage()
        
        // convert immage to a Data type so it can be save in Firebase
        guard let imageToSave = self.placeImage.jpegData(compressionQuality: 0.5) else {
            print("ERROR: could not convert image to jpeg")
            completed(false)
            return
        }
        
        let uploadMetadata = StorageMetadata()
        uploadMetadata.contentType = "image/jpeg"
        
        // if there is no uuid, create one
        if placeImageUUID == "" {
            placeImageUUID = UUID().uuidString
        }
        
        // create a reference to upload storage with new UUID
        let storageRef = storage.reference().child(documentID).child(self.placeImageUUID)
        let uploadTask = storageRef.putData(imageToSave, metadata: uploadMetadata) { (metadata, error) in
            guard error == nil else {
                print("ERROR: during .putdata storage upload for reference \(storageRef). Error: \(error?.localizedDescription)")
                completed(false)
                return
            }
            print("👍 upload worked! Metadata is \(metadata)")
        }
        
        uploadTask.observe(.success) { (snapshot) in
            //
            let dataToSave = self.dictionary
            let ref = db.collection("landmarks").document(self.documentID)
            ref.setData(dataToSave) { (error) in
                if let error = error {
                    print("ERROR: saving document \(self.documentID) in success observer. Error = \(error.localizedDescription)")
                    completed(false)
                } else {
                    print("Document updated with ref ID: \(ref.documentID).")
                    completed(true)
                }
                
            }
        }
        
        uploadTask.observe(.failure) { (snapshot) in
            if let error = snapshot.error {
                print("ERROR: \(error.localizedDescription) upload task for file \(self.placeImageUUID)")
            }
            return completed(false)
        }
    }
    
    func loadImage(completed: @escaping () -> ()) {
        let storage = Storage.storage()
        let storageRef = storage.reference().child(self.documentID).child(self.placeImageUUID)
        
        storageRef.getData(maxSize: 5*1024*1024) { (data, error) in
            guard error == nil else {
                print("Error: Could not load image from bucket \(self.documentID) for the file \(self.placeImageUUID)")
                return completed()
            }
            guard let downloadedImage = UIImage(data: data!) else {
                print("Error: Could not convert data to image from bucket \(self.documentID) for the file \(self.placeImageUUID)")
                return completed()
            }
            self.placeImage = downloadedImage
            completed()
        }
    }
    
}

