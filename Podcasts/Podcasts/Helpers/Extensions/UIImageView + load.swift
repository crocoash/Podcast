//
//  UIImageView + load.swift
//  Podcasts
//
//  Created by student on 02.11.2021.
//

import UIKit

extension UIImageView {
    func load(string: String?) {
        guard let string = string, let url = URL(string: string) else { return }
        
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}
