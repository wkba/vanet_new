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

let limit_device_counts = 5

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

func getMinor(urgency_code:Int, accuracy:Int, count:Int)->UInt16{
    let arrenged_urgency_code = urgency_code * 1000 * 10
    let arrenged_accuracy = accuracy * 10
    let arrenged_count = count
    
    let arrenged_minor = arrenged_urgency_code + arrenged_accuracy + arrenged_count
    print("newMinor is " + arrenged_minor.description)
    return UInt16(arrenged_minor)
}

func getMajor()->UInt16{
    let ud = UserDefaults.standard
    var ud_major = 3
    if ud.object(forKey: "major") != nil {
        ud_major = ud.object(forKey: "major") as! Int
    }
    //print("newMajor is" + ud_major.description)
    return UInt16(ud_major)
}

func getMajorWithRandomCode()->UInt16{
    let ud = UserDefaults.standard
    var ud_major = 3
    if ud.object(forKey: "major") != nil {
        ud_major = ud.object(forKey: "major") as! Int
    }
    let arrenged_major = Int(arc4random_uniform(1000)) * 10 + ud_major
    //print("getMajorWithRandomCode is " + arrenged_major.description)
    return UInt16(arrenged_major)
}

func startAdvertisingUrgencyPeripheralData(pheripheralManager: CBPeripheralManager,accuracy:Int,major: CLBeaconMajorValue,minor:CLBeaconMinorValue,time_logs:UITextView){

    if(accuracy == -1){
        print("accuracy == -1")
        return
    }
    if(Int(minor)%10000 < 10){
        let urgency_code = Int(minor) % 100000 / 10000
        let arrenged_accuracy = (Int(minor) / 100) % 100 + accuracy
        let arrenged_count = Int(minor) % 10
        let minor = CLBeaconMinorValue(getMinor(urgency_code: urgency_code, accuracy: arrenged_accuracy + accuracy, count: arrenged_count+1))
        print("一番目でなく、三番目以内の端末.minor is " + minor.description + ", accuracy is " + accuracy.description +  ", major is " + major.description)
        let newPeripheralData = setPeripheralData(major: major, minor:minor)
        pheripheralManager.startAdvertising(newPeripheralData as? [String : Any])
        writeAdvertiseData(count: Int(minor)%10000, major: Int(major),minor:Int(minor),time_logs: time_logs)
    }
}
func startFirstAdvertisingUrgencyPeripheralData(pheripheralManager: CBPeripheralManager,accuracy:Int,major: CLBeaconMajorValue,minor:CLBeaconMinorValue,time_logs:UITextView){
    
    if(accuracy == -1){
        print("accuracy == -1")
        return
    }
    print("startFirstAdvertisingUrgencyPeripheralData")
    print(minor)
    let newPeripheralData = setPeripheralData(major: major, minor:10001)
    pheripheralManager.startAdvertising(newPeripheralData as? [String : Any])
    print("一番最初の端末")
    writeAdvertiseData(count: Int(minor)%10000, major: Int(major), minor: Int(minor), time_logs: time_logs)
}

func is_urgency_signal(minor:CLBeaconMinorValue)->Bool{
    if(Int(minor)/10000 == 1){
        return true
    }
    return false
}

func is_first_time_random_code(major:CLBeaconMajorValue,random_code_list:Array<Int>)->Bool{
    let random_code = Int(major)/10
    //print("random_code_list is " + random_code_list.description)
    if random_code_list.index(of: random_code) == nil {
        print("このランダムコード初めて！！！")
        return true
    }
    //print("このランダムコードは初めてじゃない")
    return false
}

func under_certain_count(beacon: CLBeacon)->Bool{
    if(Int(beacon.minor)%10 < limit_device_counts){
        return true
    }
    print("緊急用のadは終了")
    return false
}

func writeAdvertiseData(count:Int,major:Int,minor:Int,time_logs:UITextView){
    let time_log = (minor % 10).description + "番目: " + nowTime() + " : " + major.description + ":" + minor.description + "を送信"
    time_logs.text = time_logs.text + "\n" + time_log
}
func writeReceiveData(count:Int, major:Int,minor:Int, accuracy:Double,time_logs:UITextView){
    let time_log = (minor % 10).description + "番目: " + nowTime() + " : " + major.description + ":" + minor.description + "を受信(" + "".appendingFormat("%.2f", accuracy) + ")"
    time_logs.text = time_logs.text + "\n" + time_log
}
