//
//  LandmarkInfoViewController.swift
//  TravelWise
//
//  Created by Kathleen Garrity on 4/26/20.
//  Copyright © 2020 Kathleen Garrity. All rights reserved.
//

import UIKit

class LandmarkInfoViewController: UIViewController {
    
    @IBOutlet weak var landmarkImageView: UIImageView!
    @IBOutlet weak var landmarkNameLabel: UILabel!
    @IBOutlet weak var landmarkDefinitionLabel: UILabel!
    @IBOutlet weak var landmarkHistoryTextView: UITextView!
    
    var landmarkImage: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        landmarkImageView.image = landmarkImage

        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    


}
