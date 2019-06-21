//
//  AuctionDetailHeaderView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 20.05.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class AuctionDetailHeaderView: BaseView {
    
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let horizontalInset: CGFloat = 25.0
        let chartHeight: CGFloat = 114.0
        let explanationTopInset: CGFloat = 10.0
        let topInset: CGFloat = 18.0
        let viewWidth: CGFloat = UIScreen.main.bounds.width / 2
    }
    
    private let layout = Layout<LayoutConstants>()
    
    var isBiddable = true {
        didSet {
            if isBiddable == oldValue {
                return
            }
            
            if !isBiddable {
                timerView.isHidden = true
                setupCommittedAmountViewLayout()
            }
        }
    }

    // MARK: Components
    
    private(set) lazy var auctionChartView: AuctionChartView = {
        let view = AuctionChartView(initialValue: initialValue, maximumIndex: maximumIndex)
        return view
    }()
    
    private(set) lazy var remainingAlgosView: RemainingAlgosView = {
        let view = RemainingAlgosView()
        return view
    }()
    
    private(set) lazy var timerView: AuctionTimerView = {
        let view = AuctionTimerView()
        view.time = 0
        view.explanationLabel.textAlignment = .right
        view.timeLabel.textAlignment = .right
        view.explanationLabel.text = "auction-time-left".localized
        return view
    }()
    
    private(set) lazy var committedAmountView: DetailedInformationView = {
        let committedAmountView = DetailedInformationView()
        committedAmountView.backgroundColor = .white
        committedAmountView.separatorView.isHidden = true
        committedAmountView.explanationLabel.text = "auction-detail-committed-title".localized
        committedAmountView.detailLabel.font = UIFont.font(.overpass, withWeight: .bold(size: 15.0))
        return committedAmountView
    }()
    
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
        setupAuctionChartViewLayout()
        setupRemainingAlgosViewLayout()
        setupAuctionTimerViewLayout()
    }
    
    private func setupAuctionChartViewLayout() {
        addSubview(auctionChartView)
        
        auctionChartView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            make.height.equalTo(layout.current.chartHeight)
        }
    }
    
    private func setupRemainingAlgosViewLayout() {
        addSubview(remainingAlgosView)
        
        remainingAlgosView.snp.makeConstraints { make in
            make.top.equalTo(auctionChartView.snp.bottom)
            make.leading.bottom.equalToSuperview()
            make.width.equalTo(layout.current.viewWidth)
        }
        
        remainingAlgosView.explanationLabel.snp.updateConstraints { make in
            make.top.equalToSuperview().inset(layout.current.explanationTopInset)
        }
    }

    private func setupAuctionTimerViewLayout() {
        addSubview(timerView)
        
        timerView.snp.makeConstraints { make in
            make.top.equalTo(auctionChartView.snp.bottom)
            make.trailing.bottom.equalToSuperview()
            make.width.equalTo(layout.current.viewWidth)
        }
        
        timerView.explanationLabel.snp.updateConstraints { make in
            make.top.equalToSuperview().inset(layout.current.explanationTopInset)
        }
    }
    
    private func setupCommittedAmountViewLayout() {
        addSubview(committedAmountView)
        
        committedAmountView.snp.makeConstraints { make in
            make.top.equalTo(auctionChartView.snp.bottom)
            make.trailing.bottom.equalToSuperview()
            make.width.equalTo(layout.current.viewWidth)
        }
        
        committedAmountView.explanationLabel.snp.updateConstraints { make in
            make.top.equalToSuperview().inset(layout.current.explanationTopInset)
        }
    }
}
