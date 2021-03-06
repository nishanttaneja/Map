//
//  ViewController.swift
//  Map
//
//  Created by Nishant Taneja on 06/03/21.
//

import MapKit

class ViewController: UIViewController {
    // IBOutlets
    @IBOutlet private weak var mapView: MKMapView!
    @IBOutlet private weak var infoAndCurrentLocationStackView: UIStackView!
    @IBOutlet private weak var infoButton: UIButton!
    @IBOutlet private weak var currentLocationButton: UIButton!
    
    // Variables | Constants
    private var locationManager = CLLocationManager()
    private var hasLocationAccess: Bool {
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways: return true
        default:
            locationManager.requestWhenInUseAuthorization()
            return false
        }
    }
    private var requestCurrentLocation: Bool = false {
        willSet {
            guard hasLocationAccess else {
                print("location access is not authorised")
                return
            }
            guard newValue else {
                // Cancel request for current location
                locationManager.stopUpdatingLocation()
                currentLocationButton.setImage(UIImage(systemName: "location"), for: .normal)
                return
            }
            // Request Current Location
            locationManager.startUpdatingLocation()
            currentLocationButton.setImage(UIImage(systemName: "location.fill"), for: .normal)
        }
    }
    private var currentLocation: CLLocation?
    
    // IBActions
    @IBAction private func infoButtonAction(_ sender: UIButton) {}
    
    @IBAction private func currentLocationButtonAction(_ sender: UIButton) {
        requestCurrentLocation = !requestCurrentLocation
    }
}

//MARK:- CLLocationManagerDelegate
extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let lastLocation = locations.last else { return }
        if currentLocation != nil {
            if lastLocation.coordinate.latitude != currentLocation!.coordinate.latitude,
               lastLocation.coordinate.longitude != currentLocation!.coordinate.longitude {
                currentLocation = lastLocation
            }
        } else {
            currentLocation = lastLocation
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse: requestCurrentLocation = true
        default: requestCurrentLocation = false
        }
    }
}

//MARK:- View Lifecycle
extension ViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        infoAndCurrentLocationStackView.configureUI()
        locationManager.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        requestCurrentLocation = true
    }
}

//MARK:- UIStackView
fileprivate extension UIStackView {
    /// Configures basic UI. Includes adding Shadow and CornerRadius.
    func configureUI() {
        layer.cornerRadius = frame.height/8
        layer.shadowRadius = 1
        layer.shadowColor = UIColor.systemGray4.cgColor
        layer.shadowOpacity = 1
        layer.shadowOffset = .zero
    }
}
