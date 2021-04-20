//
//  Utils.swift
//  MyMemory
//
//  Created by 최동호 on 2021/03/20.
//

import Foundation
import UIKit

// 튜토리얼 페이지 관련
extension UIViewController {
    var tutorialSB: UIStoryboard {
        return UIStoryboard(name: "Tutorial", bundle: Bundle.main)
    }
    
    func instanceTutorialVC(name: String) -> UIViewController? {
        return self.tutorialSB.instantiateViewController(withIdentifier: name)
    }
}

// 알림창 관련
extension UIViewController {
    func alert(title: String?, message: String, completion: (() -> Void)? = nil) {
        // ui 관련은 전부 메인 스레드에서
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .cancel){
                (_) in
                completion?()
            }
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
}

