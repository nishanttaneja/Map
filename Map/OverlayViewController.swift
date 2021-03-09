//
//  OverlayViewController.swift
//  Map
//
//  Created by Nishant Taneja on 09/03/21.
//

import UIKit

@objc protocol OverlayGestureRecognizerDelegate: class {
    func handleOverlayTapGestureRecognizer(_ recognizer: UITapGestureRecognizer)
    func handleOverlayPanGestureRecognizer(_ recognizer: UIPanGestureRecognizer)
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
        willSet {
            if newValue != .fullyExpanded {
                if searchBar.isFirstResponder {
                    searchBar.showsCancelButton = false
                    searchBar.resignFirstResponder()
                }
            }
            startAnimators(for: newValue)
        }
    }
    private var runningAnimators = [UIViewPropertyAnimator]()
}

//MARK:- UISearchBarDelegate
extension OverlayViewController: UISearchBarDelegate {
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        if currentCardState != .fullyExpanded {
            currentCardState = .fullyExpanded
        }
        searchBar.showsCancelButton = true
        return true
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        currentCardState = .expanded
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
        return newYOrigin < 40 ? 40 : newYOrigin
    }
}

//MARK:- Animators
extension OverlayViewController {
    private func startAnimators(for state: OverlayCardState) {
        guard runningAnimators.isEmpty else {
            print(#function, false)
            return
        }
        let frameAnimator = animator(ofType: .frame, forState: state)
        let cornerRadiusAnimator = animator(ofType: .cornerRadius, forState: state)
        frameAnimator.startAnimation()
        cornerRadiusAnimator.startAnimation()
        runningAnimators.append(contentsOf: [frameAnimator, cornerRadiusAnimator])
    }
    
    private func animator(ofType type: AnimatorType, forState overlayCardState: OverlayCardState) -> UIViewPropertyAnimator {
        var animator = UIViewPropertyAnimator()
        switch type {
        case .frame:
            animator = UIViewPropertyAnimator(duration: 0.5, dampingRatio: 1, animations: { [weak self] in
                guard self != nil else { return }
                self!.view.frame.origin.y = self!.yOrigin(for: overlayCardState)
            })
            animator.addCompletion { [weak self] _ in
                self?.runningAnimators.removeAll()
            }
        case .cornerRadius:
            animator = UIViewPropertyAnimator(duration: 0.5, curve: .linear, animations: { [weak self] in
                guard self != nil else { return }
                self!.view.layer.cornerRadius = self!.height(for: overlayCardState)/40
            })
        }
        return animator
    }
    
    private enum AnimatorType {
        case frame, cornerRadius
    }
}


//MARK:- View LifeCycle
extension OverlayViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let tapGestureRecognizer = UITapGestureRecognizer(target: gestureRecognizerDelegate, action: #selector(gestureRecognizerDelegate?.handleOverlayTapGestureRecognizer(_:)))
        let panGestureRecognizer = UIPanGestureRecognizer(target: gestureRecognizerDelegate, action: #selector(gestureRecognizerDelegate?.handleOverlayPanGestureRecognizer(_:)))
        draggableView.addGestureRecognizer(tapGestureRecognizer)
        draggableView.addGestureRecognizer(panGestureRecognizer)
    }
}

//MARK:- GestureRecognizer: DefaultImplementation
@objc extension OverlayViewController {
    /// Execute this method to perform default operations for UITapGestureRecognizer.
    func handleTapGestureRecognizer(_ recognizer: UITapGestureRecognizer) {
        switch currentCardState {
        case .collapsed: currentCardState = .expanded
        case .expanded: currentCardState = .fullyExpanded
        case .fullyExpanded: currentCardState = .collapsed
        }
    }
    
    /// Execute this method to perform default operations for UIPanGestureRecognizer.
    func handlePanGestureRecognizer(_ recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began: print("began")
        case .changed: print("changed")
        case .ended: print("ended")
        default: break
        }
    }
}
