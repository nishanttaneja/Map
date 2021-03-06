//
//  ViewController.swift
//  Map
//
//  Created by Nishant Taneja on 06/03/21.
//

import UIKit
import MapKit

class ViewController: UIViewController {
    // IBOutlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var infoAndCurrentLocationStackView: UIStackView!
    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var currentLocationButton: UIButton!
    
    // Variables | Constants
    
    
    // IBActions
    @IBAction func infoButtonAction(_ sender: UIButton) {}
    
    @IBAction func currentLocationButtonAction(_ sender: UIButton) {}
}

//MARK:- View Lifecycle
extension ViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        infoAndCurrentLocationStackView.configureUI()
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
