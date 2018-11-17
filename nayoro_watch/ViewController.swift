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
    
    
    @IBOutlet weak var averageView: UITextView!
    private let healthStore = HKHealthStore()
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
            self.getHeartRates()
            self.getHeartRateWithFiveMinutes()
        }
    }}
    
    

    private var statistics = [HKStatistics]()

    private func getHeartRates() {
        guard let type = HKObjectType.quantityType(forIdentifier: .heartRate) else {
            return
        }
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "yyyy/MM/dd"
        let startDate = dateformatter.date(from: "2018/11/17")
        let endDate = dateformatter.date(from: "2018/11/18")
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        let query = HKStatisticsQuery(quantityType: type, quantitySamplePredicate: predicate, options: [.discreteAverage, .discreteMin, .discreteMax]) { [unowned self] (query, statistic, error) in
            guard let statistic = statistic, error == nil else {
                return
            }
            self.statistics.append(statistic)
            print("最低値 \(statistic.minimumQuantity()?.doubleValue(for: HKUnit(from: "count/min")) ?? 0) bpm")
            print("最高値 \(statistic.maximumQuantity()?.doubleValue(for: HKUnit(from: "count/min")) ?? 0) bpm")
            print("平均値 \(statistic.averageQuantity()?.doubleValue(for: HKUnit(from: "count/min")) ?? 0) bpm")
            print("-------------")
        }
        healthStore.execute(query)
    }

    private var heartRateStatistics = [HKStatistics]()
    
    private func getHeartRateWithFiveMinutes() {
        var average = ""
        var dateComponents = DateComponents()
        let dateformatter = DateFormatter()
        dateformatter.locale = Locale(identifier: "ja_JP")
        dateformatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        let startDate = dateformatter.date(from: "2018/11/17 16:00:00")
        let endDate = dateformatter.date(from: "2018/11/17 18:00:00")
        dateComponents.minute = 5  // 間隔時間
        let quantityType = HKObjectType.quantityType(forIdentifier: .heartRate)!,
        
        query = HKStatisticsCollectionQuery(quantityType: quantityType, quantitySamplePredicate: nil, options: [.discreteAverage, .discreteMin, .discreteMax], anchorDate: startDate!, intervalComponents: dateComponents)
        query.initialResultsHandler = { [unowned self] (query, result, error) in
            guard let result = result, error == nil else {
                return
            }
            result.enumerateStatistics(from: startDate!, to: endDate!) { (statistic, stop) in
                self.heartRateStatistics.append(statistic)
                print("平均値 \(statistic.averageQuantity()?.doubleValue(for: HKUnit(from: "count/min")) ?? 0) 脈/分")
                average += "平均値 \(statistic.averageQuantity()?.doubleValue(for: HKUnit(from: "count/min")) ?? 0) 脈/分\n"
            }
             self.averageView.text = average
        }
        
        healthStore.execute(query)
    }
    
}
