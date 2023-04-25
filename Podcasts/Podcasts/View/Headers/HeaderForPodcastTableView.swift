//
//  HeaderForPodcastTableView.swift
//  Podcasts
//
//  Created by Anton on 15.04.2023.
//

import UIKit

class HeaderForPodcastTableView: UIView {

    @IBOutlet private weak var titleOfHeader: UILabel!
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadFromXib()
    }
    
    required init?(coder: NSCoder) {
      super.init(coder: coder)
        loadFromXib()
    }
  
    func setupView(text: String) {
        self.titleOfHeader.text = text
        self.titleOfHeader.numberOfLines = 0
        let height = self.titleOfHeader.textHeight
        self.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: height)
    }
}

