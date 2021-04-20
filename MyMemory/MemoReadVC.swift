//
//  MemoReadVC.swift
//  MyMemory
//
//  Created by 최동호 on 2021/03/08.
//

import UIKit

class MemoReadVC: UIViewController {
    
    var param: MemoData?
    
    @IBOutlet weak var subject: UILabel!
    @IBOutlet weak var contents: UILabel!
    @IBOutlet weak var img: UIImageView!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.subject.text = param?.title
        self.contents.text = param?.contents
        self.img.image = param?.image
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd일 HH:mm분에 작성됨"
        let dateString = dateFormatter.string(from: (param?.regdate)!)
        
        self.navigationItem.title = dateString
    }
}
