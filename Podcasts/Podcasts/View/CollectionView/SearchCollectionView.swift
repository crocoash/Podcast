//
//  SearchCollectionView.swift
//  Podcasts
//
//  Created by Anton on 09.05.2023.
//1
import UIKit

@objc protocol SearchCollectionViewDelegate: AnyObject {
   func searchCollectionView(_ searchCollectionView: SearchCollectionView, didTapAtIndexPath indexPath: IndexPath)
}

@objc protocol SearchCollectionViewDataSource: AnyObject {
    func searchCollectionViewNumbersOfSections(_ searchCollectionView: SearchCollectionView) -> Int
    func searchCollectionView(_ searchCollectionView: SearchCollectionView, nameOfSectionForIndex index: Int) -> String
    func searchCollectionView(_ searchCollectionView: SearchCollectionView, sizeForSection section: Int) -> CGSize
    func searchCollectionView(_ searchCollectionView: SearchCollectionView, numbersOfRowsInSection index: Int) -> Int
    func searchCollectionView(_ searchCollectionView: SearchCollectionView, rowForIndexPath indexPath: IndexPath) -> SearchCollectionView.Row
}

class SearchCollectionView: UICollectionView, IDiffableCollectionViewWithDataSource {    

    typealias Section = String
    class Row: NSObject {
       let podcast: Podcast
       let identifier = UUID()
       
       init(podcast: Podcast) {
          self.podcast = podcast
       }
    }
    
    var snapShot: SnapShot!
    var diffableDataSource: DiffableDataSource!
    
    func sectionFor(index: Int) -> String {
        return myDataSource?.searchCollectionView(self, nameOfSectionForIndex: index) ?? ""
    }
    
    var countOfSections: Int { return  myDataSource?.searchCollectionViewNumbersOfSections(self) ?? 0 }
    
    func countOfRowsInSection(index: Int) -> Int {
        return myDataSource?.searchCollectionView(self, numbersOfRowsInSection: index) ?? 0
    }
    
    func cellForRowAt(indexPath: IndexPath) -> Row {
        guard let myDataSource = myDataSource else { fatalError() }
        return myDataSource.searchCollectionView(self, rowForIndexPath: indexPath)
    }
    
   @IBOutlet weak var myDelegate: SearchCollectionViewDelegate?
   @IBOutlet weak var myDataSource: SearchCollectionViewDataSource?
   
   required init?(coder: NSCoder) {
      super.init(coder: coder)
       collectionViewLayout = createLayout()
       register()
   }
   
   override func reloadData() {
      super.reloadData()
       reloadTableView()
   }
   
   //MARK: - Actions
   @objc func selectCell(sender: UITapGestureRecognizer) {
      guard let cell = sender.view as? SearchCollectionViewCell,
            let indexPath = indexPath(for: cell) else { return }
      
      myDelegate?.searchCollectionView(self, didTapAtIndexPath: indexPath)
   }
}

































//MARK: - Private Methods
extension SearchCollectionView {
   
   private func register() {
      
      let cellRegistration = UICollectionView.CellRegistration<SearchCollectionViewCell, Podcast> { cell, indexPath, podcast in
          cell.setUP(podcast: podcast)
         cell.addMyGestureRecognizer(self, type: .tap(), #selector(self.selectCell))
      }
      
      diffableDataSource = UICollectionViewDiffableDataSource<Section, Row>(collectionView: self) { collectionView, indexPath, item in
         return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item.podcast)
      }
      
      let supplementaryRegistration = UICollectionView.SupplementaryRegistration
      <SearchCollectionHeaderReusableView>(elementKind: SearchCollectionHeaderReusableView.identifier) { [weak self] (supplementaryView, string, indexPath) in
         guard let self = self else { return }
         let title = snapShot.sectionIdentifiers[indexPath.section]
         supplementaryView.setUp(title: title)
      }
      
      self.diffableDataSource.supplementaryViewProvider = { (view, kind, index) in
         let view = self.dequeueConfiguredReusableSupplementary(using: supplementaryRegistration, for: index)
          view.backgroundColor = .systemBackground
         return view
      }
   }
   
   private func createLayout() -> UICollectionViewLayout {
       let sectionProvider = { [weak self] (section: Int, invarement: NSCollectionLayoutEnvironment) in
           guard let self = self,
                 //TODO: -
                 let _ = myDataSource?.searchCollectionView(self, sizeForSection: section).width else { fatalError() }
           
           let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/3),
                                                heightDimension: .fractionalHeight(1.0))
           
           let items = NSCollectionLayoutItem(layoutSize: itemSize)
           
           let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.9),
                                                  heightDimension: itemSize.widthDimension)
                                                  
           let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [items])
           group.interItemSpacing = .fixed(CGFloat(10))
           
           
           let section = NSCollectionLayoutSection(group: group)
           section.orthogonalScrollingBehavior = .paging
           section.interGroupSpacing = CGFloat(10)
           section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)

           
           let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(50)),
            elementKind: SearchCollectionHeaderReusableView.identifier, alignment: .top)
           sectionHeader.pinToVisibleBounds = true
           section.boundarySupplementaryItems = [sectionHeader]
           return section
       }
      
      let config = UICollectionViewCompositionalLayoutConfiguration()

      let layout = UICollectionViewCompositionalLayout(sectionProvider: sectionProvider, configuration: config)
      
      return layout
   }
   
}

