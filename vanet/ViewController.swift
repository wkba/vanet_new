//
//  ViewController.swift
//  vanet
//
//  Created by wakabashi on 2016/12/07.
//  Copyright © 2016年 wakabayashi. All rights reserved.
//

import UIKit
import CoreLocation
import CoreBluetooth

class ViewController: UIViewController, CBPeripheralManagerDelegate, CLLocationManagerDelegate {

    // PheripheralManager.
    var myPheripheralManager:CBPeripheralManager!
    // CLLocationManager
    var locationManager:CLLocationManager!

    
    @IBOutlet weak var debug_label: UILabel!
    @IBOutlet weak var state_button: UIButton!
    // Flag.
    var isAdvertising: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // PeripheralManagerを定義.
        myPheripheralManager = CBPeripheralManager()
        myPheripheralManager.delegate = self
        
        // ボタンの生成.
        self.state_button.layer.masksToBounds = true
        self.state_button.layer.cornerRadius = 50.0
        self.state_button.addTarget(self, action: #selector(onClickStateButton(sender:)), for: .touchDown)
        
        isAdvertising = false
        
        //現在地の取得を開始.
        if CLLocationManager.locationServicesEnabled() {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.startUpdatingLocation()
        }
    }
    
    /*
     Peripheralの準備ができたら呼び出される.
     */
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        print("peripheralManagerDidUpdateState")
    }
    
    /*
     ボタンイベントのセット.
     */
    func onClickStateButton(sender: UIButton){
        
        if(!isAdvertising) {
            // iBeaconのUUID.
            let myProximityUUID = NSUUID(uuidString: "9EDFA660-204E-4066-8644-A432AE2B6EC1")
            
            // iBeaconのIdentifier.
            let myIdentifier = "fabo2"
            
            // Major.
            let myMajor : CLBeaconMajorValue = 1
            
            // Minor.
            let myMinor : CLBeaconMinorValue = 2
            
            // BeaconRegionを定義.
            let myBeaconRegion = CLBeaconRegion(proximityUUID: myProximityUUID! as UUID, major: myMajor, minor: myMinor, identifier: myIdentifier)
            
            // Advertisingのフォーマットを作成.
            let myBeaconPeripheralData = NSDictionary(dictionary: myBeaconRegion.peripheralData(withMeasuredPower: nil))
            
            
            // Advertisingを発信.
            myPheripheralManager.startAdvertising(myBeaconPeripheralData as? [String : AnyObject])
        } else {
            
            myPheripheralManager.stopAdvertising()
            
            isAdvertising = false
            state_button.setTitle("Advertising", for: .normal)
            state_button.backgroundColor = UIColor.orange
        }
    }
    
    /*
     Advertisingが始まると呼ばれる.
     */
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        print("peripheralManagerDidStartAdvertising")
        
        isAdvertising = true
        state_button.setTitle("STOP", for: .normal)
        state_button.backgroundColor = UIColor.red
    }

    /*
    ユーザが位置情報の使用を許可しているか確認.
    */
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            break
        case .authorizedAlways, .authorizedWhenInUse:
            break
        }
    }
    
    /*
    位置情報が更新されるたびに呼ばれる.
    */
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last else {
            return
        }
        
        self.debug_label.text = "緯度:".appendingFormat("%.4f", newLocation.coordinate.latitude) + ", 経度:".appendingFormat("%.4f", newLocation.coordinate.longitude) + ", 速さ:".appendingFormat("%.4f", newLocation.speed) + ", 方角:".appendingFormat("%.2f", newLocation.course);
        print(newLocation);
    }
}
