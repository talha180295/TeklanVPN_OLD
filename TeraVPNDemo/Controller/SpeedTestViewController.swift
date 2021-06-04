//
//  SpeedTestViewController.swift
//  TeraVPNDemo
//
//  Created by Talha Ahmed on 10/02/2021.
//  Copyright © 2021 abc. All rights reserved.
//

import UIKit
import LMGaugeViewSwift

class SpeedTestViewController: UIViewController, URLSessionDelegate, URLSessionDataDelegate {
    
    @IBOutlet weak var gaugeView: GaugeView!
    @IBOutlet weak var startBtn: UIButton!
    @IBOutlet weak var speedLabel: UILabel!
    typealias speedTestCompletionHandler = (_ megabytesPerSecond: Double? , _ error: Error?) -> Void
    
    var speedTestCompletionBlock : speedTestCompletionHandler?
    
    var startTime: CFAbsoluteTime!
    var stopTime: CFAbsoluteTime!
    var bytesReceived: Int!
    
    var timeDelta: Double = 1.0/24
    var velocity: Double = 0
    var acceleration: Double = 5
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.title = "Speed Test"//Titles.SPEED_TEST.rawValue.localiz()
        
        self.startBtn.setTitle("START SPEED TEST", for: .normal)
        
        setupGauge()
        self.speedLabel.text = ""
    }
    
    
    @IBAction func startTest(_ sender:UIButton){
        checkForSpeedTest()
    }
    
    @IBAction func backButton(_ sender:UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
    func setupGauge(){
        
        // Configure gauge view
        let screenMinSize = min(UIScreen.main.bounds.size.width, UIScreen.main.bounds.size.height)
        let ratio = Double(screenMinSize)/320
        gaugeView.divisionsRadius = 1.25 * ratio
        gaugeView.subDivisionsRadius = (1.25 - 0.5) * ratio
        gaugeView.ringThickness = 16 * ratio
        gaugeView.valueFont = UIFont(name: GaugeView.defaultFontName, size: CGFloat(80 * ratio))!
        gaugeView.unitOfMeasurementFont = UIFont(name: GaugeView.defaultFontName, size: CGFloat(16 * ratio))!
        gaugeView.minMaxValueFont = UIFont(name: GaugeView.defaultMinMaxValueFont, size: CGFloat(12 * ratio))!
        gaugeView.unitOfMeasurement = "Mb/s"
        // Update gauge view
        gaugeView.minValue = 0
        gaugeView.maxValue = 100
//        gaugeView.limitValue = 50
        
        // Create a timer to update value for gauge view
//        Timer.scheduledTimer(timeInterval: timeDelta,
//                             target: self,
//                             selector: #selector(updateGaugeTimer),
//                             userInfo: nil,
//                             repeats: true)
    }
    
    
    func ringStokeColor(gaugeView: GaugeView, value: Double) -> UIColor {
        if value >= gaugeView.limitValue {
            return UIColor(red: 1, green: 59.0/255, blue: 48.0/255, alpha: 1)
        }
//        if nightModeSwitch.isOn {
//            return UIColor(red: 76.0/255, green: 217.0/255, blue: 100.0/255, alpha: 1)
//        }
        return UIColor(red: 11.0/255, green: 150.0/255, blue: 246.0/255, alpha: 1)
    }
    
    // MARK: EVENTS
    
//    @objc func updateGaugeTimer(timer: Timer) {
//        // Calculate velocity
//        velocity += timeDelta * acceleration
//        if velocity > gaugeView.maxValue {
//            velocity = gaugeView.maxValue
//            acceleration = -5
//        }
//        if velocity < gaugeView.minValue {
//            velocity = gaugeView.minValue
//            acceleration = 5
//        }
//
//        // Set value for gauge view
//        gaugeView.value = velocity
//    }
//
    func checkForSpeedTest() {
        
        startBtn.isEnabled = false
        startBtn.setTitle("TESTING", for: .disabled)
        testDownloadSpeedWithTimout(timeout: 10.0) { (speed, error) in
            print("Download Speed:", speed ?? "NA")
            print("Speed Test Error:", error ?? "NA")
            let formattedSpeed = String(format: "DOWNLOADING SPEED : %.2f  Mb/s", speed ?? 0.0)
            
            DispatchQueue.main.async {
                self.startBtn.setTitle("START SPEED TEST", for: .normal)
                self.startBtn.isEnabled = true
                self.speedLabel.text = formattedSpeed
            }
        }
        
    }
    
    func testDownloadSpeedWithTimout(timeout: TimeInterval, withCompletionBlock: @escaping speedTestCompletionHandler) {
        
        guard let url = URL(string: "http://ipv4.scaleway.testdebit.info/1G.iso") else { return }
        
        startTime = CFAbsoluteTimeGetCurrent()
        stopTime = startTime
        bytesReceived = 0
        
        speedTestCompletionBlock = withCompletionBlock
        
        let configuration = URLSessionConfiguration.ephemeral
        configuration.timeoutIntervalForResource = timeout
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        configuration.urlCache = nil
        let session = URLSession.init(configuration: configuration, delegate: self, delegateQueue: nil)
        session.dataTask(with: url).resume()
        
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        bytesReceived! += data.count
        stopTime = CFAbsoluteTimeGetCurrent()
        
        let elapsed = stopTime - startTime
        
        var downloadSpeed = Double(bytesReceived) / (elapsed)
        downloadSpeed = (downloadSpeed / (1024 * 1024)) * 8
        speedListener(speed: downloadSpeed)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        
        let elapsed = stopTime - startTime
        
        if let aTempError = error as NSError?, aTempError.domain != NSURLErrorDomain && aTempError.code != NSURLErrorTimedOut && elapsed == 0  {
            speedTestCompletionBlock?(nil, error)
            return
        }
        
        //        let speed = elapsed != 0 ? Double(bytesReceived) / elapsed / 1024.0 / 1024.0 : -1
        var downloadSpeed = Double(bytesReceived) / (elapsed)
        downloadSpeed = (downloadSpeed / (1024 * 1024)) * 8
        speedTestCompletionBlock?(downloadSpeed, nil)
        
    }
    
    func speedListener(speed:Double){
        
        let formattedSpeed = String(format: "DOWNLOADING SPEED: %.2f  Mb/s", speed)
        print("\(formattedSpeed)")
        
        DispatchQueue.main.async {
            self.gaugeView.value = speed
            self.speedLabel.text = formattedSpeed
        }
       
    }
}
