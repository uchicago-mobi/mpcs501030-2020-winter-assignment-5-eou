//
//  MapViewController.swift
//  Project5
//
//  Created by Hangyi Wang on 2020/2/12.
//  Copyright © 2020 Hangyi Wang. All rights reserved.
//
// Attribution: https://www.ioscreator.com/tutorials/mapkit-ios-tutorial
// Attribution: https://stackoverflow.com/questions/24045570/how-do-i-get-a-plist-as-a-dictionary-in-swift
// Attribution: https://www.latlong.net/place/chicago-il-usa-1855.html
// Attribution: https://stackoverflow.com/questions/35963128/swift-understanding-mark
// Attribution: https://stackoverflow.com/questions/23739659/how-to-auto-select-annotation-when-add-to-mapkit
// Attribution: https://stackoverflow.com/questions/6797096/delete-all-keys-from-a-nsuserdefaults-dictionary-ios/6797133#6797133
// Attribution: https://stackoverflow.com/questions/44876420/save-struct-to-userdefaults

import UIKit
import MapKit

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var annotationTitle: UILabel!
    @IBOutlet weak var annotationDesc: UILabel!
    
    @IBOutlet weak var addFavoriteButton: UIButton!
    
    // MARK: - Init DataManager Singleton
    let dataManager = DataManager.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        addFavoriteButton.addTarget(self, action: #selector(addFavoriteButtonTapped), for: .touchUpInside)
        
        mapView.showsCompass = false
        mapView.pointOfInterestFilter = .excludingAll
        
        // MARK: - Customize marker style
        mapView.register(PlaceMarkerView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        
        // MARK: - Init UserDefaults storage
        let favoritePlaces = Set<String>()
        UserDefaults.standard.set(try! PropertyListEncoder().encode(favoritePlaces), forKey:"favoritePlaces")
        
        // MARK: - Get region info from plist
        let plist = self.dataManager.loadAnnotationFromPlist(plistName: "Data") as! Dictionary<String, Any>
        
        let location: CLLocationCoordinate2D
        let span: MKCoordinateSpan
        
        let region = plist["region"] as! Array<Double>
        // Use default place stored in Data.plist
        if region.count == 4 {
            // Set chicago latitude and longitude
            location = CLLocationCoordinate2D(latitude: region[0], longitude: region[1])

            // Display area on mapView
            span = MKCoordinateSpan(latitudeDelta: region[2], longitudeDelta: region[3])
        } else {
            // If there is no default region info in Data.plist
            // Set chicago latitude and longitude
            location = CLLocationCoordinate2D(latitude: 41.881832, longitude: -87.623177)

            // Display area on mapView
            span = MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
        }
        
        let initRegion = MKCoordinateRegion(center: location, span: span)
        
        // Set init region range on map
        mapView.setRegion(initRegion, animated: true)
        
        // Put the places in data.places to the mapView
        let places = plist["places"] as! Array<Dictionary<String, Any>>
        for place in places {
            addPlaceToMap(place: place)
        }
        
        // If it is default info
        if region.count == 4 {
            // Focus on the default place
            focusPlaceOnMap(name: "Wrigley Field")
        } else {
            annotationTitle.text = "Select a place"
            annotationDesc.text = ""
        }
        
    }
    
    // MARK: - Save/Remove current place into/from user default storage
    @objc func addFavoriteButtonTapped(_ button: UIButton) {
        // MARK: Use UserDefaults to access data locally
        let placeName = annotationTitle.text!
        
        if let data = UserDefaults.standard.value(forKey:"favoritePlaces") as? Data {
            let favoritePlaceSet = try! PropertyListDecoder().decode(Set<String>.self, from: data)
            if !favoritePlaceSet.contains(placeName) {
                // Have not stored before, store it !
                self.dataManager.saveFavorites(placeName: placeName)
                addFavoriteButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
            } else {
                // Have stored before, remove it !
                self.dataManager.removeFavorite(placeName: placeName)
                addFavoriteButton.setImage(UIImage(systemName: "star"), for: .normal)
            }
        }
    }
    
    // MARK: - Add annotations
    func addPlaceToMap(place: Dictionary<String, Any>) {
        let coordinate = CLLocationCoordinate2DMake(place["lat"] as! CLLocationDegrees,
                                                    place["long"] as! CLLocationDegrees)
        let name = place["name"] as! String
        let desc = place["description"] as! String
        
        let annotation = Place(name: name, longDescription: desc)
        annotation.title = annotation.name
        annotation.subtitle = annotation.longDescription
        annotation.coordinate = coordinate
        
        // Add annotation to the mapView
        mapView.addAnnotation(annotation)
    }
    
    // MARK: - Focus on a specified place on mapView
    func focusPlaceOnMap(name: String) {
        for annotation in mapView.annotations {
            if annotation.title == name {
                mapView.selectAnnotation(annotation, animated: true)
                annotationTitle.text = annotation.title as? String
                annotationDesc.text = annotation.subtitle as? String
                
                let miles: Double = 20 * 50
                let zoomLocation = annotation.coordinate
                let viewRegion = MKCoordinateRegion.init(center: zoomLocation,
                                                         latitudinalMeters: miles,
                                                         longitudinalMeters: miles)
                
                // Set the this region on the map
                mapView.setRegion(viewRegion, animated: true)
                return
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? FavoritesViewController {
            destination.delegate = self
        }
    }
}


extension MapViewController: MKMapViewDelegate {
    // Change mapView when an annotation is selected
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        annotationTitle.text = (view.annotation?.title)!
        annotationDesc.text = (view.annotation?.subtitle)!
        
        let placeName = annotationTitle.text!
        
        // For favorite button style: check if it is a user's favorite place
        if let data = UserDefaults.standard.value(forKey:"favoritePlaces") as? Data {
            let favoritePlaceSet = try! PropertyListDecoder().decode(Set<String>.self, from: data)
            if favoritePlaceSet.contains(placeName) {
                addFavoriteButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
            } else {
                addFavoriteButton.setImage(UIImage(systemName: "star"), for: .normal)
            }
        }
    }
}

extension MapViewController: PlacesFavoritesDelegate {
    // Update the map view based on the favorite place that was passed in
    func favoritePlace(name: String) {
        focusPlaceOnMap(name: name)
    }
}
