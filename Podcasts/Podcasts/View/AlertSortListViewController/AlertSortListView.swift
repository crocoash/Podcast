//
//  AlertSortListViewController.swift
//  Podcasts
//
//  Created by Anton on 14.08.2023.
//

import UIKit

//MARK: - MyDataSource
@objc protocol AlertSortListViewMyDataSource: AnyObject {
    
}

@objc protocol AlertSortListViewMyDelegate: AnyObject {
    
}

@IBDesignable
class AlertSortListView: UIView {

    typealias InputType = AlertSortListViewMyDataSource & AlertSortListViewMyDelegate
    
    @IBOutlet private weak var closeImageView: UIImageView!
    @IBOutlet private weak var collectionView: UICollectionView!
    
    @IBOutlet private weak var myDataSource: AlertSortListViewMyDataSource?
    @IBOutlet private weak var myDelegate: AlertSortListViewMyDelegate?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        configureView()
    }
}

//MARK: - Private Methods
extension AlertSortListView {
    
    private func configureView() {
        layer.cornerRadius = frame.width * 0.9
        backgroundColor = .yellow
    }
}
