//
//  drawCircle.swift
//  vanet
//
//  Created by wakabashi on 2016/12/19.
//  Copyright © 2016年 wakabayashi. All rights reserved.
//

import UIKit
import CoreLocation

func getRadius(width : CGFloat, accuracy : CLLocationAccuracy)->CGFloat{
    enum Distance: CLLocationAccuracy {
        case Far = 0.50
        case Near = 0.30
        case VeryNear = 0.10
    }
    
    let base = width / 5
    if (accuracy == -1) {
        return width
    } else if (Distance.Far.rawValue < accuracy) {
        return base * 4
    } else if (Distance.Near.rawValue < accuracy) {
        return base * 3
    } else if (Distance.VeryNear.rawValue < accuracy) {
        return base * 2
    }else {
        return base;
    }
}

func getLayer(width : CGFloat, height : CGFloat, radius : CGFloat)->CAShapeLayer{
    
    let ovalShapeLayer = CAShapeLayer()
    ovalShapeLayer.strokeColor = UIColor.red.cgColor
    ovalShapeLayer.fillColor = UIColor.red.cgColor
    ovalShapeLayer.lineWidth = 1.0
    
    ovalShapeLayer.path = UIBezierPath(ovalIn: CGRect(x: width/2 - radius/2, y: height/2 - radius/2, width: radius, height: radius)).cgPath
    
    let inner_radius = radius - width/5
    if (0 < inner_radius) {
    let transparencyShapeLayer = CAShapeLayer()
    transparencyShapeLayer.strokeColor = UIColor.red.cgColor
    transparencyShapeLayer.fillColor = UIColor.white.cgColor
    transparencyShapeLayer.lineWidth = 1.0
    
    transparencyShapeLayer.path = UIBezierPath(ovalIn: CGRect(x: width/2 - inner_radius/2, y: height/2 - inner_radius/2, width: inner_radius, height: inner_radius)).cgPath
    
    ovalShapeLayer.addSublayer(transparencyShapeLayer)
    }
    return ovalShapeLayer
}

func getClearLayer(width : CGFloat, height : CGFloat)->CAShapeLayer{
    
    let radius = width
    let clearLayer = CAShapeLayer()
    clearLayer.strokeColor = UIColor.white.cgColor
    clearLayer.fillColor = UIColor.white.cgColor
    clearLayer.lineWidth = 1.0
    
    clearLayer.path = UIBezierPath(ovalIn: CGRect(x: width/2 - radius/2, y: height/2 - radius/2, width: radius, height: radius)).cgPath
    
    return clearLayer
}

