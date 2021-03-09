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

enum OverlayCardState {
    case collapsed, expanded, fullyExpanded
}

class OverlayViewController: UIViewController {
    // IBOutlets
    @IBOutlet weak private var draggableView: UIView!
    @IBOutlet weak private var searchBar: UISearchBar!
    @IBOutlet weak private var collectionView: UICollectionView!
    @IBOutlet weak private var separatorLabel: UILabel!
    @IBOutlet weak private var tableView: UITableView!
    
    // Delegates
    weak var gestureRecognizerDelegate: OverlayGestureRecognizerDelegate?
    
    // Variables
    var currentCardState: OverlayCardState = .collapsed {
        didSet {
            let animator = self.animator(ofType: .frameUpdate, forState: currentCardState)
            animator.startAnimation()
        }
    }
}

//MARK:- OverlayCard: SupportingMethods
extension OverlayViewController {
    private func height(for overlayCardState: OverlayCardState) -> CGFloat {
        switch overlayCardState {
        case .collapsed: return draggableView.frame.height + 20
        case .expanded: return collectionView.frame.height + draggableView.frame.height
        case .fullyExpanded: return tableView.frame.height + collectionView.frame.height + draggableView.frame.height
        }
    }
    private func yOrigin(for overlayCardState: OverlayCardState) -> CGFloat {
        let newYOrigin: CGFloat = UIScreen.main.bounds.height - height(for: overlayCardState)
        return newYOrigin < 80 ? 80 : newYOrigin
    }
}

//MARK:- Animators
extension OverlayViewController {
    private enum AnimatorType {
        case frameUpdate
    }
    
    private func animator(ofType type: AnimatorType, forState overlayCardState: OverlayCardState) -> UIViewPropertyAnimator {
        var animator = UIViewPropertyAnimator()
        switch type {
        case .frameUpdate:
            animator = UIViewPropertyAnimator(duration: 0.5, dampingRatio: 1, animations: {
                self.view.frame.origin.y = self.yOrigin(for: overlayCardState)
            })
        }
        return animator
    }
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
