//
//  AlertSortListViewController.swift
//  Podcasts
//
//  Created by Anton on 14.08.2023.
//

import UIKit

//MARK: - MyDataSource
@objc protocol AlertSortListViewDataSource: AnyObject {
    @objc optional func test()
}

@objc protocol AlertSortListViewDelegate: AnyObject {
    
}

class AlertSortListViewModel {
    
    private let dataStoreManager: DataStoreManagerInput
    private let listDataManager: ListDataManagerInput
    
    init(dataStoreManager: DataStoreManagerInput, listDataManager: ListDataManagerInput) {
        self.dataStoreManager = dataStoreManager
        self.listDataManager = listDataManager
    }
    
   var listSections: [ListSection]  {
        return dataStoreManager.viewContext.fetchObjectsArray(ListSection.self,
                                                              sortDescriptors: [NSSortDescriptor(key: #keyPath(ListSection.sequenceNumber), ascending: true)])
    }
    
    var countOfRows: Int {
        return listSections.count
    }
    
    func moveItem(from oldIndex: Int, to newIndex: Int) {
        let object = listSections[oldIndex]
        listDataManager.change(for: object, sequenceNumber: newIndex)
    }
}

class AlertSortListView: UIView {
    
    //MARK: Services
    private let dataStoreManager: DataStoreManagerInput
    
    @IBOutlet private weak var closeImageView: UIImageView!
    @IBOutlet private weak var tableView: UITableView!
    
    weak var dataSource: AlertSortListViewDataSource?
    weak var delegate: AlertSortListViewDelegate?
    weak var vc: UIViewController!
    
    //MARK: Variables
    private var alertSortListViewIsShowing = false
    private var model: AlertSortListViewModel
    private var gestureView: UIView?
    private var panGestureAnchorY: CGFloat?
    private var height: Double = 300
    lazy private var width = vc.view.frame.width * 0.8
    
    private var y: Double {
        get { frame.origin.y }
        set { frame.origin.y = newValue }
    }
      
    /// Positions
    lazy private var hidePositionY = vc.view.frame.height
    lazy private var showPositionY = vc.view.frame.height - height - margin
    lazy private var margin = (vc.view.frame.width - width) / 2
    lazy private var positionYForClosed = showPositionY + height * 0.3
      
    typealias InputType = AlertSortListViewDelegate & AlertSortListViewDataSource & UIViewController
    
    //MARK: init
    init(vc: InputType, dataStoreManager: DataStoreManagerInput, listDataManager: ListDataManagerInput) {

        self.dataStoreManager = dataStoreManager
        self.model = AlertSortListViewModel(dataStoreManager: dataStoreManager, listDataManager: listDataManager)
        
        super.init(frame: .zero)
        
        self.vc = vc
        self.delegate = vc
        self.dataSource = vc
        
        configureView()
        loadFromXib()
        
        closeImageView.addMyGestureRecognizer(self, type: .panGestureRecognizer, #selector(panGesture(sender:)))

        tableView.isEditing = true
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
            
            if newPositionY > positionYForClosed {
                hide()
            }

            self.panGestureAnchorY = gesturePoint.y
            
        case .cancelled, .ended:
            
            if y < positionYForClosed {
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
        frame.size.width = width
        frame.size.height = height
        frame.origin.y = vc.view.frame.height
        frame.origin.x = margin
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
        gestureView = nil
    }
}

//MARK: - UITableViewDelegate
extension AlertSortListView: UITableViewDelegate {
    
}

//MARK: - UITableViewDataSource
extension AlertSortListView: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.countOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = model.listSections[indexPath.row]
        let cell = UITableViewCell()
        var content = cell.defaultContentConfiguration()
        content.text = item.nameOfEntity
        cell.contentConfiguration = content
        return cell
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        guard sourceIndexPath != destinationIndexPath else { return }
        model.moveItem(from: sourceIndexPath.row, to: destinationIndexPath.row)
    }
}
