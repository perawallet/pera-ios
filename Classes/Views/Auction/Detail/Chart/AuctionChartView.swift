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
        let chartTopInset: CGFloat = 5.0
        let chartHorizontalInset: CGFloat = 20.0
        let separatorHeight: CGFloat = 1.0
        let horizontalInset: CGFloat = 25.0
        let imageHeight: CGFloat = 4.0
        let bottomInset: CGFloat = 8.0
        let currencyTopOffset: CGFloat = 5.0
        let currencyTrailingOffset: CGFloat = -2.0
    }
    
    private let layout = Layout<LayoutConstants>()
    
    private enum Colors {
        static let lineColor = rgba(0.67, 0.67, 0.72, 0.2)
    }
    
    // MARK: Components

    private(set) lazy var lineChartView: LineChartView = {
        let chartView = LineChartView()
        chartView.backgroundColor = .white
        chartView.drawGridBackgroundEnabled = false
        chartView.noDataText = ""
        
        chartView.legend.enabled = false
        
        chartView.leftAxis.enabled = false
        chartView.leftAxis.axisMinimum = 0
        chartView.leftAxis.axisMaximum = Double(initialValue)
        chartView.leftAxis.axisLineColor = .white
        
        chartView.xAxis.enabled = false
        chartView.xAxis.axisMinimum = 0
        chartView.xAxis.axisMaximum = self.maximumIndex
        chartView.xAxis.axisLineColor = .white
        
        chartView.rightAxis.enabled = false
        
        return chartView
    }()
    
    private lazy var currencySignLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(.overpass, withWeight: .extraBold(size: 15.0)))
            .withTextColor(SharedColors.black)
            .withLine(.single)
            .withAlignment(.left)
            .withText("$")
    }()
    
    private(set) lazy var currentValueLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(.overpass, withWeight: .extraBold(size: 30.0)))
            .withTextColor(SharedColors.black)
            .withLine(.single)
            .withAlignment(.left)
    }()
    
    private lazy var titleLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(.avenir, withWeight: .demiBold(size: 14.0)))
            .withTextColor(.black)
            .withLine(.single)
            .withAlignment(.center)
            .withText("auction-price-current-title".localized)
    }()
    
    private lazy var firstLineView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.lineColor
        return view
    }()
    
    private lazy var secondLineView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.lineColor
        return view
    }()
    
    private lazy var thirdLineView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.lineColor
        return view
    }()
    
    private lazy var forthLineView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.lineColor
        return view
    }()
    
    private lazy var bottomImageView = UIImageView(image: img("img-chart-color"))
    
    private let initialValue: Double
    private let maximumIndex: Double
    
    // MARK: Initialization
    
    init(initialValue: Double, maximumIndex: Double) {
        self.initialValue = initialValue
        self.maximumIndex = maximumIndex
        
        super.init(frame: .zero)
    }
    
    // MARK: Setup
    
    override func configureAppearance() {
        backgroundColor = .white
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        super.prepareLayout()
        
        setupLineChartViewLayout()
        setupFirstLineViewLayout()
        setupSecondLineViewLayout()
        setupThirdLineViewLayout()
        setupForthLineViewLayout()
        setupCurrentValueLabelLayout()
        setupCurrencySignLabelLayout()
        setupTitleLabelLayout()
        setupBottomImageViewLayout()
    }
    
    private func setupLineChartViewLayout() {
        addSubview(lineChartView)
        
        lineChartView.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(layout.current.chartHorizontalInset)
            make.top.equalToSuperview().inset(layout.current.chartTopInset)
        }
    }
    
    private func setupFirstLineViewLayout() {
        addSubview(firstLineView)
        
        firstLineView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.top.equalToSuperview().inset(layout.current.topInset)
            make.height.equalTo(layout.current.separatorHeight)
        }
    }
    
    private func setupSecondLineViewLayout() {
        addSubview(secondLineView)
        
        secondLineView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.top.equalTo(firstLineView.snp.bottom).offset(layout.current.topInset)
            make.height.equalTo(layout.current.separatorHeight)
        }
    }
    
    private func setupThirdLineViewLayout() {
        addSubview(thirdLineView)
        
        thirdLineView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.top.equalTo(secondLineView.snp.bottom).offset(layout.current.topInset)
            make.height.equalTo(layout.current.separatorHeight)
        }
    }
    
    private func setupForthLineViewLayout() {
        addSubview(forthLineView)
        
        forthLineView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.top.equalTo(thirdLineView.snp.bottom).offset(layout.current.topInset)
            make.height.equalTo(layout.current.separatorHeight)
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
    
    func setData(entries: [ChartDataEntry], isCompleted: Bool) {
        let pricesDataSet = LineChartDataSet(entries: entries, label: nil)
        pricesDataSet.drawValuesEnabled = false
        pricesDataSet.drawCircleHoleEnabled = false
        pricesDataSet.drawCirclesEnabled = false
        pricesDataSet.lineWidth = 4.0
        pricesDataSet.mode = .horizontalBezier
        
        if isCompleted {
            pricesDataSet.setColor(rgb(0.67, 0.67, 0.72))
        } else {
            pricesDataSet.setColor(SharedColors.turquois)
        }
        
        lineChartView.data = LineChartData(dataSet: pricesDataSet)
        
        lineChartView.setVisibleXRange(minXRange: Double(1), maxXRange: maximumIndex)
    }
    
    func addData(entries: [ChartDataEntry], at index: Int) {
        for entry in entries {
            lineChartView.data?.addEntry(entry, dataSetIndex: 0)
            lineChartView.notifyDataSetChanged()
        }
        
        lineChartView.setVisibleXRange(minXRange: Double(1), maxXRange: maximumIndex)
        lineChartView.moveViewToX(Double(index))
    }
    
    func setLastData(entry: ChartDataEntry, isCompleted: Bool) {
        let pricesDataSet = LineChartDataSet(entries: [entry], label: nil)
        pricesDataSet.drawValuesEnabled = false
        
        pricesDataSet.drawCircleHoleEnabled = true
        pricesDataSet.drawCirclesEnabled = true
        pricesDataSet.circleHoleRadius = 4.0
        pricesDataSet.circleRadius = 10.0
        
        pricesDataSet.lineWidth = 4.0
        pricesDataSet.mode = .horizontalBezier
        
        if isCompleted {
            pricesDataSet.setColor(rgb(0.67, 0.67, 0.72))
            pricesDataSet.circleColors = [rgb(0.67, 0.67, 0.72).withAlphaComponent(0.1)]
            pricesDataSet.circleHoleColor = rgb(0.67, 0.67, 0.72)
        } else {
            pricesDataSet.setColor(SharedColors.turquois)
            pricesDataSet.circleColors = [SharedColors.turquois.withAlphaComponent(0.1)]
            pricesDataSet.circleHoleColor = SharedColors.turquois
        }
        
        lineChartView.data?.removeDataSetByIndex(1)
        
        lineChartView.data?.addDataSet(pricesDataSet)
    }
    
    func configureCompletedState() {
        titleLabel.text = "auction-price-closing-title".localized
        let dataset = lineChartView.data?.getDataSetByIndex(0)
        dataset?.setColor(rgb(0.67, 0.67, 0.72))
        bottomImageView.image = img("img-chart-dark")
    }
}
