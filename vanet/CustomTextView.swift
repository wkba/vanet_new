//
//  CustomView.swift
//  vanet
//
//  Created by wakabashi on 2017/01/10.
//  Copyright © 2017年 wakabayashi. All rights reserved.
//

import UIKit

@IBDesignable class CustomTextView: UITextView {
    
    @IBInspectable var cornerRadius: CGFloat = 0.0
    @IBInspectable var borderColor: UIColor = UIColor.clear
    @IBInspectable var borderWidth: CGFloat = 0.0
    
    override func draw(_ rect: CGRect) {
        self.layer.cornerRadius = cornerRadius
        self.clipsToBounds = (cornerRadius > 0)
        
        self.layer.borderColor = borderColor.cgColor
        self.layer.borderWidth = borderWidth
        
        super.draw(rect)
    }
}
