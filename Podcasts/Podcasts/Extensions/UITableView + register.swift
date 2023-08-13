//
//  UITableView + register.swift
//  Podcasts
//
//  Created by Tsvetkov Anton on 30.10.2021.
//

import UIKit
import CoreData

extension UITableView {
    
    func register(_ cell: UITableViewCell.Type) {
        register(UINib(nibName: "\(cell.identifier)", bundle: nil), forCellReuseIdentifier: "\(cell.identifier)")
    }

    func getCell<T: UITableViewCell>(cell: T.Type, indexPath: IndexPath) -> T {
        if self.dequeueReusableCell(withIdentifier: cell.identifier) == nil {
            self.register(cell)
        }
        return self.dequeueReusableCell(withIdentifier: cell.identifier, for: indexPath) as! T
    }
}

extension UITableView {
    
    func getCells<Item: NSManagedObject,
                  Section,
                  EntityProtocol>
    (dataSource: UITableViewDiffableDataSource<Section,Item>, whereEntityConformTo entityProtocol: EntityProtocol) -> [(UITableViewCell)] {
        
        var cells = [UITableViewCell]()
        
        guard let indexPaths = self.indexPathsForVisibleRows else { return [] }
        
        indexPaths.forEach {
            guard let item = dataSource.itemIdentifier(for: $0) else { return }
            if item.isPropertiesConform(to: entityProtocol.self), let cell = self.cellForRow(at: $0) {
                cells.append(cell)
            }
        }
        return cells
    }

}
