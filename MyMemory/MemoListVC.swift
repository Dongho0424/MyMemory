//
//  MemoListVC.swift
//  MyMemory
//
//  Created by 최동호 on 2021/03/08.
//

import UIKit

class MemoListVC: UITableViewController, UISearchBarDelegate {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    // dao instance
    lazy var dao = MemoDAO()
    
    // search bar 
    @IBOutlet weak var searchBar: UISearchBar!
    
    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let revealVC = self.revealViewController() {
            
            let btn = UIBarButtonItem()
            btn.image = UIImage(named: "sidemenu")
            btn.target = revealVC
            btn.action = #selector(revealVC.revealToggle(_:))
            
            self.navigationItem.leftBarButtonItem = btn
            
            self.view.addGestureRecognizer(revealVC.panGestureRecognizer())
        }
        
        // searchBar delegate
        self.searchBar.delegate = self
        
        // searchBar에 done 버튼 만들어서 키보드 내려가기
        self.addHideKeyboardBtn(textField: self.searchBar)
        
//        self.searchBar.setImage(<#T##iconImage: UIImage?##UIImage?#>, for: <#T##UISearchBar.Icon#>, state: <#T##UIControl.State#>)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        let ud = UserDefaults.standard
        if ud.bool(forKey: UserInfoKey.tutorial) == false {
            let vc = self.instanceTutorialVC(name: "MasterVC")
            vc?.modalPresentationStyle = .fullScreen
            self.present(vc!, animated: true)
            return
        }
        
        // core data에서 저장된 데이터 가져오기
        self.appDelegate.memoList = self.dao.fetch()
        
        self.tableView.reloadData()
    }
    
    // MARK: - Actions
    
    @objc func dismissKeyboard(_ sender: Any){
        self.searchBar.endEditing(true)
    }
    
    func addHideKeyboardBtn(textField: UISearchBar){
        let viewForHideKeyboard = UIToolbar()
        viewForHideKeyboard.sizeToFit()
        let hideKeyboardBtn = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissKeyboard(_:)))
        let flexibleBtn = UIBarButtonItem(systemItem: .flexibleSpace)
        viewForHideKeyboard.items = [flexibleBtn, hideKeyboardBtn]
        
        self.searchBar.inputAccessoryView = viewForHideKeyboard
    }

    // MARK: - TableView Data Source

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
    
    // MARK: - TableView Delegate
    
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
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let data = self.appDelegate.memoList[indexPath.row]
        
        if dao.delete(data.objectId!) {
            self.appDelegate.memoList.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    // MARK: - SearchBar Delegate
    
    // when searchButton is clicked
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let keyword = searchBar.text
        
        self.appDelegate.memoList = self.dao.fetch(keyword: keyword)
        self.tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let keyword = searchBar.text
        
        self.appDelegate.memoList = self.dao.fetch(keyword: keyword)
        self.tableView.reloadData()
    }
    
//    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
//        // hide keyboard when tap outside
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard(_:)))
//
//        self.view.addGestureRecognizer(tapGesture)
//    }
//
//    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
//        self.view.gestureRecognizers?.removeAll()
//    }

}
/*
 request : 현재 학생이 공부하는 파트(출제 영역)에 대한 학생의 공부 중요도 높은 카테고리 m개와 특정 태그 n개에 해당하는 문제
 response : 문제 pk, 문제 이미지, 단답 or ㄱㄴㄷ flag
 */
