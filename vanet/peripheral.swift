//
//  peripheral.swift
//  vanet
//
//  Created by wakabashi on 2016/12/20.
//  Copyright © 2016年 wakabayashi. All rights reserved.
//

import UIKit
import CoreBluetooth
import CoreLocation

func setPeripheralData(major:CLBeaconMajorValue, minor:CLBeaconMinorValue)->NSDictionary{
    // iBeaconのUUID.
    let myProximityUUID = NSUUID(uuidString: "9EDFA660-204E-4066-8644-A432AE2B6EC1")
    
    // iBeaconのIdentifier.
    let myIdentifier = "fabo2"
    
    // BeaconRegionを定義.
    let myBeaconRegion = CLBeaconRegion(proximityUUID: myProximityUUID! as UUID, major: major, minor: minor, identifier: myIdentifier)
    
    // Advertisingのフォーマットを作成.
    let myBeaconPeripheralData = NSDictionary(dictionary: myBeaconRegion.peripheralData(withMeasuredPower: nil))
    
    return myBeaconPeripheralData
}

func getMinor(urgency_code:Int, accuracy:CLLocationAccuracy, count:Int)->Int{
    let arrenged_urgency_code = NSString(format: "%04d", urgency_code) as String
    let arrenged_accuracy = NSString(format: "%04d", Int(accuracy)) as String
    let arrenged_count = NSString(format: "%04d", count) as String
    
    let arrenged_minor = arrenged_urgency_code + arrenged_accuracy + arrenged_count
    return Int(arrenged_minor)!
}
