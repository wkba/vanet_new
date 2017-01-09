//
//  utility.swift
//  vanet
//
//  Created by wakabashi on 2016/12/19.
//  Copyright © 2016年 wakabayashi. All rights reserved.
//

import UIKit

func getVehicleName(major:NSNumber)->String{
    switch Int(major) % 10{
    case 0:
        return "自動車"
    case 1:
        return "自転車"
    case 2:
        return "歩行者"
    default:
        return "不明"
    }
}
func nowTime() -> String {
    let format = DateFormatter()
    format.dateFormat = "HH:mm:ss.SSS"
    return format.string(from: NSDate() as Date)
}
