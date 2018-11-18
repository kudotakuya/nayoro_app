//
//  ViewController.swift
//  nayoro_watch
//
//  Created by Takuya Kudo on 2018/11/17.
//  Copyright © 2018 Takuya Kudo. All rights reserved.
//

import UIKit
import HealthKit

class ViewController: UIViewController {
    
    
    @IBOutlet weak var moneyLabel: UILabel!
    @IBOutlet weak var averageView: UITextView!
    private let healthStore = HKHealthStore()
    var money = 10000
    var ave = ""
    var mon = 0
    
    // ワークアウトと心拍数を読み出しに設定
    private let readDataTypes: Set<HKObjectType> = [
        HKWorkoutType.workoutType(),
        HKObjectType.quantityType(forIdentifier: .heartRate)!,
        ]
    
    override func viewDidLoad() { do {
        super.viewDidLoad()
        
        healthStore.requestAuthorization(toShare: nil, read: readDataTypes) { (success, error) in
            guard success, error == nil else {
                return
            }
        }

        self.getHeartRateWithFiveMinutes( {average, money in
            print(average)
            self.ave = average
            self.mon = money
        })


        //labelを更新
        Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(ViewController.timerUpdateLabel), userInfo: nil, repeats: true)
        //データを更新
        Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(ViewController.timerUpdateData), userInfo: nil, repeats: true)
        
    }}
    
    @objc func timerUpdateLabel() {
        print("update label")
        self.averageView.text = ave
        self.moneyLabel.text = "\(mon)  円"
    }

    @objc func timerUpdateData() {
        print("update data")
        self.getHeartRateWithFiveMinutes( {average, money in
            print(average)
            self.ave = average
            self.mon = money
        })
    }
    
    private var statistics = [HKStatistics]()

    private var heartRateStatistics = [HKStatistics]()
    
    private func getHeartRateWithFiveMinutes(_ after:@escaping (String, Int) -> ()) {
        var average = ""
        let calendar = Calendar.current
        let now = Date()
        var dateComponents = DateComponents()
        let dateformatter = DateFormatter()
        dateformatter.locale = Locale(identifier: "ja_JP")
        dateformatter.dateFormat = "yyyy/MM/dd HH:mm"
        let nowDate = dateformatter.string(from: now as Date)
        var comps = DateComponents(hour: -2)
        let secondHourDate = dateformatter.string(from: calendar.date(byAdding: comps, to: now as Date)!)
        let startDate = dateformatter.date(from: secondHourDate)
        let endDate = dateformatter.date(from: nowDate)
        var time = ""
        var calc_time = 0
        var now_data = ""
        
        print(nowDate)
        print(secondHourDate)
        dateComponents.minute = 5  // 間隔時間
        let quantityType = HKObjectType.quantityType(forIdentifier: .heartRate)!,
        
        query = HKStatisticsCollectionQuery(quantityType: quantityType, quantitySamplePredicate: nil, options: [.discreteAverage, .discreteMin, .discreteMax], anchorDate: startDate!, intervalComponents: dateComponents)
        query.initialResultsHandler = { [unowned self] (query, result, error) in
            guard let result = result, error == nil else {
                return
            }
            result.enumerateStatistics(from: startDate!, to: endDate!) { (statistic, stop) in
                self.heartRateStatistics.append(statistic)
                comps = DateComponents(minute: calc_time)
                time = dateformatter.string(from: calendar.date(byAdding: comps, to: startDate as! Date)!)
                calc_time += 5
                average += "\(time) 平均値 \(statistic.averageQuantity()?.doubleValue(for: HKUnit(from: "count/min")).rounded() ?? 0) 脈/分\n"
                now_data = "\(statistic.averageQuantity()?.doubleValue(for: HKUnit(from: "count/min")).rounded() ?? 0)"
                
                self.money -= 3
            }
            
            //self.postJson(time: nowDate, heart_rate: now_data)
            after(average, self.money)
            
        }
        
        healthStore.execute(query)
        
    }
    
    private func postJson(time: String, heart_rate: String) {
        let urlString = "https://gmail60.cybozu.com/k/v1/record.json"
    
        let request = NSMutableURLRequest(url: URL(string: urlString)!)
    
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("CCjFz4XeW0Fc79GEEL9aR6DHJrGrnAwwKt7ZkuzZ", forHTTPHeaderField: "X-Cybozu-API-Token")
    
        let params:[String:Any] = [
            "app": 6,
            "record":[
                "user_id":[
                    "value": "001"
                ],
                "get_time":[
                    "value": time
                ],
                "heart_rate":[
                    "value": heart_rate
                ]
            ]
        ]
    
        do{
            request.httpBody = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
    
            let task:URLSessionDataTask = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {(data,response,error) -> Void in
                let resultData = String(data: data!, encoding: .utf8)!
                print("result:\(resultData)")
            })
            task.resume()
        }catch{
            print("Error:\(error)")
            return
        }
    
    }
    
}
