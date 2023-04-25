//
//  LikedMomentsViewController.swift
//  Podcasts
//
//  Created by mac on 08.11.2021.
//

import UIKit
import CoreData

protocol LikedMomentsViewControllerDelegate: AnyObject {
    
    func likedMomentViewController(_ likedMomentViewController: LikedMomentsViewController, didSelectMomentAt index: Int, likedMoments: [LikedMoment])
}

class LikedMomentsViewController: UIViewController {

    @IBOutlet private weak var emptyDataImage: UIImageView!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var tableViewBottomConstraint: NSLayoutConstraint!
   
    private var cellHeight: CGFloat = 75
    
    private var tableViewBottomConstraintConstant: CGFloat = 0
    weak var delegate: LikedMomentsViewControllerDelegate?
    
    private var playerIsSHidden = true {
        didSet {
            tableViewBottomConstraintConstant = playerIsSHidden ? 0 : 50
            tableViewBottomConstraint?.constant = tableViewBottomConstraintConstant
        }
    }
    
    //MARK: - View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(PodcastCell.self)
        tableView.rowHeight = cellHeight
        tableViewBottomConstraint.constant = tableViewBottomConstraintConstant
        LikedMoment.likedMomentFRC.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        showEmptyImage()
    }
    
    //MARK: Actions
    @IBAction func removeAll(_ sender: UIBarButtonItem) {
        LikedMoment.removeAll()
    }
    
    //MARK: Public Methods
    func updateConstraintForTableView(playerIsPresent value: Bool) {
        playerIsSHidden = !value
    }
}

extension LikedMomentsViewController {
    
    private func showEmptyImage() {
        let likeMomentsIsEmpty = LikedMoment.allObjectsFromCoreData.isEmpty
        emptyDataImage?.isHidden = !likeMomentsIsEmpty
        tableView?.isHidden = likeMomentsIsEmpty
    }
}

// MARK: - UITableViewDelegate
extension LikedMomentsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.likedMomentViewController(self, didSelectMomentAt: indexPath.row, likedMoments: LikedMoment.allObjectsFromCoreData)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let moment = LikedMoment.getLikedMoment(at: indexPath)
            moment.remove()
        }
    }
}

// MARK: - UITableViewDataSource
extension LikedMomentsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return LikedMoment.likedMomentFRC.sections?[section].objects?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let likedMoment = LikedMoment.getLikedMoment(at: indexPath)
        let cell = tableView.getCell(cell: PodcastCell.self, indexPath: indexPath)
        cell.configureCell(nil, with: likedMoment.podcast)
        return cell
    }
}

//MARK: - NSFetchedResultsControllerDelegate
extension LikedMomentsViewController: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .delete :
            guard let indexPath = indexPath else { return }
            tableView.deleteRows(at: [indexPath], with: .left)
            let title = "podcast is removed from playlist"
            MyToast.create(title: title, (playerIsSHidden ? .bottom : .bottomWithPlayer), for: view)
            
        case .insert :
            if let newIndexPath = newIndexPath {
                tableView.insertRows(at: [newIndexPath], with: .left)
                let likedMoment = LikedMoment.likedMomentFRC.object(at: newIndexPath)
                let name = likedMoment.podcast.trackName ?? ""
                let title = "\(name) podcast is added to playlist"
                MyToast.create(title: title, (playerIsSHidden ? .bottom : .bottomWithPlayer), for: view)
            }
            
        case .move :
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .left)
            }
            if let newIndexPath = newIndexPath {
                tableView.insertRows(at: [newIndexPath], with: .left)
            }
            
        case .update :
            if let indexPath = indexPath {
                let podcast = LikedMoment.getLikedMoment(at: indexPath).podcast
                if let cell = tableView.cellForRow(at: indexPath) as? PodcastCell {
                    cell.configureCell(nil, with: podcast)
                }
            }
            
        default : break
        }
        showEmptyImage()
    }
}
