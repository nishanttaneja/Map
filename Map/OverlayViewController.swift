//
//  OverlayViewController.swift
//  Map
//
//  Created by Nishant Taneja on 09/03/21.
//

import UIKit

@objc protocol OverlayGestureRecognizerDelegate: class {
    @objc func handleTapGestureRecognizer(_ recognizer: UITapGestureRecognizer)
}

class OverlayViewController: UIViewController {
    // IBOutlets
    @IBOutlet weak var draggableView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    // Delegates
    weak var gestureRecognizerDelegate: OverlayGestureRecognizerDelegate?
}

//MARK:- View LifeCycle
extension OverlayViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let tapGestureRecognizer = UITapGestureRecognizer(target: gestureRecognizerDelegate, action: #selector(gestureRecognizerDelegate?.handleTapGestureRecognizer(_:)))
        draggableView.addGestureRecognizer(tapGestureRecognizer)
    }
}
