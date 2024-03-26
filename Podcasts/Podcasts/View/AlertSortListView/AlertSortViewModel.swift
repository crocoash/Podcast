//
//  AlertSortViewModel.swift
//  Podcasts
//
//  Created by Anton on 10.09.2023.
//

import UIKit

class AlertSortListViewModel: IPerRequest, INotifyOnChanged, ITableViewModel {
    
    var dataSourceForView: [SectionData] = []
    var listSections: [ListSection] = []
    
    struct Arguments {}
    
    struct SectionData: ISectionData {
        
        typealias Row = String
        typealias Section = String
        
        static func == (lhs: AlertSortListViewModel.SectionData, rhs: AlertSortListViewModel.SectionData) -> Bool {
            return false
        }
        
        var section: String
        var rows: [String]
                
        var isActive: Bool
        
        var isAvailable: Bool {
            return isActive
        }
    }
    
    //MARK: Services
    private let listDataManager: ListDataManager
    
    required init?(container: IContainer, args: Arguments) {
        self.dataStoreManager = container.resolve()
        self.listDataManager = container.resolve()
        
        configureDataSource()
        listDataManager.delegate = self
    }
    
    private let dataStoreManager: DataStoreManager
    
    func moveItem(from oldIndex: Int, to newIndex: Int) {
        let object = listSections[oldIndex]
        listDataManager.change(for: object, sequenceNumber: newIndex)
    }
  
    func changeActiveState(for indexPath: IndexPath) {
        let listSection = getItem(for: indexPath)
        listDataManager.changeActiveState(for: listSection)
    }
    
    func getCell(_ tableView: UITableView, for indexPath: IndexPath) -> UITableViewCell {
        let item = listSections[indexPath.row]
        let cell = UITableViewCell()
        cell.accessoryType = .checkmark
        cell.isSelected = true
        var content = cell.defaultContentConfiguration()
        content.text = item.nameOfEntity
        cell.contentConfiguration = content
        return cell
    }
}

//MARK: - Private Methods
extension AlertSortListViewModel {
    
    private func configureDataSource() {
        listSections = dataStoreManager.viewContext.fetchObjectsArray(ListSection.self,
                                                                           sortDescriptors: [NSSortDescriptor(key: #keyPath(ListSection.sequenceNumber), ascending: true)])

        let rows: [String] = listSections.map { $0.nameOfSection }
        dataSourceForView = [SectionData(section: "", rows: rows, isActive: true)]
        changed.raise()
    }
    
    private func getItem(for indexPath: IndexPath) -> ListSection {
        return listSections[indexPath.row]
    }
}

//MARK: - ListDataManagerDelegate
extension AlertSortListViewModel: ListDataManagerDelegate {
    func listDataManagerDidUpdate(_ ListDataManager: ListDataManager) {
        configureDataSource()
    }
}
