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
    private(set) var playlist: PlayListByGenre!
    var diffableDataSource: UICollectionViewDiffableDataSource<String, Item>! = nil
    var snapShot = NSDiffableDataSourceSnapshot<String, Item>()
    
    struct Item: Hashable {
        let podcast: Podcast
        let identifier = UUID()
        func hash(into hasher: inout Hasher) {
            hasher.combine(identifier)
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.collectionViewLayout = createLayout()
        self.configureDataSource()
    }
    
    
    //MARK: - Public Methods
    func setUp(playlist: [Podcast]) {
        self.playlist = playlist.sortPodcastsByGenre
        reloadData1()
    }
    
    func createLayout() -> UICollectionViewLayout {
        let sectionProvider = { (section: Int, invarement: NSCollectionLayoutEnvironment) in
            let itemSize = CGFloat(0.25)
            let items = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(itemSize), heightDimension: .fractionalWidth(itemSize)))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(10)), subitems: [items])
            
            let section = NSCollectionLayoutSection(group: group)
//            section.orthogonalScrollingBehavior = .continuous
            
            let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(50)),
                elementKind: SearchCollectionHeaderReusableView.identifier, alignment: .top)
            sectionHeader.pinToVisibleBounds = true
            section.boundarySupplementaryItems = [sectionHeader]
            return section
        }
        
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 0
        let layout = UICollectionViewCompositionalLayout(sectionProvider: sectionProvider, configuration: config)
  
        return layout
    }
    
    func configureDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<SearchCollectionViewCell, Podcast>{ cell, indexPath, item in
            cell.setUP(entity: item)
            cell.addMyGestureRecognizer(self, type: .tap(), #selector(self.selectCell))
        }
        
        self.diffableDataSource = UICollectionViewDiffableDataSource<String, Item>(collectionView: self) { collectionView, indexPath, item in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item.podcast)
        }
        
        let supplementaryRegistration = UICollectionView.SupplementaryRegistration
        <SearchCollectionHeaderReusableView>(elementKind: SearchCollectionHeaderReusableView.identifier) { (supplementaryView, string, indexPath) in
            let title = self.playlist[indexPath.section].key + " " + String(self.playlist[indexPath.section].podcasts.count)
//            let section = self.snapShot.sectionIdentifiers[indexPath.section]
            
            supplementaryView.setUp(title: title)
        }
        
        self.diffableDataSource.supplementaryViewProvider = { (view, kind, index) in
            return self.dequeueConfiguredReusableSupplementary(using: supplementaryRegistration, for: index)
        }
    }
    
    func reloadData1() {
        
        snapShot = NSDiffableDataSourceSnapshot<String, Item>()
        let items = playlist.map { (key: $0.key,items: $0.podcasts.map { Item(podcast: $0)})}
       
        for item in items {
            snapShot.appendSections([item.key])
            snapShot.appendItems(item.items)
        }
//
        self.diffableDataSource.apply(snapShot ,animatingDifferences: false)
    }
    
//    override func supplementaryView(forElementKind elementKind: String, at indexPath: IndexPath) -> UICollectionReusableView? {
//        return nil
//    }
    
    //MARK: - Actions
    @objc func selectCell(sender: UITapGestureRecognizer) {
        guard let cell = sender.view as? SearchCollectionViewCell,
              let indexPath = indexPath(for: cell) else { return }
        
        let podcast = playlist[indexPath.section].podcasts[indexPath.row]
        myDelegate?.searchCollectionView(self, podcast: podcast)
    }
}


