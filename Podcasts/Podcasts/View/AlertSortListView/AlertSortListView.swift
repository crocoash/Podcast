//
//  AlertSortListViewController.swift
//  Podcasts
//
//  Created by Anton on 14.08.2023.
//

import UIKit

//MARK: - MyDataSource
@objc protocol AlertSortListViewDataSource: AnyObject {
    
}

@objc protocol AlertSortListViewDelegate: AnyObject {
    
}

class AlertSortListView: UIView {
    
    @IBOutlet private weak var closeImageView: UIImageView!
    @IBOutlet private weak var collectionView: UICollectionView!
    
    weak var dataSource: AlertSortListViewDataSource?
    weak var delegate: AlertSortListViewDelegate?
    weak var vc: UIViewController!
    
    //MARK: Variables
    private var alertSortListViewIsShowing = false
    
    private var gestureView: UIView?
    private var panGestureAnchorY: CGFloat?
    private var height: Double = 300
    private var y: Double {
        get { frame.origin.y }
        set { frame.origin.y = newValue }
    }
        
    lazy private var hidePositionY = vc.view.frame.height
    lazy private var showPositionY = vc.view.frame.height - height
    lazy private var positionForClosedY = showPositionY + height * 0.3

      
    typealias InputType = AlertSortListViewDelegate & AlertSortListViewDataSource & UIViewController
    
    //MARK: init
    init(vc: InputType) {
        
        super.init(frame: .zero)
        
        self.vc = vc
        self.delegate = vc
        self.dataSource = vc
        
        configureView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    //MARK: Actions
    @objc func showOrHideAlertListView() {
        if alertSortListViewIsShowing {
            hide()
        } else {
            show()
        }
    }
    
    @objc private func panGesture(sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .began:
            panGestureAnchorY = sender.location(in: superview).y
            
        case .changed:
            guard let panGestureAnchorY = panGestureAnchorY else { return }
            
            let gesturePoint = sender.location(in: vc.view)
            let changes = gesturePoint.y - panGestureAnchorY
            let newPositionY = y + changes
            
            if newPositionY > showPositionY {
                y -= -changes
            }
            
            if newPositionY > positionForClosedY {
                hide()
            }

            self.panGestureAnchorY = gesturePoint.y
            
        case .cancelled, .ended:
            
            if y < positionForClosedY {
                show()
            }
            
            panGestureAnchorY = nil
                        
        case .failed, .possible:
            break
        @unknown default:
            break
        }
    }
}

//MARK: - Private Methods
extension AlertSortListView {
    
    private func addGestureView() {

        let gestureView = UIView(frame: vc.view.frame)
        gestureView.addMyGestureRecognizer(self, type: .tap(), #selector(showOrHideAlertListView))
        vc.tabBarController?.view.insertSubview(gestureView, belowSubview: self)
        self.gestureView = gestureView
    }
    
    private func configureView() {
        frame.size.width = vc.view.frame.width + 0.1
        frame.size.height = height
        frame.origin.y = vc.view.frame.height
        layer.cornerRadius = frame.width * 0.1
        
        backgroundColor = .yellow
        addMyGestureRecognizer(self, type: .panGestureRecognizer, #selector(panGesture(sender:)))
    }

    private func show() {
        alertSortListViewIsShowing = true
        
        if gestureView == nil {
            addGestureView()
        }
        
        UIView.animate(withDuration: 0.4) { [weak self] in
            guard let self = self else { return }
            frame.origin.y = showPositionY
        }
    }
    
    private func hide() {
        alertSortListViewIsShowing = false
        
        UIView.animate(withDuration: 0.4) { [weak self] in
            guard let self = self else { return }
            
            frame.origin.y = hidePositionY
        }
        
        gestureView?.removeFromSuperview()
    }
}
