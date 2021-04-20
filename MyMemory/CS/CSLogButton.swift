//
//  CSLogButton.swift
//  MyMemory
//
//  Created by 최동호 on 2021/03/15.
//

import UIKit

public enum CSLogType: Int{
    case basic
    case title
    case tag
}

public class CSLogButton: UIButton {
    
    public var logType: CSLogType = .basic

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        self.setBackgroundImage(UIImage(named: "button-bg"), for: .normal)
        self.tintColor = .white
        
        self.addTarget(self, action: #selector(logging(_:)), for: .touchUpInside)
    }
    
    @objc func logging(_ sender: UIButton){
        switch self.logType {
        case .basic:
            print("button is now clicked")
        case .title:
            let btnTitle = sender.titleLabel?.text ?? "no title"
            print("button is now clicked")
            print("title: \(btnTitle)")
        case .tag:
            print("button is now clicked")
            print("tag: \(sender.tag)")
        }
    }
}
