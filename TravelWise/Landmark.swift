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

class Landmark {
    var landmarkName: String
    var landmarkHistory: String
    var coordinate: CLLocationCoordinate2D
    var createdOn: Date
    var postingUserID: String
    var documentID: String
    
    var latitude: CLLocationDegrees {
        return coordinate.latitude
    }

    var longitude: CLLocationDegrees {
        return coordinate.longitude
    }
    
    var dictionary: [String: Any] {
        let timeIntervalDate = createdOn.timeIntervalSince1970
        return ["landmarkName": landmarkName, "landmarkHistory": landmarkHistory, "latitude": latitude, "longitude": longitude, "createdOn": timeIntervalDate, "postingUserID": postingUserID, "documentID": documentID]
    }
    
    init(landmarkName: String, landmarkHistory: String, coordinate: CLLocationCoordinate2D, createdOn: Date, postingUserID: String, documentID: String) {
        self.landmarkName = landmarkName
        self.landmarkHistory = landmarkHistory
        self.coordinate = coordinate
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
        let timeIntervalDate = dictionary["createdOn"] as! TimeInterval? ?? TimeInterval()
        let createdOn = Date(timeIntervalSince1970: timeIntervalDate)
        let postingUserID = dictionary["postingUserID"] as! String? ?? ""
        
        
        self.init(landmarkName: landmarkName, landmarkHistory: landmarkHistory, coordinate: coordinate, createdOn: createdOn, postingUserID: postingUserID, documentID: "")
    }
    
    convenience init() {
        self.init(landmarkName: "", landmarkHistory: "", coordinate: CLLocationCoordinate2D(), createdOn: Date(), postingUserID: "", documentID: "")
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
    
}

