//
//  AuctionsViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 1.05.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit
import Charts

class AuctionsViewController: BaseViewController {
    
    private lazy var auctionChartView = AuctionChartView(initialValue: 10)
    
    private var prices = [10.0, 9.5, 8.7, 7.9, 6.5, 6.0, 5.2, 4.0, 3.7, 3.0, 1.7, 1.6, 1.5, 1.0, 0.4, 0.0]
    
    private var timer: Timer?
    private var index = 1
    
    override func prepareLayout() {
        super.prepareLayout()
        
        setupChartViewLayout()
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        
        navigationItem.title = "auction-title".localized
        
        timer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(updateChart), userInfo: nil, repeats: true)
    }
    
    private func setupChartViewLayout() {
        view.addSubview(auctionChartView)
        
        auctionChartView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalToSuperview().inset(40.0)
            make.height.equalTo(100.0)
        }
    }
    
    @objc
    private func updateChart() {
        if index >= prices.count {
            auctionChartView.configureCompletedState()
            return
        }
        
        auctionChartView.currentValueLabel.text = "\(prices[index])"
        auctionChartView.addData(entry: ChartDataEntry(x: Double(index), y: prices[index]), at: index)
        
        index += 1
    }
}
