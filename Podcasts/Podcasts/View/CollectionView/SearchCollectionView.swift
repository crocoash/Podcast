//
//  SearchCollectionView.swift
//  Podcasts
//
//  Created by Anton on 09.05.2023.
//

import UIKit

@objc protocol SearchCollectionViewDelegate: AnyObject {
   func searchCollectionView(_ searchCollectionView: SearchCollectionView, didTapAtIndexPath indexPath: IndexPath)
}

@objc protocol SearchCollectionViewDataSource: AnyObject {
   func searchCollectionViewNumbersOfSections(_ searchCollectionView: SearchCollectionView) -> Int
   func searchCollectionView(_ searchCollectionView: SearchCollectionView, nameOfSectionForIndex index: Int) -> String
   func searchCollectionView(_ searchCollectionView: SearchCollectionView, numbersOfRowsInSection index: Int) -> Int
   func searchCollectionView(_ searchCollectionView: SearchCollectionView, rowForIndexPath indexPath: IndexPath) -> SearchCollectionView.Row
}

class SearchCollectionView: UICollectionView {
   
   @IBOutlet weak var myDelegate: SearchCollectionViewDelegate?
   @IBOutlet weak var myDataSource: SearchCollectionViewDataSource?
   
   var diffableDataSource: UICollectionViewDiffableDataSource<String, Row>! = nil
   var snapShot = NSDiffableDataSourceSnapshot<String, Row>()
   
   
   class Row: NSObject {
      let podcast: Podcast
      let identifier = UUID()
      
      init(podcast: Podcast) {
         self.podcast = podcast
      }
   }
   
   required init?(coder: NSCoder) {
      super.init(coder: coder)
      self.collectionViewLayout = createLayout()
      self.register()
   }
   
   override func reloadData() {
      super.reloadData()
      reloadTableViewData()
   }
   
   //    override func supplementaryView(forElementKind elementKind: String, at indexPath: IndexPath) -> UICollectionReusableView? {
   //        return nil
   //    }
   
   //MARK: - Actions
   @objc func selectCell(sender: UITapGestureRecognizer) {
      guard let cell = sender.view as? SearchCollectionViewCell,
            let indexPath = indexPath(for: cell) else { return }
      
      myDelegate?.searchCollectionView(self, didTapAtIndexPath: indexPath)
   }
}

//MARK: - Private Methods
extension SearchCollectionView {
   
   private func reloadTableViewData() {
      snapShot = NSDiffableDataSourceSnapshot<String, Row>()
      let numbersOfSections = myDataSource?.searchCollectionViewNumbersOfSections(self) ?? 0
      
      (0..<numbersOfSections).forEach { indexSection in
         
         let numbersOfRows = myDataSource?.searchCollectionView(self, numbersOfRowsInSection: indexSection) ?? 0
         
         if let section = myDataSource?.searchCollectionView(self, nameOfSectionForIndex: indexSection) {
            var rows = [Row]()
            (0..<numbersOfRows).forEach { indexRow in
               
               let row = myDataSource?.searchCollectionView(self, rowForIndexPath: IndexPath(row: indexRow, section: indexSection))
               if let row = row {
                  rows.append(row)
               }
            }
            snapShot.appendSections([section])
            snapShot.appendItems(rows)
         }
      }
      
      self.diffableDataSource.apply(snapShot)
   }
   
   
   private func register() {
      
      let cellRegistration = UICollectionView.CellRegistration<SearchCollectionViewCell, Podcast> { cell, indexPath, item in
//          cell.
         cell.addMyGestureRecognizer(self, type: .tap(), #selector(self.selectCell))
      }
      
      self.diffableDataSource = UICollectionViewDiffableDataSource<String, Row>(collectionView: self) { collectionView, indexPath, item in
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
   
}

