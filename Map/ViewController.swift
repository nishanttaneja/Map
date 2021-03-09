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
    private var detailedAnnotationVC = DetailedAnnotationViewController(nibName: "DetailedAnnotationViewController", bundle: nil)
    
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
    private var location: CLLocation? {
        willSet {
            guard newValue != nil else { return }
            updateRegion(to: MKCoordinateRegion(center: newValue!.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000))
            
        }
    }
    private var currentRegion: MKCoordinateRegion {
        get { mapView.region }
        set { mapView.setRegion(newValue, animated: true) }
    }
    
    // IBActions
    @IBAction private func infoButtonAction(_ sender: UIButton) {}
    
    @IBAction private func currentLocationButtonAction(_ sender: UIButton) {
        requestCurrentLocation = !requestCurrentLocation
    }
}

//MARK:- MapView SupportingMethods
private extension ViewController {
    func updateRegion(to newRegion: MKCoordinateRegion) {
        currentRegion = newRegion
    }
}

//MARK:- MKMapViewDelegate
extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        print(#function)
    }
    func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
        print(#function)
    }
    func locationManagerDidResumeLocationUpdates(_ manager: CLLocationManager) {
        print(#function)
    }
}

//MARK:- CLLocationManagerDelegate
extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print(#function, mapView.userLocation.coordinate)
        guard let lastLocation = locations.last else { return }
        if location != nil {
            if lastLocation.coordinate.latitude != location!.coordinate.latitude,
               lastLocation.coordinate.longitude != location!.coordinate.longitude {
                location = lastLocation
            } else {
                updateRegion(to: MKCoordinateRegion(center: location!.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000))
            }
        } else {
            location = lastLocation
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse: requestCurrentLocation = true
        default: requestCurrentLocation = false
        }
    }
}

//MARK:- UIResponders
extension ViewController {
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        requestCurrentLocation = false
    }
}

//MARK:- View Lifecycle
extension ViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        infoAndCurrentLocationStackView.configureUI()
        locationManager.delegate = self
        mapView.showsUserLocation = true
        configureDetailedAnnotationViewController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        requestCurrentLocation = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        requestCurrentLocation = false
    }
}

//MARK:- DetailedAnnotationViewController
extension ViewController {
    private func configureDetailedAnnotationViewController() {
        detailedAnnotationVC.view.frame = CGRect(x: 0, y: mapView.frame.height - 70, width: view.frame.width, height: view.frame.height - 80)
        addChild(detailedAnnotationVC)
        view.addSubview(detailedAnnotationVC.view)
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
