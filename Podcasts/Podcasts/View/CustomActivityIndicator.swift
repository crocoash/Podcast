//
//  CustomActivityIndicator.swift
//  Podcasts
//
//  Created by Anton on 23.05.2023.
//

import Foundation
import UIKit


class CustomActivityIndicator: UIView {
    
    enum Size: Int {
        case small = 40
        case middle = 70
        case large = 100
        
        var cgSize: CGSize {
            return CGSize(width: self.rawValue, height: self.rawValue)
        }
    }
    
    var size: Size
    
    init(size: Size = .middle) {
        self.size = size
        super.init(frame: CGRect(origin: .zero, size: size.cgSize))
        configureView()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    func configureView() {
        let oneSection = .pi / 2 * CGFloat(0.7)
        let startAngle = .zero - CGFloat.pi / 2
        let redLine = createLine(startAngle: startAngle, endAngle: startAngle + oneSection, color: .red)
        let blueLine = createLine(startAngle: startAngle * 2, endAngle: startAngle * 2 + oneSection, color: .blue)
        let yellowLine = createLine(startAngle: startAngle * 3, endAngle: startAngle * 3 + oneSection, color: .yellow)
        let greenLine = createLine(startAngle: startAngle * 4, endAngle: startAngle * 4 + oneSection, color: .green)
        
        [redLine, blueLine, yellowLine, greenLine].forEach { self.layer.addSublayer($0) }
    }
    
    func startAnimation() {
        UIView.animate(withDuration: 1.0, delay: 0, options: .curveLinear) {
            self.transform = CGAffineTransform(rotationAngle: .pi)
        } completion: { _ in
            UIView.animate(withDuration: 1.0, delay: 0, options: .curveLinear) {
                self.transform = CGAffineTransform(translationX: 0, y: 0)
                self.transform = CGAffineTransform.identity.scaledBy(x: 0.6, y: 0.6)
            } completion: { _ in
                self.startAnimation()
            }
        }
    }
}

//MARK: - Private Methods
extension CustomActivityIndicator {
 
    private func createLine(startAngle: CGFloat, endAngle: CGFloat , color: UIColor) -> CALayer {
        let spinningCircle = CAShapeLayer()
        let lineWidth = frame.width /  7
        let center = CGPoint(x: frame.width / 2, y: frame.height / 2)
        
        let circularPath = UIBezierPath(arcCenter: center, radius: frame.width/2 - lineWidth, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        
        spinningCircle.path = circularPath.cgPath
        spinningCircle.fillColor = UIColor.clear.cgColor
        spinningCircle.strokeColor = color.cgColor
        spinningCircle.lineWidth = lineWidth
        spinningCircle.lineCap = .round
        
        return spinningCircle
    }
}

extension UIView {
    
    func showActivityIndicator() {
       guard !subviews.contains( where: { $0 is CustomActivityIndicator }) else { return }
        let activityIndicator = CustomActivityIndicator()
        activityIndicator.center = center
        activityIndicator.startAnimation()
        addSubview(activityIndicator)
    }
    
    func hideActivityIndicator() {
        subviews.forEach {
            if let activityIndicator = $0 as? CustomActivityIndicator {
                activityIndicator.removeFromSuperview()
            }
        }
    }
}
