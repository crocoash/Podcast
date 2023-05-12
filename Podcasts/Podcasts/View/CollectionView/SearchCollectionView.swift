//
//  SearchCollectionView.swift
//  Podcasts
//
//  Created by Anton on 09.05.2023.
//

import UIKit

@objc protocol SearchCollectionViewDelegate: AnyObject {
    func searchCollectionView(_ searchCollectionView: SearchCollectionView, podcast: Podcast)
}

class SearchCollectionView: UICollectionView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
//    private func configureTableView() {
//        tableView.rowHeight = 100
//        refreshControl.tintColor = .yellow
//        tableView.refreshControl = refreshControl
//    }
    weak var myDelegate: SearchCollectionViewDelegate?
    private var podcasts: PlayListByGenre!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.delegate = self
        self.dataSource = self
        
        register(SearchCollectionViewCell.self)
        let nib = UINib(nibName: SearchCollectionHeaderReusableView.identifier, bundle: nil)
        register(nib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SearchCollectionHeaderReusableView.identifier)
    }
    
    func setUp(podcasts: [Podcast]) {
        self.podcasts = podcasts.sortPodcastsByGenre
        reloadData()
    }
    
    @objc func selectCell(sender: UITapGestureRecognizer) {
        guard let cell = sender.view as? SearchCollectionViewCell,
              let indexPath = indexPath(for: cell)else { return }
        
        let podcast = podcasts[indexPath.section].podcasts[indexPath.row]
        myDelegate?.searchCollectionView(self, podcast: podcast)
    }
}

//MARK: - Private Methods
extension SearchCollectionView {
    
}

//MARK: - UICollectionViewDataSource
extension SearchCollectionView: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return podcasts[section].podcasts.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return podcasts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = getCell(cell: SearchCollectionViewCell.self, indexPath: indexPath)
        let entity = podcasts[indexPath.section].podcasts[indexPath.row]
        cell.addMyGestureRecognizer(self, type: .tap(), #selector(selectCell(sender: )))
        cell.setUP(entity: entity)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let headerView = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: "\(SearchCollectionHeaderReusableView.self)",
                for: indexPath)

            guard let header = headerView as? SearchCollectionHeaderReusableView else { return headerView }

            let title = podcasts[indexPath.section].key
            header.setUp(title: title)
            return header
        }
        
        assert(false, "Invalid element type")
    }
}


//MARK: -  UICollectionViewDelegate
extension SearchCollectionView: UICollectionViewDelegate {
    
}

//MARK: - UICollectionViewDelegateFlowLayout
extension SearchCollectionView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = bounds.width / 3
        return CGSize(width: size, height: size)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
        
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: self.bounds.width, height: 100)
    }
}
