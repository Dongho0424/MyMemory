//
//  MemoListVC.swift
//  MyMemory
//
//  Created by 최동호 on 2021/03/08.
//

import UIKit

class MemoListVC: UITableViewController {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.appDelegate.memoList.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // 1. 셀에 해당하는 데이터 꺼내고
        let row = self.appDelegate.memoList[indexPath.row]
        
        // 2. 이미지 속성에 맞게 identifier 정하고
        let identifier = row.image == nil ? "memoCell" : "memoCellWithImage"
        
        // 3. reuse queue에서 알맞은거 꺼내고
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? MemoCell
        
        
        // 4. 셀 채우고
        cell?.subject?.text = row.title
        cell?.contents?.text = row.contents
        cell?.img?.image = row.image
        
        // 5. 날짜 포매팅
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        cell?.regdate?.text = dateFormatter.string(from: row.regdate!)
        
        // 6. 리턴
        return cell ?? MemoCell()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // 1. 셀에 해당하는 데이터
        let row = self.appDelegate.memoList[indexPath.row]
        
        // 2. 이동할 화면의 인스턴스
        guard let vc = self.storyboard?.instantiateViewController(identifier: "MemoRead") as? MemoReadVC else {
            return
        }
        
        // 3. 값을 전달할 다음, 상세
        vc.param = row
        
        // 네비게이션 컨트롤러로 이동
        self.navigationController?.pushViewController(vc, animated: true)
        
        // 매뉴얼 세그웨이로 이동
//        self.performSegue(withIdentifier: "read_sg", sender: self)
        
    }
}
