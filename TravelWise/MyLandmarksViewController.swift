//
//  MyPlacesViewController.swift
//  TravelWise
//
//  Created by Kathleen Garrity.
//  Copyright © 2020 Kathleen Garrity. All rights reserved.
//

import UIKit
import CoreLocation
import Firebase
import FirebaseUI
import GoogleSignIn

class MyLandmarksViewController: UIViewController {
    
    var landmarks: Landmarks!
    var authUI:FUIAuth!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addBarButton: UIBarButtonItem!
    // create outlet for sign out button and disable when editing
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        authUI = FUIAuth.defaultAuthUI()
        authUI.delegate = self
        
        landmarks = Landmarks()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        landmarks.loadData {
            self.tableView.reloadData()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        signIn()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowLandmark" {
            let destination = segue.destination as! LandmarkDetailTableViewController
            let selectedPath = tableView.indexPathForSelectedRow!
            destination.landmark = landmarks.landmarkArray[selectedPath.row]
        }
    }

    
    func signIn() {
        let providers: [FUIAuthProvider] = [
            FUIGoogleAuth(),
        ]
        if authUI.auth?.currentUser == nil {
            self.authUI?.providers = providers
            let loginViewController = authUI.authViewController()
            loginViewController.modalPresentationStyle = .fullScreen
            present(loginViewController, animated: true, completion: nil)
        } else {
            tableView.isHidden = false
        }
    }
    
    @IBAction func signOutBarButtonPressed(_ sender: UIBarButtonItem) {
        do {
            try authUI!.signOut()
            print("^^^ Successfully signed out!")
            tableView.isHidden = true
            signIn()
        } catch {
            tableView.isHidden = true
            print("*** ERROR: Couldn't sign out")
        }
    }
    
    
    @IBAction func editButtonPressed(_ sender: UIBarButtonItem) {
        if tableView.isEditing {
            tableView.setEditing(false, animated: true)
            sender.title = "Edit"
            addBarButton.isEnabled = true
        } else {
            tableView.setEditing(true, animated: true)
            sender.title = "Done"
            addBarButton.isEnabled = false
            
        }
    }
    
    
}

extension MyLandmarksViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return landmarks.landmarkArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyPlacesCell", for: indexPath) as! LandmarksTableViewCell
        cell.cellLandmarkNameLabel.text = landmarks.landmarkArray[indexPath.row].landmarkName
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        
        //cell.cellCreatedOnLabel.text = formatter.string(from: landmarks.landmarkArray[indexPath.row].createdOn)
        cell.cellCreatedOnLabel.text = "4/29/20"
        
        landmarks.landmarkArray[indexPath.row].loadImage {
            cell.landmarkCellImageView.image = self.landmarks.landmarkArray[indexPath.row].placeImage
        }
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            landmarks.landmarkArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let itemToMove = landmarks.landmarkArray[sourceIndexPath.row]
        landmarks.landmarkArray.remove(at: sourceIndexPath.row)
        landmarks.landmarkArray.insert(itemToMove, at: destinationIndexPath.row)
    }
    
    
}

extension MyLandmarksViewController: FUIAuthDelegate {
    func application(_ app: UIApplication, open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        let sourceApplication = options[UIApplication.OpenURLOptionsKey.sourceApplication] as! String?
        if FUIAuth.defaultAuthUI()?.handleOpen(url, sourceApplication: sourceApplication) ?? false {
            return true
        }
        // other URL handling goes here.
        return false
    }
    
    func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?) {
        if let user = user {
            // Assumes data will be isplayed in a tableView that was hidden until login was verified so unauthorized users can't see data.
            tableView.isHidden = false
            print("^^^ We signed in with the user \(user.email ?? "unknown e-mail")")
        }
    }
    
    func authPickerViewController(forAuthUI authUI: FUIAuth) -> FUIAuthPickerViewController {
        
        // Create an instance of the FirebaseAuth login view controller
        let loginViewController = FUIAuthPickerViewController(authUI: authUI)
        
        // Set background color to white
        loginViewController.view.backgroundColor = UIColor.white
        
        // Create a frame for a UIImageView to hold our logo
        let marginInsets: CGFloat = 16 // logo will be 16 points from L and R margins
        let imageHeight: CGFloat = 225 // the height of our logo
        let imageY = self.view.center.y - imageHeight // places bottom of UIImageView in the center of the login screen
        let logoFrame = CGRect(x: self.view.frame.origin.x + marginInsets, y: imageY, width: self.view.frame.width - (marginInsets*2), height: imageHeight)
        
        // Create the UIImageView using the frame created above & add the "logo" image
        let logoImageView = UIImageView(frame: logoFrame)
        logoImageView.image = UIImage(named: "logo")
        logoImageView.contentMode = .scaleAspectFit // Set imageView to Aspect Fit
        loginViewController.view.addSubview(logoImageView) // Add ImageView to the login controller's main view
        return loginViewController
    }
}




