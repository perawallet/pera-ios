//
//  AuctionsViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 1.05.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit
import Charts
import SwiftCharts

class ChartsLineChart: BaseView {
    
    //fileprivate var chart: Chart?

    override func configureAppearance() {
        super.configureAppearance()
        
        let labelSettings = ChartLabelSettings(font: UIFont.systemFont(ofSize: 13.0))
        
        let chartPoints = [(0, 0), (4, 4), (8, 11), (9, 2), (11, 10), (12, 3), (15, 18), (18, 10), (20, 15)].map {
            ChartPoint(x: ChartAxisValueInt($0.0, labelSettings: labelSettings), y: ChartAxisValueInt($0.1))
        }
        
        let xValues = chartPoints.map { $0.x }
        
        let yValues = ChartAxisValuesStaticGenerator.generateYAxisValuesWithChartPoints(
            chartPoints,
            minSegmentCount: 10,
            maxSegmentCount: 20,
            multiple: 2,
            axisValueGenerator: { ChartAxisValueDouble($0, labelSettings: labelSettings) },
            addPaddingSegmentIfEdge: false
        )
        
        let xModel = ChartAxisModel(axisValues: xValues, axisTitleLabel: ChartAxisLabel(text: "Axis title", settings: labelSettings))
        let yModel = ChartAxisModel(
            axisValues: yValues,
            axisTitleLabel: ChartAxisLabel(text: "Axis title", settings: labelSettings.defaultVertical())
        )
        
        let chartSettings = ChartSettings()
        
        let coordsSpace = ChartCoordsSpaceLeftBottomSingleAxis(
            chartSettings: chartSettings,
            chartFrame: CGRect(x: 50, y: 70, width: 300, height: 300),
            xModel: xModel,
            yModel: yModel
        )
        let (xAxisLayer, yAxisLayer, innerFrame) = (coordsSpace.xAxisLayer, coordsSpace.yAxisLayer, coordsSpace.chartInnerFrame)
        
        let lineModel = ChartLineModel(
            chartPoints: chartPoints,
            lineColors: [UIColor.yellow, UIColor.red],
            lineWidth: 2,
            animDuration: 1,
            animDelay: 0
        )
        let chartPointsLineLayer = ChartPointsLineLayer(
            xAxis: xAxisLayer.axis,
            yAxis: yAxisLayer.axis,
            lineModels: [lineModel],
            pathGenerator: CatmullPathGenerator()
        ) // || CubicLinePathGenerator
        
        let settings = ChartGuideLinesDottedLayerSettings(linesColor: UIColor.black, linesWidth: 1.0)
        let guidelinesLayer = ChartGuideLinesDottedLayer(xAxisLayer: xAxisLayer, yAxisLayer: yAxisLayer, settings: settings)
        
        let chart = Chart(
            frame: CGRect(x: 50, y: 70, width: 300, height: 400),
            innerFrame: innerFrame,
            settings: chartSettings,
            layers: [
                xAxisLayer,
                yAxisLayer,
                guidelinesLayer,
                chartPointsLineLayer
            ]
        )
        
        addSubview(chart.view)
    }
    
}

class SwiftChartsLineChart: BaseView {
    
}

class AuctionsViewController: BaseViewController {
    
    private lazy var chartsLineChart = ChartsLineChart()
    
    private lazy var swiftChartsLineChart = SwiftChartsLineChart()
    
    override func configureAppearance() {
        super.configureAppearance()
        
        navigationItem.title = "auction-title".localized
        
        view.addSubview(chartsLineChart)
        
        chartsLineChart.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            make.height.equalTo(UIScreen.main.bounds.height / 2)
        }
        
        view.addSubview(swiftChartsLineChart)
        
        swiftChartsLineChart.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(UIScreen.main.bounds.height / 2)
        }
    }
}
