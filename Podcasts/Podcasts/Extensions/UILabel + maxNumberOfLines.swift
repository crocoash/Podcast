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
    
    var textHeight: CGFloat {
        guard let self = self else { return 0 }
        return self.font.lineHeight
    }
}

extension UILabel {
    
    var maxNumberOfLines: Int {
        let maxSize = CGSize(width: self.frame.size.width, height: CGFloat(MAXFLOAT))
        let text = (self.text ?? "") as NSString
        let textHeight = text.boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: [.font: self.font as Any], context: nil).height
        let lineHeight = self.font.lineHeight
        return Int(ceil(textHeight / lineHeight))
    }
}
