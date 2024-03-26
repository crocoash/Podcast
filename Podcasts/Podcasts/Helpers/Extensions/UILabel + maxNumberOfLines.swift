//
//  UILabel.swift
//  MovieApp
//
//  Created by Tsvetkov Anton on 18.08.2021.
//

import UIKit


extension Optional where Wrapped == UILabel {
    
    var maxNumberOfLines: Int {
        guard let self = self else { return 0 }
        return self.maxNumberOfLines
    }
    
    var lineHeight: CGFloat {
        guard let self = self else { return 0 }
        return self.lineHeight
    }
}

extension UILabel {
    
    var lineHeight: CGFloat {
        return self.font.lineHeight
    }
    
    var maxNumberOfLines: Int {
        return Int(round(textHeight / lineHeight))
    }
    
    var textHeight: CGFloat {
        let maxSize = CGSize(width: self.frame.size.width, height: CGFloat(MAXFLOAT))
        return self.textRect(forBounds: CGRect(origin: .zero, size: maxSize),limitedToNumberOfLines: 0).height
    }
}
