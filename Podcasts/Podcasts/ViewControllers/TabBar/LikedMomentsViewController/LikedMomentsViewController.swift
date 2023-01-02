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
    
    //MARK: - View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(PodcastCell.self)
        tableView.rowHeight = cellHeight
        tableViewBottomConstraint.constant = tableViewBottomConstraintConstant
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        LikedMomentsManager.shared.likedMomentFRC.delegate = self
        reloadData()
    }
    
    //MARK: - Public Method
    func reloadData() {
        tableView?.reloadData()
        showEmptyImage()
    }
    
    func playerIsShow() {
        tableViewBottomConstraintConstant = 50
        tableViewBottomConstraint?.constant = tableViewBottomConstraintConstant
    }
}

extension LikedMomentsViewController {
    
    private func showEmptyImage() {
        let likeMomentsIsEmpty = LikedMomentsManager.shared.podcast.isEmpty
        emptyDataImage?.isHidden = !likeMomentsIsEmpty
        tableView?.isHidden = likeMomentsIsEmpty
    }
}

// MARK: - UITableViewDelegate
extension LikedMomentsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.likedMomentViewController(self, didSelectMomentAt: indexPath.row, likedMoments: LikedMomentsManager.shared.podcast)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            LikedMomentsManager.shared.deleteMoment(at: indexPath)
            FirebaseDatabase.shared.saveLikedMoment()
            reloadData()
        }
    }
}

// MARK: - UITableViewDataSource
extension LikedMomentsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return LikedMomentsManager.shared.countOfLikeMoments
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let likedMoment = LikedMomentsManager.shared.getLikeMoment(at: indexPath)
        let cell = tableView.getCell(cell: PodcastCell.self, indexPath: indexPath)
        cell.configureCell(with: likedMoment.podcast)
        return cell
    }
}

//MARK: - NSFetchedResultsControllerDelegate
extension LikedMomentsViewController: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        guard let indexPath = indexPath else { return }
        switch type {
        case .delete:
            tableView.deleteRows(at: [indexPath], with: .fade)
        default: break
        }
    }
}
