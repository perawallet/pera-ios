// Copyright 2019 Algorand, Inc.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//
//   AlgorandChartView.swift

import Charts

class AlgorandChartView: BaseView {

    weak var delegate: AlgorandChartViewDelegate?

    private lazy var lineChartView: AlgorandLineChartView = {
        let lineChartView = AlgorandLineChartView()
        lineChartView.chartDescription?.enabled = chartCustomizer.isDescriptionEnabled
        lineChartView.dragEnabled = chartCustomizer.isDragEnabled
        lineChartView.setScaleEnabled(chartCustomizer.isScaleEnabled)
        lineChartView.pinchZoomEnabled = chartCustomizer.isPinchZoomEnabled
        lineChartView.highlightPerTapEnabled = chartCustomizer.isHighlightPerTapEnabled
        lineChartView.legend.enabled = chartCustomizer.isLegendEnabled
        lineChartView.legend.form = chartCustomizer.legendForm
        lineChartView.rightAxis.enabled = chartCustomizer.isRightAxisEnabled
        lineChartView.dragYEnabled = chartCustomizer.isDragYEnabled
        lineChartView.xAxis.drawAxisLineEnabled = chartCustomizer.xAxisCustomizer.isAxisLineEnabled
        lineChartView.xAxis.drawGridLinesEnabled = chartCustomizer.xAxisCustomizer.isGridLinesEnabled
        lineChartView.xAxis.drawLabelsEnabled = chartCustomizer.xAxisCustomizer.isAxisLabelsEnabled
        lineChartView.xAxis.granularityEnabled = chartCustomizer.xAxisCustomizer.isGranularityEnabled
        lineChartView.leftAxis.drawAxisLineEnabled = chartCustomizer.yAxisCustomizer.isAxisLineEnabled
        lineChartView.leftAxis.drawGridLinesEnabled = chartCustomizer.yAxisCustomizer.isGridLinesEnabled
        lineChartView.leftAxis.drawLabelsEnabled = chartCustomizer.yAxisCustomizer.isAxisLabelsEnabled
        lineChartView.leftAxis.granularityEnabled = chartCustomizer.yAxisCustomizer.isGranularityEnabled
        lineChartView.minOffset = chartCustomizer.minimumOffset
        return lineChartView
    }()

    private let chartCustomizer: AlgorandChartViewCustomizable

    init(chartCustomizer: AlgorandChartViewCustomizable) {
        self.chartCustomizer = chartCustomizer
        super.init(frame: .zero)
    }

    override func configureAppearance() {
        backgroundColor = .clear
        lineChartView.noDataText = chartCustomizer.emptyText
    }

    override func prepareLayout() {
        prepareWholeScreenLayoutFor(lineChartView)
    }

    override func linkInteractors() {
        lineChartView.delegate = self
        let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleHighlightingChart(_:)))
        lineChartView.addGestureRecognizer(gestureRecognizer)
    }
}

extension AlgorandChartView {
    @objc
    private func handleHighlightingChart(_ gesture: UIPanGestureRecognizer) {
        if gesture.isGestureCompleted {
            removeChartHighlighting()
            return
        }

        highlightChart(with: gesture)
    }

    private func removeChartHighlighting() {
        lineChartView.highlightValue(nil)
        lineChartView.marker = nil

        if let dataSet = lineChartView.data?.dataSets.last as? LineChartDataSet,
           let currentColor = dataSet.colors.first {
            dataSet.setColor(currentColor.withAlphaComponent(1.0))
        }

        delegate?.algorandChartViewDidDeselect(self)
    }

    private func highlightChart(with gesture: UIPanGestureRecognizer) {
        if let dataSet = lineChartView.data?.dataSets.last as? LineChartDataSet {
            // Add circle point for the highlighted value
            dataSet.drawCirclesEnabled = gesture.isGestureCompleted
            dataSet.drawVerticalHighlightIndicatorEnabled = true

            if let currentColor = dataSet.colors.first {
                addMarkerForHighlightedValue(with: currentColor)
                dataSet.setColor(currentColor.withAlphaComponent(0.5))
            }
        }
    }

    private func addMarkerForHighlightedValue(with color: UIColor) {
        let marker = ChartCircleMarker(outsideColor: Colors.Background.secondary, insideColor: color.withAlphaComponent(1.0))
        marker.size = CGSize(width: 10, height: 10)
        lineChartView.marker = marker
    }
}

extension AlgorandChartView: ChartViewDelegate {
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        delegate?.algorandChartView(self, didSelectItemAt: Int(highlight.x))
    }

    func chartValueNothingSelected(_ chartView: ChartViewBase) {
        delegate?.algorandChartViewDidDeselect(self)
    }
}

extension AlgorandChartView {
    func bind(_ viewModel: AlgorandChartViewModelConvertible) {
        lineChartView.clear()

        if let data = viewModel.chartData() {
            lineChartView.data = data
        }
    }
}

protocol AlgorandChartViewDelegate: class {
    func algorandChartView(_ algorandChartView: AlgorandChartView, didSelectItemAt index: Int)
    func algorandChartViewDidDeselect(_ algorandChartView: AlgorandChartView)
}
