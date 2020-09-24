
//
//  TextViwe.swift
//  OfficeManger
//
//  Created by yaojinhai on 2020/9/8.
//  Copyright © 2020 yaojinhai. All rights reserved.
//

import Foundation
import SwiftUI
import UIKit




struct TextView: UIViewRepresentable {
    
    
    let defalutText: String
    @Binding var valueText: String
    @Binding var isCanEdit: Bool
    
    @Binding var finishedBlock: (() -> Void)?
    
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        
        textView.delegate = context.coordinator
        textView.textContainerInset = .init(top: 10, left: 10, bottom: 10, right: 10)
        textView.font = .systemFont(ofSize: 16)
        textView.text = defalutText
        textView.keyboardDismissMode = .onDrag
        return textView
        
    }
    func updateUIView(_ uiView:  UITextView, context: Context) {

        
    }
    func makeCoordinator() -> Coordinator {
        Coordinator(textView: self)
    }
    
    class Coordinator: NSObject,UITextViewDelegate {
        let parentView: TextView
        init(textView: TextView) {
            parentView = textView
        }
        func textViewDidEndEditing(_ textView: UITextView) {
            DispatchQueue.main.async {
                self.parentView.valueText = (textView.text ?? "")
                self.parentView.finishedBlock?();
            }
        }
        func textViewDidChange(_ textView: UITextView) {
            DispatchQueue.main.async {
                self.parentView.valueText = textView.text ?? ""
            }
        }
    }
    
    
}

struct SigleTextField: UIViewRepresentable {
    
    let placeholder: String
    @Binding var valueText: String
    @Binding var finished: (() -> Void)?
    
    func makeCoordinator() -> Coordinator {
        Coordinator(textView: self)
    }
    
    
    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.text = valueText;
        textField.placeholder = placeholder
        textField.delegate = context.coordinator
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.returnKeyType = .done
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.clearButtonMode = .always
        textField.clearsOnBeginEditing = true;
        return textField
    }
    
    func updateUIView(_ uiView: UITextField, context: Context) {
        DispatchQueue.main.async {
            self.valueText = uiView.text ?? ""
        }
        
    }
    
    class Coordinator: NSObject,UITextFieldDelegate {
        let parentView: SigleTextField
        init(textView: SigleTextField) {
            parentView = textView
        }
        func textFieldDidEndEditing(_ textField: UITextField) {
            parentView.valueText = textField.text ?? ""
            parentView.finished?()
        }
        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            var allText = (textField.text ?? "") + string;
            if string == "" {
                if !allText.isEmpty {
                    allText.removeLast()
                }
            }
            parentView.valueText = allText
            return true
        }
        
        func textFieldShouldClear(_ textField: UITextField) -> Bool {
            parentView.valueText = ""
            return true
        }
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            parentView.valueText = textField.text ?? ""
            parentView.finished?()
            textField.endEditing(true)
            return true;
        }
    }
}
