//
//  riderViewController.swift
//  Ride Surfer
//
//  Created by Mark on 11/03/2019.
//  Copyright © 2019 Mark-Attila Nagy. All rights reserved.
//

import UIKit
import MapKit
import FirebaseDatabase
import FirebaseAuth

class riderViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet var riderMapView: MKMapView!
    @IBOutlet var callARideButton: UIButton!
    
    var locationManager = CLLocationManager()
    var userLocation = CLLocationCoordinate2D()
    var rideHasBeenCalled = false
    var driverOnTheWay = false
    var driverLocation = CLLocationCoordinate2D()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        if let email = Auth.auth().currentUser?.email {
            
            Database.database().reference().child("RideRequests").queryOrdered(byChild: "email").queryEqual(toValue: email).observe(.childAdded, with: { (snapshot) in
                
                self.rideHasBeenCalled = true
                self.callARideButton.setTitle("Cancel Ride", for: .normal)
                
                Database.database().reference().child("RideRequests").removeAllObservers()
                
                if let rideReqDictionary = snapshot.value as? [String:AnyObject] {
                    
                    if let driverLat = rideReqDictionary["driverLat"] as? Double {
                        if let driverLon = rideReqDictionary["driverLon"] as? Double {
                            self.driverLocation = CLLocationCoordinate2D(latitude: driverLat, longitude: driverLon)
                            self.driverOnTheWay = true
                            self.displayDriverAndRider()
                            
                            if let email = Auth.auth().currentUser?.email {
                                
                                Database.database().reference().child("RideRequests").queryOrdered(byChild: "email").queryEqual(toValue: email).observe(.childChanged, with: { (snapshot) in
                                    
                                    
                                    if let rideReqDictionary = snapshot.value as? [String:AnyObject] {
                                        
                                        if let driverLat = rideReqDictionary["driverLat"] as? Double {
                                            if let driverLon = rideReqDictionary["driverLon"] as? Double {
                                                self.driverLocation = CLLocationCoordinate2D(latitude: driverLat, longitude: driverLon)
                                                self.driverOnTheWay = true
                                                self.displayDriverAndRider()
                                            }
                                        }
                                    }
                                })
                            }
                        }
                    }
                }
            })
        }
    }
    
    func displayDriverAndRider() {
        
        let driverCLLocation = CLLocation(latitude: driverLocation.latitude, longitude: driverLocation.longitude)
        let riderCLLocation = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
        let distance = driverCLLocation.distance(from: riderCLLocation) / 1000
        let roundedDistance = round(distance * 100) / 100
        callARideButton.setTitle("Your ride is \(roundedDistance)km away!", for: .normal)
        
        riderMapView.removeAnnotations(riderMapView.annotations)
        
        let latDelta = abs(driverLocation.latitude - userLocation.latitude) * 2 + 0.005
        let lonDelta = abs(driverLocation.longitude - userLocation.longitude) * 2 + 0.005
        
        let region = MKCoordinateRegion(center: userLocation, span: MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta))
        riderMapView.setRegion(region, animated: true)
        
        let riderAnnotation = MKPointAnnotation()
        riderAnnotation.coordinate = userLocation
        riderAnnotation.title = "Your location"
        riderMapView.addAnnotation(riderAnnotation)
        
        let driverAnnotation = MKPointAnnotation()
        driverAnnotation.coordinate = driverLocation
        driverAnnotation.title = "Your ride"
        riderMapView.addAnnotation(driverAnnotation)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let coord = manager.location?.coordinate {
            
            let center = CLLocationCoordinate2D(latitude: coord.latitude, longitude: coord.longitude)
            
            userLocation = center
            
            
            
            if rideHasBeenCalled {
                
                displayDriverAndRider()
            } else {
                
                let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
                
                riderMapView.setRegion(region, animated: true)
                riderMapView.removeAnnotations(riderMapView.annotations)
                
                let annotation = MKPointAnnotation()
                annotation.coordinate = center
                annotation.title = "You"
                riderMapView.addAnnotation(annotation)
            }
            
        }
        
    }
    
    @IBAction func callARide(_ sender: Any) {
        
        if !driverOnTheWay {
            
            if let email = Auth.auth().currentUser?.email {
                
                if rideHasBeenCalled {
                    
                    rideHasBeenCalled = false
                    callARideButton.setTitle("Call a Ride", for: .normal)
                    
                    Database.database().reference().child("RideRequests").queryOrdered(byChild: "email").queryEqual(toValue: email).observe(.childAdded, with: { (snapshot) in
                        
                        snapshot.ref.removeValue()
                        
                        Database.database().reference().child("RideRequests").removeAllObservers()
                        
                    })
                    
                } else {
                    
                    let rideRequestDictionary : [String:Any] = ["email":email,
                                                                "lat":userLocation.latitude,
                                                                "lon":userLocation.longitude]
                    
                    Database.database().reference().child("RideRequests").childByAutoId().setValue(rideRequestDictionary)
                    
                    rideHasBeenCalled = true
                    callARideButton.setTitle("Cancel Ride", for: .normal)
                    
                }
            }
        }
    }
    
    @IBAction func logOut(_ sender: Any) {
        
        try? Auth.auth().signOut()
        navigationController?.dismiss(animated: true, completion: nil)
        
    }
    
}
