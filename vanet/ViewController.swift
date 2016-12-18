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
import AudioToolbox

class ViewController: UIViewController, CBPeripheralManagerDelegate, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource {

    // PheripheralManager.
    var myPheripheralManager:CBPeripheralManager!
    // CLLocationManager
    var locationManager:CLLocationManager!

    
    @IBOutlet weak var debug_label: UILabel!
    @IBOutlet weak var state_button: UIButton!
    // Flag.
    var isAdvertising: Bool!
    
    var myBeaconRegion:CLBeaconRegion!
    var beaconUuids: NSMutableArray!
    var beaconDetails: NSMutableArray!
    @IBOutlet weak var beaconTableView: UITableView!
    @IBOutlet weak var debug_logs: UITextView!
    @IBOutlet weak var debugView: UIView!
    @IBOutlet weak var modeSwitch: UISwitch!
    @IBAction func changeMode(_ sender: Any) {
        if (modeSwitch.isOn) {
            debugView.isHidden = true
            state_button.isHidden = true
            productionView.isHidden = false
        }else{
            debugView.isHidden = false
            state_button.isHidden = false
            productionView.isHidden = true
        }
    }
    @IBOutlet weak var productionView: UIView!
    
    // 今回の検知対象のUUID
    let UUIDList = [
        "9EDFA660-204E-4066-8644-A432AE2B6EC1",
        "9EDFA660-204E-4066-8644-A432AE2B6EC2",
        "9EDFA660-204E-4066-8644-A432AE2B6EC3"
    ]

    var device_width : CGFloat = 0.0
    var device_height : CGFloat = 0.0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        device_width = productionView.bounds.size.width
        device_height = productionView.bounds.size.height
        //let rectSize = fillRect(width: 150.0, height: 150.0)
        //let rectView = UIImageView(image: rectSize)
        
        //rectView.center = productionView.center
        
        //productionView.addSubview(rectView)

        //let radius = getRadius(width : device_width, accuracy : 50)
        //productionView.layer.addSublayer(getLayer(width : device_width, height : device_height, radius : radius))
        
        
        //let ovalShapeLayer = CAShapeLayer()
        //ovalShapeLayer.strokeColor = UIColor.black.cgColor  // 輪郭は青色
        //ovalShapeLayer.fillColor = UIColor.red.cgColor  // 図形の中の色は白色
        //ovalShapeLayer.lineWidth = 1.0  // 輪郭の線の太さは1.0pt
        
        // 図形は円形
        //ovalShapeLayer.path = UIBezierPath(ovalIn: CGRect(x: device_width/2 - 50, y: device_height/2 - 50, width: 100.0, height: 100.0)).cgPath
        
        //let transparencyShapeLayer = CAShapeLayer()
        //transparencyShapeLayer.strokeColor = UIColor.white.cgColor  // 輪郭は青色
        //transparencyShapeLayer.fillColor = UIColor.white.cgColor  // 図形の中の色は白色
        //transparencyShapeLayer.lineWidth = 1.0  // 輪郭の線の太さは1.0pt
        
        // 図形は円形
        //transparencyShapeLayer.path = UIBezierPath(ovalIn: CGRect(x: device_width/2 - 25, y: device_height/2 - 25, width: 50.0, height: 50.0)).cgPath
        
        //ovalShapeLayer.addSublayer(transparencyShapeLayer)
        
        // 作成したCALayerを画面に追加
        //productionView.layer.addSublayer(ovalShapeLayer)
        
        
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
            // ロケーションマネージャの作成.
            locationManager = CLLocationManager()
            // デリゲートを自身に設定.
            locationManager.delegate = self
            // 取得精度の設定.
            // https://developer.apple.com/reference/corelocation/cllocationmanager/1423836-desiredaccuracy
            locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
            // 取得頻度の設定.(1mごとに位置情報取得)
            locationManager.distanceFilter = 0.1
            locationManager.startUpdatingLocation()
        }

        // beaconTableView.
        beaconTableView.register(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
        beaconTableView.dataSource = self
        beaconTableView.delegate = self
        beaconTableView.rowHeight = 100
        
        // セキュリティ認証のステータスを取得
        let status = CLLocationManager.authorizationStatus()
        print("CLAuthorizedStatus: \(status.rawValue)");
        
        // まだ認証が得られていない場合は、認証ダイアログを表示
        if(status == .notDetermined) {
            // [認証手順1] まだ承認が得られていない場合は、認証ダイアログを表示.
            // [認証手順2] が呼び出される
            locationManager.requestAlwaysAuthorization()
        }
        
        // 配列をリセット
        beaconUuids = NSMutableArray()
        beaconDetails = NSMutableArray()
    }
    
    func fillRect(width w: CGFloat, height h: CGFloat) -> UIImage {
        
        let size = CGSize(width: w, height: h)
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        
        let context = UIGraphicsGetCurrentContext()
        
        let rect = CGRect(x: 0, y: 0, width: w, height: h)
        let path = UIBezierPath(rect: rect)
        context?.setFillColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
        
        path.fill()
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
        
    }
    
    /*
     debugLogに書き込むだけのメソッド
     */
    func addDebugLogs(log : String){
        self.debug_logs.text = self.debug_logs.text + "\n" + log;
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
            let myMajor : CLBeaconMajorValue = 0
            
            // Minor.
            let myMinor : CLBeaconMinorValue = 0
            
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
    位置情報が更新されるたびに呼ばれる.
    */
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        //ここでアドバイズを再定義
        print("アドバイズが再定義された")
        addDebugLogs(log: "アドバイズが再定義された");
        
        myPheripheralManager.stopAdvertising()
        // iBeaconのUUID.
        let myProximityUUID = NSUUID(uuidString: "9EDFA660-204E-4066-8644-A432AE2B6EC1")
        
        // iBeaconのIdentifier.
        let myIdentifier = "fabo2"
        
        // Major.
        let myMajor : CLBeaconMajorValue = CLBeaconMajorValue(arc4random() % 100 + 1)
        // Minor.
        let myMinor : CLBeaconMinorValue = CLBeaconMinorValue(arc4random() % 100 + 1)
        
        // BeaconRegionを定義.
        let myBeaconRegion = CLBeaconRegion(proximityUUID: myProximityUUID! as UUID, major: myMajor, minor: myMinor, identifier: myIdentifier)
        
        // Advertisingのフォーマットを作成.
        let myBeaconPeripheralData = NSDictionary(dictionary: myBeaconRegion.peripheralData(withMeasuredPower: nil))
        
        // Advertisingを発信.
        myPheripheralManager.startAdvertising(myBeaconPeripheralData as? [String : AnyObject])
    }
    
//central
    /*
     CoreLocationの利用許可が取れたらiBeaconの検出を開始する.
     */
    private func startMyMonitoring() {
        
        // UUIDListのUUIDを設定して、反応するようにする
        for i in 0 ..< UUIDList.count {
            
            // BeaconのUUIDを設定.
            let uuid: NSUUID! = NSUUID(uuidString: "\(UUIDList[i].lowercased())")
            
            // BeaconのIfentifierを設定.
            let identifierStr: String = "fabo\(i)"
            
            // リージョンを作成.
            myBeaconRegion = CLBeaconRegion(proximityUUID: uuid as UUID, identifier: identifierStr)
            
            // ディスプレイがOffでもイベントが通知されるように設定(trueにするとディスプレイがOnの時だけ反応).
            myBeaconRegion.notifyEntryStateOnDisplay = false
            
            // 入域通知の設定.
            myBeaconRegion.notifyOnEntry = true
            
            // 退域通知の設定.
            myBeaconRegion.notifyOnExit = true
            
            // [iBeacon 手順1] iBeaconのモニタリング開始([iBeacon 手順2]がDelegateで呼び出される).
            locationManager.startMonitoring(for: myBeaconRegion)
        }
    }
    
    /*
     [認証手順2] 認証のステータスがかわったら呼び出される.
     */
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        print("didChangeAuthorizationStatus");
        
        // 認証のステータスをログで表示
        switch (status) {
        case .notDetermined:
            print("未認証の状態")
            break
        case .restricted:
            print("制限された状態")
            break
        case .denied:
            print("許可しない")
            break
        case .authorizedAlways:
            print("常に許可")
            // 許可がある場合はiBeacon検出を開始.
            startMyMonitoring()
            break
        case .authorizedWhenInUse:
            print("このAppの使用中のみ許可")
            // 許可がある場合はiBeacon検出を開始.
            startMyMonitoring()
            break
        }
    }
    
    /*
     [iBeacon 手順2]  startMyMonitoring()内のでstartMonitoringForRegionが正常に開始されると呼び出される。
     */
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        
        print("[iBeacon 手順2] didStartMonitoringForRegion");
        
        // [iBeacon 手順3] この時点でビーコンがすでにRegion内に入っている可能性があるので、その問い合わせを行う
        // [iBeacon 手順4] がDelegateで呼び出される.
        manager.requestState(for: region);
    }
    
    /*
     [iBeacon 手順4] 現在リージョン内にiBeaconが存在するかどうかの通知を受け取る.
     */
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        
        print("[iBeacon 手順4] locationManager: didDetermineState \(state)")
        
        switch (state) {
            
        case .inside: // リージョン内にiBeaconが存在いる
            print("iBeaconが存在!");
            
            // [iBeacon 手順5] すでに入っている場合は、そのままiBeaconのRangingをスタートさせる。
            // [iBeacon 手順6] がDelegateで呼び出される.
            // iBeaconがなくなったら、Rangingを停止する
            manager.startRangingBeacons(in: region as! CLBeaconRegion)
            break;
            
        case .outside:
            print("iBeaconが圏外!")
            // 外にいる、またはUknownの場合はdidEnterRegionが適切な範囲内に入った時に呼ばれるため処理なし。
            break;
            
        case .unknown:
            print("iBeaconが圏外もしくは不明な状態!")
            // 外にいる、またはUknownの場合はdidEnterRegionが適切な範囲内に入った時に呼ばれるため処理なし。
            break;
            
        }
    }
    
    /*
     [iBeacon 手順6] 現在取得しているiBeacon情報一覧が取得できる.
     iBeaconを検出していなくても1秒ごとに呼ばれる.
     */
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        
        // 配列をリセット
        beaconUuids = NSMutableArray()
        beaconDetails = NSMutableArray()
        
        
        // 範囲内で検知されたビーコンはこのbeaconsにCLBeaconオブジェクトとして格納される
        // rangingが開始されると１秒毎に呼ばれるため、beaconがある場合のみ処理をするようにすること.
        if(beacons.count > 0){
            
            // STEP7: 発見したBeaconの数だけLoopをまわす
            for i in 0 ..< beacons.count {
                
                let beacon = beacons[i]
                let beaconUUID = beacon.proximityUUID;
                let minorID = beacon.minor;
                let majorID = beacon.major;
                let rssi = beacon.rssi;
                let accuracy = beacon.accuracy;
                if(beacon.accuracy<10.0){
                    // バイブレーション？アラート？
                    AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                }
                
                //print("UUID: \(beaconUUID.UUIDString) minorID: \(minorID) majorID: \(majorID)");
                
                var proximity = ""
                
                switch (beacon.proximity) {
                    
                case CLProximity.unknown :
                    print("Proximity: Unknown");
                    proximity = "Unknown"
                    break
                    
                case CLProximity.far:
                    print("Proximity: Far");
                    proximity = "Far"
                    break
                    
                case CLProximity.near:
                    print("Proximity: Near");
                    proximity = "Near"
                    
                    break
                    
                case CLProximity.immediate:
                    print("Proximity: Immediate");
                    proximity = "Immediate"
                    break
                }
                
                beaconUuids.add(beaconUUID.uuidString)
                
                var myBeaconDetails = "Major: \(majorID) "
                myBeaconDetails += "Minor: \(minorID) "
                myBeaconDetails += "Accuracy:".appendingFormat("%.2f", accuracy)
                print(myBeaconDetails)
                addDebugLogs(log: myBeaconDetails)
                beaconDetails.add(myBeaconDetails)
                let radius = getRadius(width : device_width, accuracy : accuracy)
                productionView.layer.addSublayer(getLayer(width : device_width, height : device_height, radius : radius))
                
            }
        }
        
        // TableViewのReflesh.
        beaconTableView.reloadData()
        
        
    }
    
    /*
     [iBeacon イベント] iBeaconを検出した際に呼ばれる.
     */
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("didEnterRegion: iBeaconが圏内に発見されました。");
        
        // Rangingを始める (Ranginghあ1秒ごとに呼ばれるので、検出中のiBeaconがなくなったら止める)
        manager.startRangingBeacons(in: region as! CLBeaconRegion)
    }
    
    /*
     [iBeacon イベント] iBeaconを喪失した際に呼ばれる. 喪失後 30秒ぐらいあとに呼び出される.
     */
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("didExitRegion: iBeaconが圏外に喪失されました。");
        
        // 検出中のiBeaconが存在しないのなら、iBeaconのモニタリングを終了する.
        manager.stopRangingBeacons(in: region as! CLBeaconRegion)
    }
    
    /*
     Cellが選択された際に呼び出される
     */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Num: \(indexPath.row)")
        print("Value: \(beaconUuids[indexPath.row])")
    }
    
    /*
     Cellの総数を返す.
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return beaconUuids.count
    }
    
    /*
     Cellに値を設定する
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 再利用するCellを取得する.
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "Cell")
        
        // Cellに値を設定する.
        cell.textLabel?.numberOfLines = 0
        cell.textLabel!.font = UIFont(name: "Arial", size: 15)
        cell.textLabel!.textColor = UIColor.blue
        cell.textLabel!.text = beaconUuids[indexPath.row] as? String
        cell.detailTextLabel!.text = beaconDetails[indexPath.row] as? String
        
        return cell
    }
    
}
