//
//  ViewController.swift
//  Mapbox
//
//  Created by Manan Bhatia on 18/03/24.
//

import UIKit
import MapboxMaps

class ViewController: UIViewController {

    internal var mapView: MapView!
    let mapStyles: [String] = ["mapbox://styles/mapbox/streets-v11", "mapbox://styles/mapbox/satellite-v9", "mapbox://styles/mapbox/satellite-streets-v11"]
    
    let tabBar = UITabBar()
    let centerUserLocationButton = UIButton(type: .system)
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupMapView()
        setupTabBar()
        highlightButton(at: 0) // Highlight "Streets" button initially
        mapView.location.delegate = self
               mapView.location.options.activityType = .other
               mapView.location.options.puckType = .puck2D()
               mapView.location.locationProvider.startUpdatingLocation()
               
        mapView.mapboxMap.onNext(event: .mapLoaded) { [self]_ in
                   self.locationUpdate(newLocation: mapView.location.latestLocation!)
               }
        
        // Add long press gesture recognizer to the map view
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        mapView.addGestureRecognizer(longPress)
    }

    func setupMapView() {
        mapView = MapView(frame: view.bounds)
        let cameraOptions = CameraOptions(center: CLLocationCoordinate2D(latitude: 39.5, longitude: -98.0), zoom: 2, bearing: 0, pitch: 0)
        mapView.mapboxMap.setCamera(to: cameraOptions)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)
    }

    func setupTabBar() {
        view.addSubview(tabBar)
        tabBar.translatesAutoresizingMaskIntoConstraints = false
        tabBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        tabBar.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tabBar.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true

        let streetsItem = UITabBarItem(title: "Streets", image: UIImage(systemName: "map.fill"), tag: 0)
        let satelliteItem = UITabBarItem(title: "Satellite", image: UIImage(systemName: "globe"), tag: 1)
        let hybridItem = UITabBarItem(title: "Hybrid", image: UIImage(systemName: "globe.americas.fill"), tag: 2)
        let centerItem = UITabBarItem(title: "Locate Me", image: UIImage(systemName: "location.magnifyingglass"), tag: 3)

        tabBar.setItems([streetsItem, satelliteItem, hybridItem, centerItem], animated: false)
        tabBar.delegate = self
    }

    func changeMapStyle(to styleURI: String) {
        mapView.mapboxMap.style.uri = StyleURI(rawValue: styleURI)
    }
    
    func highlightButton(at index: Int) {
        
        guard let item = tabBar.items?[index] else { return }
        tabBar.selectedItem = item
    }
    
    @objc func centerMapAtUserLocation() {
           if let userLocation = mapView.location.latestLocation {
               mapView.camera.fly(to: CameraOptions(center: userLocation.coordinate, zoom: 14.0), duration: 1.0)
           } else {
               // Handle if user location is not available
               print("User location is not available.")
           }
       }
    
    // Handle long press gesture
    @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else { return }
        
        let touchLocation = gesture.location(in: mapView)
        let coordinate = mapView.mapboxMap.coordinate(for: touchLocation)
        
        // Add marker at the touched location
        addMarker(at: coordinate)
    }

    // Add marker at a specific coordinate
    func addMarker(at coordinate: CLLocationCoordinate2D) {
        var pointAnnotation = PointAnnotation(coordinate: coordinate)
        if let image = UIImage(systemName: "pin.fill"){
            pointAnnotation.image = .init(image: image.withTintColor(.red), name: "pin")
        } else {
            // Handle the case where the image is nil
            print("Image named 'mappin' not found.")
        }

        // Create the `PointAnnotationManager`, which will be responsible for handling this annotation
        let pointAnnotationManager = mapView.annotations.makePointAnnotationManager()

        // Add the annotation to the manager in order to render it on the map.
        pointAnnotationManager.annotations = [pointAnnotation]
    }
}

extension ViewController: UITabBarDelegate {
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        switch item.tag {
        case 0:
            changeMapStyle(to: mapStyles[0])
        case 1:
            changeMapStyle(to: mapStyles[1])
        case 2:
            changeMapStyle(to: mapStyles[2])
        case 3:
            centerMapAtUserLocation()
        default:
            break
        }
    }
}

extension ViewController: LocationPermissionsDelegate, LocationConsumer {
    func locationUpdate(newLocation: MapboxMaps.Location) {
        mapView.camera.fly(to: CameraOptions(center: newLocation.coordinate, zoom: 14.0), duration: 2.0)
    }
}

