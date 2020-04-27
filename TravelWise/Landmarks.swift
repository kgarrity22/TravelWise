//
//  Landmarks.swift
//  TravelWise
//
//  Created by Kathleen Garrity.
//  Copyright © 2020 Kathleen Garrity. All rights reserved.
//

import Foundation
import Firebase

class Landmarks {
    var landmarkArray: [Landmark] = []
    var db: Firestore!
    
    init() {
        db = Firestore.firestore()
    }
    
    func loadData(completed: @escaping () -> ())  {
        db.collection("landmarks").addSnapshotListener { (querySnapshot, error) in
            guard error == nil else {
                print("*** ERROR: adding the snapshot listener \(error!.localizedDescription)")
                return completed()
            }
            self.landmarkArray = []
            // there are querySnapshot!.documents.count documents in the landmarks snapshot
            for document in querySnapshot!.documents {
              // You'll have to be sure you've created an initializer in the singular class (Spot, below) that acepts a dictionary.
                let landmark = Landmark(dictionary: document.data())
                landmark.documentID = document.documentID
                self.landmarkArray.append(landmark)
            }
            completed()
        }
    }
}
