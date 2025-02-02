//
//  RKMultiUnitRulerView.swift
//  RKMultiUnitRuler
//
//  Created by Umer Jabbar on 01/02/2025.
//

import SwiftUI

public struct RKMultiUnitRulerGlucoseView: UIViewRepresentable {
    
    var view = RKMultiUnitRuler()
    var textFieldColorOverrides: [RKRange<Float>: UIColor]?
    
    var valueUpdated: ((Double) -> Void)?
    
    public init(textFieldColorOverrides: [RKRange<Float> : UIColor]? = nil, valueUpdated: ((Double) -> Void)?) {
        self.textFieldColorOverrides = textFieldColorOverrides
        self.valueUpdated = valueUpdated
    }
    
    public func makeUIView(context: Context) -> RKMultiUnitRuler {
        view.direction = .horizontal
        view.delegate = context.coordinator
        view.dataSource = context.coordinator
        view.measurement = Measurement(value: 120, unit: UnitMass.kilograms)
        return view
    }
    
    public func updateUIView(_ uiView: RKMultiUnitRuler, context: Context) {
        
    }
    
    public func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self, textFieldColorOverrides: textFieldColorOverrides)
    }
    
    public final class Coordinator: NSObject, RKMultiUnitRulerDelegate, RKMultiUnitRulerDataSource {
        
        var parent: RKMultiUnitRulerGlucoseView
        
        public var numberOfSegments: Int {
            segments.count
        }
        var segments: [RKSegmentUnit] = []
        
        var rangeStart = Measurement(value: 40, unit: UnitMass.kilograms)
        var rangeLength = Measurement(value: 364, unit: UnitMass.kilograms)
        var textFieldColorOverrides: [RKRange<Float>: UIColor]?
        
        init(parent: RKMultiUnitRulerGlucoseView, textFieldColorOverrides: [RKRange<Float>: UIColor]?) {
            self.parent = parent
            self.textFieldColorOverrides = textFieldColorOverrides
            super.init()
            segments = createSegments()
        }
        
        public func valueChanged(measurement: Measurement<Unit>) {
            let currentValue = measurement.value
            parent.valueUpdated?(currentValue)
            print(currentValue)
        }
        
        public func unitForSegment(at index: Int) -> RKSegmentUnit {
            segments[index]
        }
        
        public func rangeForUnit(_ unit: Dimension) -> RKRange<Float> {
            let locationConverted = rangeStart.converted(to: unit as! UnitMass)
            let lengthConverted = rangeLength.converted(to: unit as! UnitMass)
            return RKRange<Float>(
                location: ceilf(Float(locationConverted.value)),
                length: ceilf(Float(lengthConverted.value))
            )
        }
        
        public func styleForUnit(_ unit: Dimension) -> RKSegmentUnitControlStyle {
            let style = RKSegmentUnitControlStyle()
            style.textOfUnit = "mg/dL"
            style.textFieldColorOverrides = textFieldColorOverrides ?? [
                RKRange<Float>(location: 0, length: 69): #colorLiteral(red: 0.8117647059, green: 0, blue: 0.2470588235, alpha: 1),
                RKRange<Float>(location: 70, length: 180): #colorLiteral(red: 0.1490196078, green: 0.8470588235, blue: 0.4980392157, alpha: 1),
                RKRange<Float>(location: 181, length: 220): #colorLiteral(red: 1, green: 0.5490196078, blue: 0.2039215686, alpha: 1),
                RKRange<Float>(location: 221, length: 400): #colorLiteral(red: 0.8117647059, green: 0, blue: 0.2470588235, alpha: 1),
            ]
            return style
        }
        
        private func createSegments() -> [RKSegmentUnit] {
            let formatter = MeasurementFormatter()
            formatter.unitStyle = .short
            let numberFormatter = NumberFormatter()
            numberFormatter.maximumFractionDigits = 0
            formatter.numberFormatter = numberFormatter
            formatter.unitOptions = .providedUnit
            formatter.locale = Locale(identifier: "en_US")
            let kgSegment = RKSegmentUnit(name: "", unit: UnitMass.kilograms, formatter: formatter)
            
            kgSegment.name = ""
            kgSegment.unit = UnitMass.kilograms
            
            let kgMarkerTypeMax = RKRangeMarkerType(color: #colorLiteral(red: 0.737254902, green: 0.737254902, blue: 0.737254902, alpha: 1), size: CGSize(width: 2.0, height: 50.0), scale: 10)
            kgMarkerTypeMax.labelVisible = true
            
            let kgMarkerTypeMax2 = RKRangeMarkerType(color: #colorLiteral(red: 0.737254902, green: 0.737254902, blue: 0.737254902, alpha: 1), size: CGSize(width: 1.5, height: 45.0), scale: 5)
            kgMarkerTypeMax2.labelVisible = false
            
            kgSegment.markerTypes = [
                RKRangeMarkerType(color: #colorLiteral(red: 0.737254902, green: 0.737254902, blue: 0.737254902, alpha: 1), size: CGSize(width: 1.0, height: 35.0), scale: 1)
            ]
            kgSegment.markerTypes.append(kgMarkerTypeMax2)
            kgSegment.markerTypes.append(kgMarkerTypeMax)
            
            kgSegment.markerTypes.last?.labelVisible = false
            
            return [kgSegment]
        }
    }
}
