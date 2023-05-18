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

    weak var myDelegate: SearchCollectionViewDelegate?
    private var podcasts: PlayListByGenre!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.delegate = self
        self.dataSource = self
        register(SearchCollectionViewCell.self)
//        let nib = UINib(nibName: SearchCollectionHeaderReusableView.identifier, bundle: nil)
//        register(nib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SearchCollectionHeaderReusableView.identifier)
        
        let containerCellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Int> { cell, indexPath, menuItem in
            var contentConfiguration = cell.defaultContentConfiguration()
            contentConfiguration.text = "menuItem.title"
            contentConfiguration.textProperties.font = .preferredFont(forTextStyle: .headline)
            cell.contentConfiguration = contentConfiguration
            
            let disclosureOptions = UICellAccessory.OutlineDisclosureOptions(style: .header)
            cell.accessories = [.outlineDisclosure(options: disclosureOptions)]
            cell.backgroundConfiguration = UIBackgroundConfiguration.clear()
        }
        
        self.register(SearchCollectionHeaderReusableView.self, forSupplementaryViewOfKind: "22", withReuseIdentifier: "headerId")
        
//        let layout = UICollectionViewCompositionalLayout { sectionNumber, env in
//
////            if sectionNumber != 1 {
////                let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))
////                item.contentInsets.top = 10
////                item.contentInsets.leading = 10
////                item.contentInsets.trailing = 10
////
////                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(300)), subitems: [item])
////
////                let section = NSCollectionLayoutSection(group: group)
////                section.orthogonalScrollingBehavior = .paging
////                return section
////
////            }
////
//            let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1/4), heightDimension: .fractionalWidth(1/4)))
//            item.contentInsets.top = 10
//            item.contentInsets.leading = 2
//            item.contentInsets.trailing = 2
//
//            let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(0)), subitems: [item])
//
//
//            let section = NSCollectionLayoutSection(group: group)
//            section.boundarySupplementaryItems = [
//                .init(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(50)), elementKind: "22", alignment: .topLeading)]
//            return section
//
//        }
        createDataSource()
        
        let listConfiguration = UICollectionLayoutListConfiguration(appearance: .sidebar)
        let layout = UICollectionViewCompositionalLayout.list(using: listConfiguration)
        self.collectionViewLayout = layout

    }
    //MARK: - Public Methods
    func setUp(podcasts: [Podcast]) {
        self.podcasts = podcasts.sortPodcastsByGenre
        reloadData()
    }
    
    func createDataSource() {
        self.dataSource = UICollectionViewDiffableDataSource<String, Podcast>(collectionView: self) { collectionView, indexPath, podcast in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchCollectionViewCell.identifier, for: indexPath) as? SearchCollectionViewCell
            cell?.setUP(entity: podcast)
            return cell
        }
    }
    
    override func reloadData() {
        var snapShot = NSDiffableDataSourceSnapshot<String, Podcast>()
        snapShot.appendSections(podcasts.map { $0.key} )
        
    }
    
    //MARK: - Actions
    @objc func selectCell(sender: UITapGestureRecognizer) {
        guard let cell = sender.view as? SearchCollectionViewCell,
              let indexPath = indexPath(for: cell)else { return }
        
        let podcast = podcasts[indexPath.section].podcasts[indexPath.row]
        myDelegate?.searchCollectionView(self, podcast: podcast)
    }
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
            let headerView = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: "headerId",
                for: indexPath)
            
            guard let header = headerView as? SearchCollectionHeaderReusableView else { return headerView }
            let title = podcasts[indexPath.section].key
            header.setUp(title: title)
            return header
    }
}


//MARK: -  UICollectionViewDelegate
extension SearchCollectionView: UICollectionViewDelegate {
    
}

//MARK: - UICollectionViewDelegateFlowLayout
extension SearchCollectionView: UICollectionViewDelegateFlowLayout {
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        let size = bounds.width / 3
//        return CGSize(width: size, height: size)
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
//        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//    }
        
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
//        return CGSize(width: self.bounds.width, height: 50)
//    }
}
