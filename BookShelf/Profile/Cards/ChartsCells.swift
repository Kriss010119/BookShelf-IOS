//
//  ChartsCells.swift
//  BookShelf
//

import UIKit
import DGCharts

// MARK: - Bar Chart Cell
final class BarChartCell: UICollectionViewCell, ReusableIdentifier {
    static var reuseIdentifier: String { return "BarChartCell" }
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.BookShelf.cardBackground
        view.layer.cornerRadius = 16
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.BookShelf.separator.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = UIColor.BookShelf.primaryText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let barChartView: BarChartView = {
        let chart = BarChartView()
        chart.translatesAutoresizingMaskIntoConstraints = false
        chart.noDataText = "Нет данных"
        chart.noDataFont = .systemFont(ofSize: 12)
        chart.noDataTextColor = UIColor.BookShelf.primaryText.withAlphaComponent(0.5)
        chart.backgroundColor = .clear
        chart.drawBarShadowEnabled = false
        chart.drawValueAboveBarEnabled = true
        chart.doubleTapToZoomEnabled = false
        chart.pinchZoomEnabled = false
        chart.scaleXEnabled = false
        chart.scaleYEnabled = false
        chart.legend.enabled = false

        chart.xAxis.labelPosition = .bottom
        chart.xAxis.drawGridLinesEnabled = false
        chart.xAxis.drawAxisLineEnabled = true
        chart.xAxis.drawLabelsEnabled = true
        chart.xAxis.labelTextColor = UIColor.BookShelf.primaryText.withAlphaComponent(0.7)
        chart.xAxis.labelFont = .systemFont(ofSize: 9)
        chart.xAxis.axisLineColor = UIColor.BookShelf.separator
        chart.xAxis.granularity = 1
        chart.xAxis.labelRotatedHeight = 20
        chart.xAxis.labelRotationAngle = -45
        
        chart.leftAxis.enabled = true
        chart.leftAxis.labelTextColor = UIColor.BookShelf.primaryText.withAlphaComponent(0.7)
        chart.leftAxis.labelFont = .systemFont(ofSize: 9)
        chart.leftAxis.axisLineColor = UIColor.BookShelf.separator
        chart.leftAxis.gridColor = UIColor.BookShelf.separator.withAlphaComponent(0.3)
        chart.leftAxis.granularity = 1
        chart.leftAxis.drawZeroLineEnabled = true
        chart.leftAxis.zeroLineColor = UIColor.BookShelf.separator
        chart.leftAxis.axisMinimum = 0
        
        chart.rightAxis.enabled = false
        chart.xAxis.gridColor = .clear
        chart.animate(yAxisDuration: 0.5, easingOption: .easeInOutQuart)
        return chart
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(barChartView)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            barChartView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            barChartView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 4),
            barChartView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -4),
            barChartView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12)
        ])
    }
    
    func configure(title: String, data: [(String, Int)], color: UIColor = .BookShelf.buttonBackground) {
        titleLabel.text = title
        
        guard !data.isEmpty else {
            barChartView.data = nil
            return
        }
        var entries: [BarChartDataEntry] = []
        for i in 0..<data.count {
            entries.append(BarChartDataEntry(x: Double(i), y: Double(data[i].1)))
        }
        let dataSet = BarChartDataSet(entries: entries, label: "")
        dataSet.colors = [color]
        dataSet.valueTextColor = UIColor.BookShelf.primaryText
        dataSet.valueFont = .systemFont(ofSize: 8)
        dataSet.drawValuesEnabled = true
        dataSet.valueFormatter = IntegerValueFormatter()
        let chartData = BarChartData(dataSet: dataSet)
        chartData.barWidth = 0.5
        let xValues = data.map { $0.0 }
        let xAxisFormatter = IndexAxisValueFormatter(values: xValues)
        barChartView.xAxis.valueFormatter = xAxisFormatter
        barChartView.xAxis.setLabelCount(min(xValues.count, 5), force: false)
        barChartView.data = chartData
        barChartView.notifyDataSetChanged()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        barChartView.data = nil
    }
}

// MARK: - Pie Chart Cell
final class PieChartCell: UICollectionViewCell, ReusableIdentifier {
    static var reuseIdentifier: String { return "PieChartCell" }
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.BookShelf.cardBackground
        view.layer.cornerRadius = 16
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.BookShelf.separator.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = UIColor.BookShelf.primaryText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let pieChartView: PieChartView = {
        let chart = PieChartView()
        chart.translatesAutoresizingMaskIntoConstraints = false
        chart.noDataText = "Нет данных"
        chart.noDataFont = .systemFont(ofSize: 12)
        chart.noDataTextColor = UIColor.BookShelf.primaryText.withAlphaComponent(0.5)
        chart.backgroundColor = .clear
        chart.usePercentValuesEnabled = true
        chart.drawHoleEnabled = true
        chart.holeColor = UIColor.BookShelf.cardBackground
        chart.holeRadiusPercent = 0.4
        chart.transparentCircleRadiusPercent = 0.45
        chart.drawCenterTextEnabled = false
        chart.rotationEnabled = true
        chart.highlightPerTapEnabled = true
        chart.legend.enabled = true
        chart.legend.textColor = UIColor.BookShelf.primaryText
        chart.legend.font = .systemFont(ofSize: 10)
        chart.legend.orientation = .vertical
        chart.legend.horizontalAlignment = .right
        chart.legend.verticalAlignment = .top
        chart.legend.form = .circle
        chart.legend.formSize = 10
        chart.legend.xEntrySpace = 4
        chart.legend.yEntrySpace = 2
        chart.animate(xAxisDuration: 0.5, yAxisDuration: 0.5, easingOption: .easeInOutQuart)
        return chart
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(pieChartView)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            pieChartView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            pieChartView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 4),
            pieChartView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -4),
            pieChartView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12)
        ])
    }
    
    func configure(title: String, data: [(String, Int)]) {
        titleLabel.text = title
        
        let total = data.reduce(0) { $0 + $1.1 }
        guard total > 0 else {
            pieChartView.data = nil
            return
        }
        
        var entries: [PieChartDataEntry] = []
        let colors: [UIColor] = [
            UIColor.BookShelf.buttonBackground,
            UIColor.BookShelf.primaryText,
            UIColor.BookShelf.accent,
            UIColor.BookShelf.success,
            UIColor.BookShelf.warning,
            UIColor(hex: "9C27B0"),
            UIColor(hex: "FF5722"),
            UIColor(hex: "607D8B")
        ]
        
        for item in data where item.1 > 0 {
            entries.append(PieChartDataEntry(value: Double(item.1), label: item.0))
        }
        
        let dataSet = PieChartDataSet(entries: entries, label: "")
        dataSet.colors = colors
        dataSet.valueTextColor = UIColor.BookShelf.primaryText
        dataSet.valueFont = .systemFont(ofSize: 9)
        dataSet.sliceSpace = 1
        dataSet.selectionShift = 3
        dataSet.drawValuesEnabled = false
        let chartData = PieChartData(dataSet: dataSet)
        pieChartView.data = chartData
        pieChartView.notifyDataSetChanged()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        pieChartView.data = nil
    }
}

// MARK: - Вспомогательный форматтер для целых чисел
class IntegerValueFormatter: ValueFormatter {
    func stringForValue(_ value: Double, entry: ChartDataEntry, dataSetIndex: Int, viewPortHandler: ViewPortHandler?) -> String {
        return "\(Int(value))"
    }
}
