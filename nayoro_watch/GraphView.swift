//
//  GraphView.swift
//  nayoro_watch
//
//  Created by Takuya Kudo on 2018/11/18.
//  Copyright © 2018 Takuya Kudo. All rights reserved.
//

import UIKit

@IBDesignable class GraphView: UIView {
    
    @IBInspectable var startColor: UIColor = UIColor.red
    @IBInspectable var endColor: UIColor = UIColor.green
    
    // ダミーデータ
    var graphPoints:[Int] = [4, 2, 6, 4, 5, 8, 3]
    
    // グラフのプロットデータ設定用のメソッドです。
    func setupPoints(points: [Int]) {
        graphPoints = points
        self.setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        
        // グラデーションの描画
        let width = rect.width
        let height = rect.height
        
        let path = UIBezierPath(roundedRect: rect,
                                byRoundingCorners: UIRectCorner.allCorners,
                                cornerRadii: CGSize(width: 8.0, height: 8.0))
        path.addClip()
        
        let context = UIGraphicsGetCurrentContext()
        let colors = [startColor.cgColor, endColor.cgColor]
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let colorLocations:[CGFloat] = [0.0, 1.0]
        let gradient = CGGradient(colorsSpace: colorSpace,
                                  colors: colors as CFArray,
                                  locations: colorLocations)
        var startPoint = CGPoint.zero
        var endPoint = CGPoint(x:0, y:self.bounds.height)
        context!.drawLinearGradient(gradient!,
                                    start: startPoint,
                                    end: endPoint,
                                    options: .drawsBeforeStartLocation)
        
        
        // X座標の計算
        let margin:CGFloat = 20.0
        let columnXPoint = { (column:Int) -> CGFloat in
            
            let spacer = (width - margin*2 - 4) /
                CGFloat((self.graphPoints.count - 1))
            var x:CGFloat = CGFloat(column) * spacer
            x += margin + 2
            return x
        }
        
        // Y座標の計算
        let topBorder:CGFloat = 60
        let bottomBorder:CGFloat = 50
        let graphHeight = height - topBorder - bottomBorder
        let maxValue = 150
        let columnYPoint = { (graphPoint:Int) -> CGFloat in
            
            var y:CGFloat = CGFloat(graphPoint) / CGFloat(maxValue) * graphHeight
            y = graphHeight + topBorder - y
            return y
        }
        
        // 折れ線グラフの描画
        UIColor.blue.setFill()
        UIColor.blue.setStroke()
        
        let graphPath = UIBezierPath()
        
        graphPath.move(to: CGPoint(x:columnXPoint(0),
                                      y:columnYPoint(graphPoints[0])))
        
        for i in 1..<graphPoints.count {
            let nextPoint = CGPoint(x:columnXPoint(i),
                                    y:columnYPoint(graphPoints[i]))
            graphPath.addLine(to: nextPoint)
        }
        
        graphPath.stroke()
        
        // 高さの調整
        let highestYPoint = columnYPoint(maxValue)
        startPoint = CGPoint(x:margin, y: highestYPoint)
        endPoint = CGPoint(x:margin, y:self.bounds.height)
        
        context!.drawLinearGradient(gradient!,
                                    start: startPoint,
                                    end: endPoint,
                                    options: .drawsBeforeStartLocation)
        
        graphPath.lineWidth = 2.0
        graphPath.stroke()
        
        // プロットの描画
        for i in 0..<graphPoints.count {
            var point = CGPoint(x:columnXPoint(i), y:columnYPoint(graphPoints[i]))
            point.x -= 5.0/2
            point.y -= 5.0/2
            
            let circle = UIBezierPath(ovalIn:
                CGRect(origin: point,
                       size: CGSize(width: 5.0, height: 5.0)))
            
            circle.fill()
        }
        
        let linePath = UIBezierPath()
        
        // 上のラインの描画
        linePath.move(to: CGPoint(x:margin, y: topBorder))
        linePath.addLine(to: CGPoint(x: width - margin,
                                        y:topBorder))
        
        
        // 中央のラインの描画
        linePath.move(to: CGPoint(x:margin,
                                     y: graphHeight/2 + topBorder))
        linePath.addLine(to: CGPoint(x:width - margin,
                                        y:graphHeight/2 + topBorder))
        
        
        // 下のラインの描画
        linePath.move(to: CGPoint(x:margin,
                                     y:height - bottomBorder))
        linePath.addLine(to: CGPoint(x:width - margin,
                                        y:height - bottomBorder))
        let color = UIColor(white: 1.0, alpha: 0.3)
        color.setStroke()
        
        linePath.lineWidth = 1.0
        linePath.stroke()
    }
}
