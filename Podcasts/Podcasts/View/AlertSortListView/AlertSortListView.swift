//
//  AlertSortListViewController.swift
//  Podcasts
//
//  Created by Anton on 14.08.2023.
//

import UIKit

//MARK: - MyDataSource

class AlertSortListView: UIView, IHaveViewModel, IPerRequest {
        
    typealias ViewModel = AlertSortListViewModel
    
    func viewModelChanged() {
        
    }
    
    func viewModelChanged(_ viewModel: AlertSortListViewModel) {
        
    }
    
    typealias Arguments = UIViewController
   
   //MARK: Services
   private let dataStoreManager: DataStoreManager
   private let listDataManager: ListDataManager
   
   
   @IBOutlet private weak var closeImageView: UIImageView!
   @IBOutlet private weak var tableView: UITableView!
   
   weak var vc: UIViewController!
   
   //MARK: Variables
   private var alertSortListViewIsShowing = false
   private var gestureView: UIView?
   private var panGestureAnchorY: CGFloat?
   private var height: Double = 300
   lazy private var width = vc.view.frame.width * 0.8
   
   private var y: Double {
      get { frame.origin.y }
      set { frame.origin.y = newValue }
   }
   
   /// Positions
   lazy private var hidePositionY = vc.view.frame.height * 2
   lazy private var showPositionY = vc.view.frame.height - height - margin
   lazy private var margin = (vc.view.frame.width - width) / 2
   lazy private var positionYForClosed = showPositionY + height * 0.3
   
   
   //MARK: init
    required init(container: IContainer, args: Arguments) {
        
        self.dataStoreManager = container.resolve()
        self.listDataManager = container.resolve()
        
        super.init(frame: .zero)
        
        self.vc = args
        self.listDataManager.delegate = self

        configureView()
        loadFromXib()

        [closeImageView].forEach { $0.addMyGestureRecognizer(self, type: .panGestureRecognizer, #selector(panGesture(sender:))) }

        tableView.isEditing = true
        tableView.isScrollEnabled = false
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
      layer.shadowRadius = 40
      layer.shadowOpacity = 0.2
//      layer.shadowOffset = CGSize(width: 100, height: 100)
      layer.shadowColor = UIColor.white.cgColor
   }
   
   private func show() {
      alertSortListViewIsShowing = true
      
      if gestureView == nil {
         addGestureView()
      }
      
      UIView.animate(withDuration: 0.2) { [weak self] in
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
   
//   func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
//      return true
//   }
   
   func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
      let item = viewModel.listSections[indexPath.row]
      return item.isActive ? .delete : .insert
   }
   
   func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
      guard sourceIndexPath != destinationIndexPath else { return }
       viewModel.moveItem(from: sourceIndexPath.row, to: destinationIndexPath.row)
   }
   
   func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
       viewModel.changeActiveState(for: indexPath)
      tableView.reloadRows(at: [indexPath], with: .automatic)
   }

   func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
       viewModel.changeActiveState(for: indexPath)
      tableView.reloadRows(at: [indexPath], with: .automatic)
      return []
   }
}

//MARK: - UITableViewDataSource
extension AlertSortListView: UITableViewDataSource {
   
   func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return viewModel.countOfRows
   }
   
   func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      let item = viewModel.listSections[indexPath.row]
      let cell = UITableViewCell()
      cell.accessoryType = .checkmark
      cell.isSelected = true
      var content = cell.defaultContentConfiguration()
      content.text = item.nameOfEntity
      cell.contentConfiguration = content
      return cell
   }
}

//MARK: - ListDataManagerDelegate
extension AlertSortListView: ListDataManagerDelegate {
   
   func listDataManagerDidUpdate(_ ListDataManager: ListDataManager) {
      tableView.reloadData()
   }
}
