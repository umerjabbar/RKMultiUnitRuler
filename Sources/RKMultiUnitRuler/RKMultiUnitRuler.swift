//
//  Created by Farshid Ghods on 12/27/16.
//

import UIKit

public enum RKLayerDirection: Int {
    case vertical = 0
    case horizontal
}

public class RKSegmentUnit: NSObject, NSCopying {
    public var unit: Dimension?
    public var name: String = ""
    public var image: UIImage?
    public var markerTypes: [RKRangeMarkerType] = []
    
    public var formatter: MeasurementFormatter?
    //    {
    //        didSet {
    //            if let formatter = formatter, formatter.numberFormatter.numberStyle == .decimal, formatter.numberFormatter.maximumFractionDigits != 0 {
    //                let numberFormatter = NumberFormatter()
    //                numberFormatter.paddingPosition = .afterSuffix
    //                numberFormatter.maximumFractionDigits = 2
    //                formatter.numberFormatter = numberFormatter
    //            }
    //        }
    //    }
    
    public convenience init(name: String, unit: Dimension, formatter: MeasurementFormatter) {
        self.init()
        self.name = name
        self.unit = unit
        self.formatter = formatter
    }
    
    public func copy(with zone: NSZone? = nil) -> Any {
        let copy = RKSegmentUnit()
        copy.image = image
        copy.name = name
        copy.markerTypes = markerTypes
        copy.formatter = formatter
        return copy
    }
}

public class RKSegmentUnitControlStyle: NSObject {
    public var textFieldBackgroundColor: UIColor = .clear
    public var textFieldFont: UIFont = Constants.defaultTextFieldFont
    public var textFieldTextColor: UIColor = .label
    public var flagOfView: Bool = false
    public var pointerColor: UIColor = .label
    public var textOfUnit: String = ""
    public var textOfUnitFont: UIFont = Constants.defaultUnitLabelFont
    public var textOfUnitColor: UIColor = .secondaryLabel
    public var scrollViewBackgroundColor: UIColor = .clear
    public var colorOverrides: [RKRange<Float>: UIColor]?
    public var textFieldColorOverrides: [RKRange<Float>: UIColor]?
}

public protocol RKMultiUnitRulerDataSource: AnyObject {
    func unitForSegment(at index: Int) -> RKSegmentUnit
    func rangeForUnit(_ unit: Dimension) -> RKRange<Float>
    var numberOfSegments: Int { get }
    func styleForUnit(_ unit: Dimension) -> RKSegmentUnitControlStyle
}

public protocol RKMultiUnitRulerDelegate: AnyObject {
    func valueChanged(measurement: Measurement<Unit>)
}


public class RKMultiUnitRuler: UIView {
    public var dataSource: RKMultiUnitRulerDataSource? {
        didSet {
            setupViews()
        }
    }
    public var delegate: RKMultiUnitRulerDelegate?
    public var measurement: Measurement<Unit>?
    private var segmentControl: UISegmentedControl = UISegmentedControl()
    private var segmentedViews: Array<UIView>?
    public var pointerViews: Array<RKRangePointerView>?
    public var pointerView: RKRangePointerView?
    
    private var scrollViews: Array<RKRangeScrollView>?
    private var textViews: Array<RKRangeTextView>?
    public var direction: RKLayerDirection = .horizontal
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupDefaultValues() {
        
    }
    
    open func refresh() {
        setupViews()
        
        
    }
    
    private func setupViews() {
        
        if let _ = self.dataSource {
            self.subviews.forEach({ $0.removeFromSuperview() })
            let segmentControl = setupSegmentControl()
            
            let (segmentedViews, scrollViews, textViews, pointerViews) = setupSegmentViews()
            self.segmentedViews = segmentedViews
            self.scrollViews = scrollViews
            self.textViews = textViews
            self.pointerViews = pointerViews
            var constraints = Array<NSLayoutConstraint>()
            switch (self.direction) {
            case .horizontal:
                constraints += NSLayoutConstraint.constraints(
                    withVisualFormat: "H:|-5-[segmentControl]-5-|",
                    options: NSLayoutConstraint.FormatOptions.directionLeadingToTrailing,
                    metrics: nil,
                    views: ["segmentControl": self.segmentControl])
                for segmentView in segmentedViews {
                    constraints += NSLayoutConstraint.constraints(
                        withVisualFormat: "H:|-5-[segmentView]-5-|",
                        options: NSLayoutConstraint.FormatOptions.directionLeadingToTrailing,
                        metrics: nil,
                        views: ["segmentView": segmentView])
                    constraints += NSLayoutConstraint.constraints(
                        withVisualFormat: "V:|-5-[segmentControl]-5-[segmentView]-5-|",
                        options: NSLayoutConstraint.FormatOptions.directionLeadingToTrailing,
                        metrics: nil,
                        views: ["segmentView": segmentView, "segmentControl": segmentControl])
                }
            case .vertical:
                constraints += NSLayoutConstraint.constraints(
                    withVisualFormat: "H:|-5-[segmentControl]-5-|",
                    options: NSLayoutConstraint.FormatOptions.directionLeadingToTrailing,
                    metrics: nil,
                    views: ["segmentControl": self.segmentControl])
                for segmentView in segmentedViews {
                    constraints += NSLayoutConstraint.constraints(
                        withVisualFormat: "H:|-5-[segmentView]-5-|",
                        options: NSLayoutConstraint.FormatOptions.directionLeadingToTrailing,
                        metrics: nil,
                        views: ["segmentView": segmentView])
                    constraints += NSLayoutConstraint.constraints(
                        withVisualFormat: "V:|-5-[segmentControl]-5-[segmentView]-5-|",
                        options: NSLayoutConstraint.FormatOptions.directionLeadingToTrailing,
                        metrics: nil,
                        views: ["segmentView": segmentView, "segmentControl": segmentControl])
                }
                
            }
            segmentControl.addTarget(self,
                                     action: #selector(RKMultiUnitRuler.segmentSelectionChanged(_:)),
                                     for: UIControl.Event.valueChanged)
            self.addConstraints(constraints)
            self.segmentSelectionChanged(self.segmentControl)
        }
    }
    
    private func setupSegmentControl() -> UISegmentedControl {
        if let dataSource = dataSource {
            segmentControl = UISegmentedControl()
            segmentControl.translatesAutoresizingMaskIntoConstraints = false
            for index in 0 ... dataSource.numberOfSegments - 1 {
                segmentControl.insertSegment(
                    withTitle: dataSource.unitForSegment(at: index).name,
                    at: index, animated: true
                )
            }
            
            if (dataSource.numberOfSegments > 0) {
                self.segmentControl.selectedSegmentIndex = 0
                if let unit = dataSource.unitForSegment(at: 0).unit {
                    let style = dataSource.styleForUnit(unit)
                    segmentControl.tintColor = UIColor.tintColor
                    segmentControl.setTitleTextAttributes(
                        [NSAttributedString.Key.foregroundColor: style.textFieldTextColor,
                         NSAttributedString.Key.font: Constants.defaultSegmentControlTitleFont], for: .normal)
                    
                }
            }
            segmentControl.isHidden = true
            addSubview(segmentControl)
        }
        return self.segmentControl
    }
    
    @objc func segmentSelectionChanged(_ sender: UISegmentedControl) {
        if let segmentedViews = self.segmentedViews {
            for i in 0 ... segmentedViews.count - 1 {
                if i == segmentControl.selectedSegmentIndex {
                    segmentedViews[i].isHidden = false
                } else {
                    segmentedViews[i].isHidden = true
                }
                
                let _ = self.textViews?[i].resignFirstResponder()
            }
        }
        if let dataSource = self.dataSource, let scrollViews = self.scrollViews {
            let segmentUnit = dataSource.unitForSegment(at: segmentControl.selectedSegmentIndex)
            if let measurement = self.measurement, let unit = segmentUnit.unit {
                let value = Float(measurement.value)
                self.textViews?[segmentControl.selectedSegmentIndex].currentValue = value
                scrollViews[segmentControl.selectedSegmentIndex].currentValue = value
                scrollViews[segmentControl.selectedSegmentIndex].scrollToCurrentValueOffset()
                let style = dataSource.styleForUnit(unit)
                self.segmentControl.setTitleTextAttributes(
                    [NSAttributedString.Key.foregroundColor: style.textFieldTextColor,
                     NSAttributedString.Key.font: Constants.defaultSegmentControlTitleFont], for: .normal)
            }
        }
    }
    
    @objc func scrollViewCurrentValueChanged(_ sender: RKRangeScrollView) {
        if let dataSource = self.dataSource {
            let activeSegmentUnit = dataSource.unitForSegment(at: segmentControl.selectedSegmentIndex)
            if let unit = activeSegmentUnit.unit,
               let scrollViewOfSelectedSegment = self.scrollViews?[segmentControl.selectedSegmentIndex] {
                self.measurement = Measurement(value: Double(scrollViewOfSelectedSegment.currentValue), unit: unit)
                self.delegate?.valueChanged(measurement: self.measurement!)
                updateTextFields()
            }
        }
    }
    
    @objc func textViewValueChanged(_ sender: RKRangeTextView) {
        if let dataSource = self.dataSource {
            let activeSegmentUnit = dataSource.unitForSegment(at: segmentControl.selectedSegmentIndex)
            if let textViews = self.textViews, let unit = activeSegmentUnit.unit {
                self.measurement = Measurement(value: Double(textViews[segmentControl.selectedSegmentIndex].currentValue), unit: unit)
                self.delegate?.valueChanged(measurement: self.measurement!)
            }
            self.updateScrollViews()
        }
    }
    
    func updateScrollViews() {
        if let dataSource = self.dataSource {
            if let scrollViews = self.scrollViews {
                for index in 0 ... scrollViews.count - 1 {
                    let segmentUnit = dataSource.unitForSegment(at: index)
                    if let measurement = self.measurement, let unit = segmentUnit.unit {
                        let value = Float(measurement.value)
                        scrollViews[index].currentValue = value
                    }
                    if index == segmentControl.selectedSegmentIndex {
                        scrollViews[index].scrollToCurrentValueOffset()
                    }
                }
            }
        }
    }
    
    func updateTextFields() {
        if let dataSource = self.dataSource {
            if let scrollViews = self.scrollViews {
                for index in 0 ... scrollViews.count - 1 {
                    let segmentUnit = dataSource.unitForSegment(at: index)
                    if let measurement = self.measurement, let unit = segmentUnit.unit {
                        let value = Float(measurement.value)
                        //value = Float(lroundf(value / minScale)) * minScale
                        if index != segmentControl.selectedSegmentIndex {
                            self.textViews?[index].currentValue = value
                        } else {
                            DispatchQueue.main.async {
                                let _ = self.textViews?[index].resignFirstResponder()
                                self.textViews?[index].currentValue = value
                                self.textViews?[index].updateTextValue(value: value.formatted(.number))
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    private func setupSegmentViews() -> (Array<UIView>, Array<RKRangeScrollView>, Array<RKRangeTextView>, Array<RKRangePointerView>) {
        var segmentViews: [UIView] = []
        var pointerViews: [RKRangePointerView] = []
        var scrollViews: [RKRangeScrollView] = []
        var textViews: [RKRangeTextView] = []
        if let dataSource = self.dataSource {
            var names = Array<String>()
            for index in 0 ... dataSource.numberOfSegments - 1 {
                let segmentView: UIView = UIView(frame: CGRect.zero)
                segmentView.translatesAutoresizingMaskIntoConstraints = false
                let segmentUnit = dataSource.unitForSegment(at: index)
                if let unit = segmentUnit.unit {
                    let style = dataSource.styleForUnit(unit)
                    let range = dataSource.rangeForUnit(unit)
                    names.append(segmentUnit.name)
                    let pointerView = self.setupPointerView(
                        inSegmentView: segmentView,
                        unit: segmentUnit,
                        segmentStyle: style
                    )
                    let scrollView = self.setupSegmentScrollView(
                        inSegmentView: segmentView,
                        unit: segmentUnit,
                        segmentStyle: style,
                        range: range
                    )
                    let textView = self.setupSegmentBottomView(
                        inSegmentView: segmentView,
                        unit: segmentUnit,
                        style: style
                    )
                    let underlineView = self.setupSegmentLineUnderBottomView(
                        inSegmentView: segmentView
                    )
                    let lbl = self.setupLabelBottomView(
                        inSegmentView: segmentView, style: style
                    )
                    
                    //                    lbl.frame = CGRect(x: -30, y:0, width:self.bounds.width, height:self.bounds.height)
                    
                    let segmentSubViews = [
                        "scrollView": scrollView,
                        "textView": textView,
                        "underlineView": underlineView,
                        "pointerView": pointerView,
                        "lbl": lbl
                    ]
                    var constraints = Array<NSLayoutConstraint>()
                    switch (self.direction) {
                    case .vertical:
                        constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|-5-[scrollView]-5-|",
                                                                      options: NSLayoutConstraint.FormatOptions.directionLeadingToTrailing,
                                                                      metrics: nil,
                                                                      views: segmentSubViews)
                        constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-5-[pointerView(10)]-0-[scrollView]-5-[textView]-5-|",
                                                                      options: NSLayoutConstraint.FormatOptions.directionLeadingToTrailing,
                                                                      metrics: nil,
                                                                      views: segmentSubViews)
                        constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|-5-[pointerView]-5-|",
                                                                      options: NSLayoutConstraint.FormatOptions.directionLeadingToTrailing,
                                                                      metrics: nil,
                                                                      views: segmentSubViews)
                        constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-5-[pointerView(10)]-0-[scrollView]-5-[underlineView]-5-|",
                                                                      options: NSLayoutConstraint.FormatOptions.directionLeadingToTrailing,
                                                                      metrics: nil,
                                                                      views: segmentSubViews)
                        constraints += NSLayoutConstraint.constraints(
                            withVisualFormat: "V:|-10-[textView(25)]-1-[underlineView(2)]",
                            options: NSLayoutConstraint.FormatOptions.alignAllCenterX,
                            metrics: nil,
                            views: segmentSubViews)
                    case .horizontal:
                        constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-5-[textView]-5-|",
                                                                      options: NSLayoutConstraint.FormatOptions.directionLeadingToTrailing,
                                                                      metrics: nil,
                                                                      views: segmentSubViews)
                        constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|[lbl]-0-|",
                                                                      options: NSLayoutConstraint.FormatOptions.alignAllCenterX,
                                                                      metrics: nil,
                                                                      views: segmentSubViews)
                        constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-5-[scrollView]-5-|",
                                                                      options: NSLayoutConstraint.FormatOptions.directionLeadingToTrailing,
                                                                      metrics: nil,
                                                                      views: segmentSubViews)
                        constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-5-[pointerView]-5-|",
                                                                      options: NSLayoutConstraint.FormatOptions.directionLeadingToTrailing,
                                                                      metrics: nil,
                                                                      views: segmentSubViews)
                        constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-5-[underlineView]-5-|",
                                                                      options: NSLayoutConstraint.FormatOptions.directionLeadingToTrailing,
                                                                      metrics: nil,
                                                                      views: segmentSubViews)
                        constraints += NSLayoutConstraint.constraints(
                            withVisualFormat: "V:|-5-[textView(55)]-5-[lbl(20)]-5-[pointerView(10)]-0-[scrollView]-1-[underlineView(2)]-5-|",
                            options: NSLayoutConstraint.FormatOptions.directionLeadingToTrailing,
                            metrics: nil,
                            views: segmentSubViews)
                    }
                    self.backgroundColor = style.scrollViewBackgroundColor
                    segmentView.addConstraints(constraints)
                    segmentView.backgroundColor = style.scrollViewBackgroundColor
                    
                    textView.frame = CGRect(x: 0, y: 0, width: textView.frame.width, height: textView.frame.height)
                    textView.parentView = self
                    segmentViews.append(segmentView)
                    scrollViews.append(scrollView)
                    textViews.append(textView)
                    pointerViews.append(pointerView)
                    self.addSubview(segmentView)
                    //                    lbl.frame = CGRect(x: -60, y:0, width:self.bounds.width, height:self.bounds.height)
                    
                }
            }
        }
        return (segmentViews, scrollViews, textViews, pointerViews)
    }
    
    private func setupPointerView(inSegmentView parent: UIView,
                                  unit segmentUnit: RKSegmentUnit,
                                  segmentStyle style: RKSegmentUnitControlStyle) -> RKRangePointerView {
        let pointerView = RKRangePointerView(frame: self.bounds)
        pointerView.translatesAutoresizingMaskIntoConstraints = false
        pointerView.direction = self.direction
        pointerView.backgroundColor = style.scrollViewBackgroundColor
        pointerView.fillColor = style.pointerColor
        parent.addSubview(pointerView)
        return pointerView
    }
    
    private func setupSegmentScrollView(inSegmentView parent: UIView,
                                        unit segmentUnit: RKSegmentUnit,
                                        segmentStyle style: RKSegmentUnitControlStyle,
                                        range floatRange: RKRange<Float>) -> RKRangeScrollView {
        
        let scrollView = RKRangeScrollView(frame: self.bounds)
        scrollView.markerTypes = segmentUnit.markerTypes
        scrollView.backgroundColor = style.scrollViewBackgroundColor
        scrollView.range = floatRange
        scrollView.colorOverrides = style.colorOverrides
        scrollView.direction = self.direction
        scrollView.flag = style.flagOfView
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addTarget(self,
                             action: #selector(RKMultiUnitRuler.scrollViewCurrentValueChanged(_:)),
                             for: .valueChanged)
        parent.addSubview(scrollView)
        
        return scrollView
    }
    
    private func setupSegmentBottomView(inSegmentView parent: UIView,
                                        unit segmentUnit: RKSegmentUnit,
                                        style: RKSegmentUnitControlStyle) -> RKRangeTextView {
        let textView = RKRangeTextView(frame: self.bounds)
        textView.backgroundColor = style.textFieldBackgroundColor
        textView.textField.backgroundColor = style.textFieldBackgroundColor
        textView.textField.textColor = style.textFieldTextColor
        textView.textField.textAlignment = .center
        textView.flagOfView = style.flagOfView
        textView.formatter = segmentUnit.formatter
        textView.textField.font = UIFont.boldSystemFont(ofSize: 45)
        textView.textField.text = ""
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.addTarget(
            self,
            action: #selector(RKMultiUnitRuler.textViewValueChanged(_:)),
            for: .valueChanged
        )
        textView.colorOverrides = style.textFieldColorOverrides
        parent.addSubview(textView)
        return textView
    }
    
    public var isArabic: Bool {
        if #available(iOS 16, *) {
            return Locale.current.language.languageCode?.identifier ?? "en" == "ar"
        } else {
            return Locale.current.languageCode ?? "en" == "ar"
        }
    }
    
    private func setupLabelBottomView(inSegmentView parent: UIView,style: RKSegmentUnitControlStyle) -> UIView {
        let label = UILabel(frame: self.bounds)
        label.text = style.textOfUnit
        label.font = style.textOfUnitFont
        label.textColor = style.textOfUnitColor
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        parent.addSubview(label)
        return label
    }
    
    private func setupSegmentLineUnderBottomView(inSegmentView parent: UIView) -> UIView {
        let view = UIView(frame: self.bounds)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        parent.addSubview(view)
        return view
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        if let segmentedViews = self.segmentedViews {
            for segmentView in segmentedViews {
                segmentView.layoutSubviews()
            }
        }
        updateScrollViews()
        updateTextFields()
    }
}
extension UITextField {
    
    func setUnderLine() {
        let border = CALayer()
        let width = CGFloat(0.5)
        border.borderColor = UIColor.darkGray.cgColor
        border.frame = CGRect(x: 0, y: self.frame.size.height - width, width:  self.frame.size.width - 10, height: self.frame.size.height)
        border.borderWidth = width
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
    }
    
}
