//
//  driverTableViewController.swift
//  Ride Surfer
//
//  Created by Mark on 16/03/2019.
//  Copyright © 2019 Mark-Attila Nagy. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import MapKit

class driverTableViewController: UITableViewController, CLLocationManagerDelegate {

    var rideRequests : [DataSnapshot] = []
    var locationManager = CLLocationManager()
    var userLocation = CLLocationCoordinate2D()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        Database.database().reference().child("RideRequests").observe(.childAdded) { (snapshot) in
            
            if let rideReqDictionary = snapshot.value as? [String:AnyObject] {
                
                if let driverLat = rideReqDictionary["driverLat"] as? Double {
                    
                    
                } else {
                    
                    self.rideRequests.append(snapshot)
                    self.tableView.reloadData()
                }
                
            }
            
        }
        
        Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { (Timer) in
            self.tableView.reloadData()
        }
        
    }

    // MARK: - Table view data source
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let coord = manager.location?.coordinate {
            
            userLocation = coord
            
        }
        
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rideRequests.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "rideRequestCell", for: indexPath)
        
        let snapshot = rideRequests[indexPath.row]
        
        if let rideReqDictionary = snapshot.value as? [String:AnyObject] {
            
            if let email = rideReqDictionary["email"] as? String {
                
                if let lat = rideReqDictionary["lat"] as? Double {
                    
                    if let lon = rideReqDictionary["lon"] as? Double {
                        
                        let driverCLLocation = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
                        let riderLocation = CLLocation(latitude: lat, longitude: lon)
                        let distance = driverCLLocation.distance(from: riderLocation) / 1000
                        let roundedDistance = round(distance * 100) / 100
                        
                        cell.textLabel?.text = "\(email) - \(roundedDistance)km away"
                        cell.textLabel?.textColor = .white
                        
                    }
                    
                }
                
            }
            
        }
        
        return cell
    }

    @IBAction func logOut(_ sender: Any) {
        
        try? Auth.auth().signOut()
        navigationController?.dismiss(animated: true, completion: nil)
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let snapshot = rideRequests[indexPath.row]
        
        performSegue(withIdentifier: "acceptRideSegue", sender: snapshot)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let acceptVC = segue.destination as? acceptRideViewController {
            
            if let snapshot = sender as? DataSnapshot {
                
                if let rideReqDictionary = snapshot.value as? [String:AnyObject] {
                    
                    if let email = rideReqDictionary["email"] as? String {
                        
                        if let lat = rideReqDictionary["lat"] as? Double {
                            
                            if let lon = rideReqDictionary["lon"] as? Double {
                                
                                acceptVC.requestEmail = email
                                
                                let location = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                                
                                acceptVC.requestLocation = location
                                
                                acceptVC.driverLocation = userLocation
                            }
                        }
                    }
                }
            }
        }
    }
    
}
