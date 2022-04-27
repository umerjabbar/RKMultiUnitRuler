//
// Created by Farshid Ghods on 12/28/16.
// Copyright (c) 2016 Rekovery. All rights reserved.
//

import UIKit

/*
 string extension to facilitate conversion of string to double, int and float
 */
public extension String {
    var doubleValue: Double? {
        return NumberFormatter().number(from: self)?.doubleValue
    }
    var integerValue: Int? {
        return NumberFormatter().number(from: self)?.intValue
    }
    var floatValue: Float? {
        return NumberFormatter().number(from: self)?.floatValue
    }
}

class RKRangeTextView: UIControl, UITextFieldDelegate {
    
    var textField: UITextField = UITextField()
    var formatter: MeasurementFormatter?
    var unit: Dimension?
    var flagOfView = false
    var parentView: RKMultiUnitRuler?
    
    func addDoneButtonOnKeyboard()
    {
        let doneToolbar: UIToolbar = UIToolbar(frame:  CGRect(x: 0, y: 0, width: 320, height: 50))
        doneToolbar.barStyle = UIBarStyle.default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: self, action: #selector(self.doneButtonActionClicked))
        
        var items = [UIBarButtonItem]()
        items.append(flexSpace)
        items.append(done)
        
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        self.textField.inputAccessoryView = doneToolbar
        
    }
    @objc func doneButtonActionClicked()
    {
        parentView?.refresh()
        self.textField.endEditing(true)
        self.textField.resignFirstResponder()
    }
    public var currentValue: Float = 0 {
        
        didSet {
            
            if (!self.textField.isFirstResponder) {
                
                self.updateTextFieldText(value: currentValue)
            }
            
        }
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupTextView()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupTextView()
    }
    
    /*
     Internal method used for updating the TextField using the formatter if applicable
     If the textField is the first responder then it will also retain the cursor position
     */
    private func updateTextFieldText(value: Float) {
        
        
        var originalCursorPosition : UITextPosition? = nil
        if (self.textField.isFirstResponder) {
            if let selectedRange = textField.selectedTextRange {
                originalCursorPosition = textField.position(from: selectedRange.start, offset: 1)
            }
        }
        if let formatter = self.formatter, let unit = self.unit {
            let measurement = Measurement(value: Double(value), unit: unit)
            self.textField.text = formatter.string(from: measurement)
        } else {
            self.textField.text = String(format: "%.1f", value)

        }
        if let position = originalCursorPosition {
            self.textField.selectedTextRange = textField.textRange(
                from: position, to: position)
        }
    }
    
    /*
     Creates a new UITextField and assigns the constraint programmatically
     */
    func setupTextView() {
        self.textField.removeFromSuperview()
        let textField = UITextField(frame: self.bounds)
        textField.textAlignment = NSTextAlignment.center
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.isUserInteractionEnabled = true
        textField.text = "0"
        textField.keyboardType = .decimalPad
        textField.delegate = self
        self.addSubview(textField)
        let views = ["textField": textField]
        var constraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-5-[textField]-5-|",
                                                         options: NSLayoutConstraint.FormatOptions.directionLeadingToTrailing,
                                                         metrics: nil,
                                                         views: views)
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|-5-[textField]-5-|",
                                                      options: NSLayoutConstraint.FormatOptions.directionLeadingToTrailing,
                                                      metrics: nil,
                                                      views: views)
        self.addConstraints(constraints)
        self.textField = textField
        addDoneButtonOnKeyboard()
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        return true
    }
    
    /*
     Set the cursor to the beginning of the document
     */
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        textField.selectedTextRange = textField.textRange(from: textField.beginningOfDocument, to: textField.beginningOfDocument)
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
//        parentView?.refresh()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        
    }
    
    internal func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        
    }
    
    /*
     If string is empty or "." then let the user continue updating the text
     If string can be parsed to Float then invoke the updateTextFieldText method to format the text
     else let the user continue modifying the text
     */
    func updateTextValue(value:String){
        self.textField.text = value
        updateTextColor()
    }
    func updateTextColor(){
        if flagOfView {
                           if currentValue > 250 || currentValue < 54
                               
                           {
                               textField.textColor = #colorLiteral(red: 0.8117647059, green: 0, blue: 0.2470588235, alpha: 1)
                               
                           }
                           else if currentValue > 180 && currentValue <= 250
                           {
                               textField.textColor = #colorLiteral(red: 1, green: 0.5490196078, blue: 0.2039215686, alpha: 1)
                               
                           }
                           else if currentValue >= 70 && currentValue <= 180
                           {
                               textField.textColor = #colorLiteral(red: 0.1490196078, green: 0.8470588235, blue: 0.4980392157, alpha: 1)
                               
                           }
                           else if currentValue >= 54 && currentValue < 70
                           {
                               textField.textColor = #colorLiteral(red: 0.8117647059, green: 0, blue: 0.2470588235, alpha: 1)
                               
                           }
                       }
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        
        if let char = string.cString(using: String.Encoding.utf8) {
               let isBackSpace = strcmp(char, "\\b")
               if (isBackSpace == -92) {
                   print("Backspace was pressed")
               }
           }
        let textFieldText = (textField.text ?? "") as NSString?
        let updatedString = textFieldText?.replacingCharacters(in: range, with: string)
        
        
//        if string.isEmpty || string == "." {
//
//            textField.text = updatedString
//                    if let updatedStringAsFloat = updatedString?.floatValue {
//                        currentValue = Float(updatedStringAsFloat)
//            }
//
//         self.updateTextFieldText(value: (updatedString?.floatValue)!)
//                        self.sendActions(for: UIControl.Event.valueChanged)
//
//
//        //                parentView?.refresh()
////                    }
//
//                    return true
//                }
        
        if let unit = self.unit {
            print("updatedString : \(updatedString)")
            if let updatedStringAsFloat = updatedString?.replacingOccurrences(
                of: unit.symbol, with: "").floatValue {
                currentValue = updatedStringAsFloat
                self.updateTextFieldText(value: currentValue)
                
                self.sendActions(for: UIControl.Event.valueChanged)
                return false
            }
            
            return true
        } else {
            if let updatedStringAsFloat = updatedString?.floatValue {
                currentValue = updatedStringAsFloat
                //                if UserDefaultsManager.get(key: AppConstants.RULER_FLAG)
                //                {
                //
                //                }
                if flagOfView {
                    if currentValue > 250 || currentValue < 54
                        
                    {
                        textField.textColor = #colorLiteral(red: 0.8117647059, green: 0, blue: 0.2470588235, alpha: 1)
                        
                    }
                    else if currentValue > 180 && currentValue <= 250
                    {
                        textField.textColor = #colorLiteral(red: 1, green: 0.5490196078, blue: 0.2039215686, alpha: 1)
                        
                    }
                    else if currentValue >= 70 && currentValue <= 180
                    {
                        textField.textColor = #colorLiteral(red: 0.1490196078, green: 0.8470588235, blue: 0.4980392157, alpha: 1)
                        
                    }
                    else if currentValue >= 54 && currentValue < 70
                    {
                        textField.textColor = #colorLiteral(red: 0.8117647059, green: 0, blue: 0.2470588235, alpha: 1)
                        
                    }
                }
                
                
                self.sendActions(for: UIControl.Event.valueChanged)
            }else{
                currentValue = 0
                self.sendActions(for: UIControl.Event.valueChanged)

            }
            return true
        }
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        return true
    }
    
    override func resignFirstResponder() -> Bool {
//        if (self.textField.isFirstResponder) {
//
//            self.textField.resignFirstResponder()
//        }
        return super.becomeFirstResponder()
    }
    
    
}
