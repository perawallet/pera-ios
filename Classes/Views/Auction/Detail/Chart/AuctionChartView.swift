//
//  AuctionChartView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 7.05.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit
import Charts

class AuctionChartView: BaseView {
    
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let topInset: CGFloat = 20.0
        let horizontalInset: CGFloat = 25.0
        let imageHeight: CGFloat = 4.0
        let bottomInset: CGFloat = 8.0
        let currencyTopOffset: CGFloat = 5.0
        let currencyTrailingOffset: CGFloat = -2.0
    }
    
    private let layout = Layout<LayoutConstants>()
    
    // MARK: Components

    private(set) lazy var lineChartView: LineChartView = {
        let chartView = LineChartView()
        chartView.backgroundColor = .white
        chartView.drawGridBackgroundEnabled = false
        
        chartView.legend.enabled = false
        
        chartView.leftAxis.axisMinimum = 0
        chartView.leftAxis.axisMaximum = initialValue
        chartView.leftAxis.labelTextColor = .white
        chartView.leftAxis.axisLineColor = .white
        chartView.leftAxis.gridColor = rgba(0.67, 0.67, 0.72, 0.2)
        
        chartView.xAxis.enabled = false
        chartView.xAxis.axisMinimum = 0
        chartView.xAxis.axisMaximum = 609
        chartView.xAxis.axisLineColor = .white
        
        chartView.rightAxis.enabled = false
        
        return chartView
    }()
    
    private lazy var currencySignLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(.overpass, withWeight: .bold(size: 15.0)))
            .withTextColor(SharedColors.black)
            .withLine(.single)
            .withAlignment(.left)
            .withText("$")
    }()
    
    private(set) lazy var currentValueLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(.overpass, withWeight: .bold(size: 30.0)))
            .withTextColor(SharedColors.black)
            .withLine(.single)
            .withAlignment(.left)
            .withText("\(initialValue)")
    }()
    
    private lazy var titleLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(.overpass, withWeight: .semiBold(size: 14.0)))
            .withTextColor(.black)
            .withLine(.single)
            .withAlignment(.center)
            .withText("auction-price-current-title".localized)
    }()
    
    private lazy var bottomImageView = UIImageView(image: img("img-chart-color"))
    
    private let initialValue: Double
    
    // MARK: Initialization
    
    init(initialValue: Double) {
        self.initialValue = initialValue
        
        super.init(frame: .zero)
    }
    
    // MARK: Setup
    
    override func configureAppearance() {
        backgroundColor = .white
        
        //setupData()
    }
    
    private func setupData() {
        let pricesDataSet = LineChartDataSet(entries: [ChartDataEntry(x: 0.0, y: initialValue)], label: nil)
        pricesDataSet.drawValuesEnabled = false
        pricesDataSet.drawCircleHoleEnabled = false
        pricesDataSet.drawCirclesEnabled = false
        pricesDataSet.lineWidth = 4.0
        pricesDataSet.mode = .horizontalBezier
        
        let redDiff: CGFloat = 255.0 / 609.0
        let greenDiff: CGFloat = 51.0 / 609.0
        let blueDiff: CGFloat = 255.0 / 609.0
        
        var previousRed: CGFloat = 0
        var previousGreen: CGFloat = 117
        var previousBlue: CGFloat = 255
        
        pricesDataSet.setColor(UIColor(
            red: CGFloat(previousRed / 255),
            green: CGFloat(previousGreen / 255),
            blue: CGFloat(previousBlue / 255),
            alpha: 1
        ))
        
        for _ in 0...609 {
            let color = UIColor(
                red: CGFloat(previousRed / 255),
                green: CGFloat(previousGreen / 255),
                blue: CGFloat(previousBlue / 255),
                alpha: 1
            )
            
            pricesDataSet.addColor(color)
            
            previousRed += redDiff
            previousGreen -= greenDiff
            previousBlue -= blueDiff
        }
        
        lineChartView.data = LineChartData(dataSet: pricesDataSet)
        
        lineChartView.setVisibleXRange(minXRange: Double(1), maxXRange: Double(609))
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        super.prepareLayout()
        
        setupLineChartViewLayout()
        setupCurrentValueLabelLayout()
        setupCurrencySignLabelLayout()
        setupTitleLabelLayout()
        setupBottomImageViewLayout()
    }
    
    private func setupLineChartViewLayout() {
        addSubview(lineChartView)
        
        lineChartView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setupCurrentValueLabelLayout() {
        addSubview(currentValueLabel)
        
        currentValueLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(layout.current.topInset)
        }
    }
    
    private func setupCurrencySignLabelLayout() {
        addSubview(currencySignLabel)
        
        currencySignLabel.snp.makeConstraints { make in
            make.trailing.equalTo(currentValueLabel.snp.leading).offset(layout.current.currencyTrailingOffset)
            make.top.equalTo(currentValueLabel).offset(layout.current.currencyTopOffset)
        }
    }
    
    private func setupTitleLabelLayout() {
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(currentValueLabel.snp.bottom)
            make.centerX.equalToSuperview()
        }
    }
    
    private func setupBottomImageViewLayout() {
        addSubview(bottomImageView)
        
        bottomImageView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.height.equalTo(layout.current.imageHeight)
            make.bottom.equalToSuperview().inset(layout.current.bottomInset)
        }
    }
}

// MARK: API

extension AuctionChartView {
    
    func addData(entry: ChartDataEntry, at index: Int) {
        lineChartView.data?.addEntry(entry, dataSetIndex: 0)
        lineChartView.setVisibleXRange(minXRange: Double(1), maxXRange: Double(609))
        lineChartView.notifyDataSetChanged()
        lineChartView.moveViewToX(Double(index))
    }
    
    func configureCompletedState() {
        titleLabel.text = "auction-price-closing-title".localized
        bottomImageView.image = img("img-chart-dark")
    }
}
