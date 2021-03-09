//
//  ViewController.swift
//  Map
//
//  Created by Nishant Taneja on 06/03/21.
//

import MapKit

@objc protocol MapViewGestureRecognizerDelegate: class {
    func handleMapViewTapGestureRecognizer(_ recognizer: UITapGestureRecognizer)
    func handleMapViewPanGestureRecognizer(_ recognizer: UIPanGestureRecognizer)
}

class ViewController: UIViewController {
    // IBOutlets
    @IBOutlet private weak var mapView: MKMapView!
    @IBOutlet private weak var infoAndCurrentLocationStackView: UIStackView!
    @IBOutlet private weak var infoButton: UIButton!
    @IBOutlet private weak var currentLocationButton: UIButton!
    private var overlayVC = OverlayViewController(nibName: "OverlayViewController", bundle: nil)
    var visualEffectView = UIVisualEffectView()
    
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
extension ViewController: MKMapViewDelegate {}

//MARK:- CLLocationManagerDelegate
extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
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
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        super.touchesBegan(touches, with: event)
//        print(#function)
//    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        if requestCurrentLocation { requestCurrentLocation = false }
        if overlayVC.currentCardState == .fullyExpanded { overlayVC.currentCardState = .expanded }
    }
}

//MARK:- View Lifecycle
extension ViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        infoAndCurrentLocationStackView.configureUI()
        locationManager.delegate = self
        mapView.showsUserLocation = true
        configureVisualEffectView()
        configureOverlayViewController()
        addGestureRecognizers()
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

//MARK:- VisualEffectView
extension ViewController: VisualEffectViewDelegate {
    private func configureVisualEffectView() {
        visualEffectView.frame = view.frame
        visualEffectView.isUserInteractionEnabled = false
        view.addSubview(visualEffectView)
    }
}

//MARK:- OverlayViewController
extension ViewController {
    private func configureOverlayViewController() {
        overlayVC.view.frame = CGRect(x: 0, y: view.frame.height - 90, width: view.frame.width, height: view.frame.height - 60)
        overlayVC.gestureRecognizerDelegate = self
        overlayVC.visualEffectViewDelegate = self
        addChild(overlayVC)
        view.addSubview(overlayVC.view)
    }
}

//MARK:- OverlayGestureRecognizerDelegate
extension ViewController: OverlayGestureRecognizerDelegate {
    func handleOverlayTapGestureRecognizer(_ recognizer: UITapGestureRecognizer) {
        overlayVC.handleTapGestureRecognizer(recognizer)
    }
    
    func handleOverlayPanGestureRecognizer(_ recognizer: UIPanGestureRecognizer) {
        overlayVC.handlePanGestureRecognizer(recognizer)
    }
}

//MARK:- MapViewGestureRecognizerDelegate
extension ViewController: MapViewGestureRecognizerDelegate {
    private func addGestureRecognizers() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleMapViewTapGestureRecognizer(_:)))
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleMapViewPanGestureRecognizer(_:)))
        mapView.addGestureRecognizer(tapGestureRecognizer)
        mapView.addGestureRecognizer(panGestureRecognizer)
    }
    
    func handleMapViewTapGestureRecognizer(_ recognizer: UITapGestureRecognizer) {
        if overlayVC.currentCardState == .fullyExpanded { overlayVC.currentCardState = .expanded }
    }
    
    func handleMapViewPanGestureRecognizer(_ recognizer: UIPanGestureRecognizer) {
        print(#function)
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
