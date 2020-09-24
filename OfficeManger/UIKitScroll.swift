//
//  UIKitScroll.swift
//  OfficeManger
//
//  Created by yaojinhai on 2020/9/4.
//  Copyright © 2020 yaojinhai. All rights reserved.
//

import UIKit

class UIKitScrollView: UIScrollView {
    
    override init(frame: CGRect) {
        super.init(frame: frame);
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        isPagingEnabled = true;
    }
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
