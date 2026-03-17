//
//  SimpleChartCell.swift
//  BookShelf
//

import UIKit

final class SimpleChartCell: UICollectionViewCell, ReusableIdentifier {
    static var reuseIdentifier: String { return "SimpleChartCell" }
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.BookShelf.cardBackground
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.BookShelf.separator.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = UIColor.BookShelf.primaryText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 6
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
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
        containerView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            
            stackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8)
        ])
    }
    
    func configureAsBarChart(title: String, data: [(String, Int)]) {
        titleLabel.text = title
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        let maxValue = data.map { $0.1 }.max() ?? 1
        
        for item in data {
            let rowView = createBarRow(label: item.0, value: item.1, maxValue: maxValue)
            stackView.addArrangedSubview(rowView)
        }
    }
    
    func configureAsPieChart(title: String, data: [(String, Int)]) {
        titleLabel.text = title
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        let total = data.reduce(0) { $0 + $1.1 }
        let colors: [UIColor] = [
            .BookShelf.buttonBackground,
            .BookShelf.primaryText,
            .BookShelf.accent,
            .BookShelf.success,
            .BookShelf.warning
        ]
        
        for (index, item) in data.enumerated() where item.1 > 0 {
            let percentage = total > 0 ? Double(item.1) / Double(total) * 100 : 0
            let rowView = createPieRow(
                label: item.0,
                value: item.1,
                percentage: percentage,
                color: colors[index % colors.count]
            )
            stackView.addArrangedSubview(rowView)
        }
        
        if data.isEmpty {
            let emptyLabel = UILabel()
            emptyLabel.text = "Нет данных"
            emptyLabel.textColor = .BookShelf.primaryText.withAlphaComponent(0.5)
            emptyLabel.textAlignment = .center
            emptyLabel.font = .systemFont(ofSize: 12)
            stackView.addArrangedSubview(emptyLabel)
        }
    }
    
    private func createBarRow(label: String, value: Int, maxValue: Int) -> UIView {
        let rowView = UIView()
        rowView.translatesAutoresizingMaskIntoConstraints = false
        let labelLabel = UILabel()
        labelLabel.text = label
        labelLabel.font = .systemFont(ofSize: 11)
        labelLabel.textColor = UIColor.BookShelf.primaryText
        labelLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let barContainer = UIView()
        barContainer.backgroundColor = UIColor.BookShelf.separator
        barContainer.layer.cornerRadius = 3
        barContainer.translatesAutoresizingMaskIntoConstraints = false
        
        let barView = UIView()
        barView.backgroundColor = UIColor.BookShelf.buttonBackground
        barView.layer.cornerRadius = 3
        barView.translatesAutoresizingMaskIntoConstraints = false
        
        let valueLabel = UILabel()
        valueLabel.text = "\(value)"
        valueLabel.font = .systemFont(ofSize: 11, weight: .medium)
        valueLabel.textColor = UIColor.BookShelf.primaryText
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let barWidthMultiplier = maxValue > 0 ? CGFloat(value) / CGFloat(maxValue) : 0
        barContainer.addSubview(barView)
        rowView.addSubview(labelLabel)
        rowView.addSubview(barContainer)
        rowView.addSubview(valueLabel)
        
        NSLayoutConstraint.activate([
            rowView.heightAnchor.constraint(equalToConstant: 24),
            labelLabel.leadingAnchor.constraint(equalTo: rowView.leadingAnchor),
            labelLabel.centerYAnchor.constraint(equalTo: rowView.centerYAnchor),
            labelLabel.widthAnchor.constraint(equalToConstant: 70),
            
            barContainer.leadingAnchor.constraint(equalTo: labelLabel.trailingAnchor, constant: 4),
            barContainer.centerYAnchor.constraint(equalTo: rowView.centerYAnchor),
            barContainer.heightAnchor.constraint(equalToConstant: 16),
            barContainer.widthAnchor.constraint(equalToConstant: 120),
            
            barView.leadingAnchor.constraint(equalTo: barContainer.leadingAnchor),
            barView.topAnchor.constraint(equalTo: barContainer.topAnchor),
            barView.bottomAnchor.constraint(equalTo: barContainer.bottomAnchor),
            barView.widthAnchor.constraint(equalTo: barContainer.widthAnchor, multiplier: barWidthMultiplier),
            
            valueLabel.leadingAnchor.constraint(equalTo: barContainer.trailingAnchor, constant: 4),
            valueLabel.centerYAnchor.constraint(equalTo: rowView.centerYAnchor),
            valueLabel.trailingAnchor.constraint(lessThanOrEqualTo: rowView.trailingAnchor)
        ])
        
        return rowView
    }
    
    private func createPieRow(label: String, value: Int, percentage: Double, color: UIColor) -> UIView {
        let rowView = UIView()
        rowView.translatesAutoresizingMaskIntoConstraints = false
        
        let colorView = UIView()
        colorView.backgroundColor = color
        colorView.layer.cornerRadius = 4
        colorView.translatesAutoresizingMaskIntoConstraints = false
        
        let labelLabel = UILabel()
        labelLabel.text = label
        labelLabel.font = .systemFont(ofSize: 11)
        labelLabel.textColor = UIColor.BookShelf.primaryText
        labelLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let valueLabel = UILabel()
        valueLabel.text = "\(value) (\(String(format: "%.1f", percentage))%)"
        valueLabel.font = .systemFont(ofSize: 11, weight: .medium)
        valueLabel.textColor = UIColor.BookShelf.primaryText
        valueLabel.textAlignment = .right
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        
        rowView.addSubview(colorView)
        rowView.addSubview(labelLabel)
        rowView.addSubview(valueLabel)
        
        NSLayoutConstraint.activate([
            rowView.heightAnchor.constraint(equalToConstant: 20),
            colorView.leadingAnchor.constraint(equalTo: rowView.leadingAnchor),
            colorView.centerYAnchor.constraint(equalTo: rowView.centerYAnchor),
            colorView.widthAnchor.constraint(equalToConstant: 8),
            colorView.heightAnchor.constraint(equalToConstant: 8),
            labelLabel.leadingAnchor.constraint(equalTo: colorView.trailingAnchor, constant: 4),
            labelLabel.centerYAnchor.constraint(equalTo: rowView.centerYAnchor),
            valueLabel.trailingAnchor.constraint(equalTo: rowView.trailingAnchor),
            valueLabel.centerYAnchor.constraint(equalTo: rowView.centerYAnchor),
            valueLabel.leadingAnchor.constraint(greaterThanOrEqualTo: labelLabel.trailingAnchor, constant: 4)
        ])
        return rowView
    }
}
