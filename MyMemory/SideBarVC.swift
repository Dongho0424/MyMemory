//
//  SideBarVC.swift
//  MyMemory
//
//  Created by 최동호 on 2021/03/16.
//

import UIKit

class SideBarVC: UITableViewController {
    
    let titles = ["새글 작성하기", "친구 새글", "달력으로 보기", "공지사항", "통계", "계정 관리"]
    
    let icons = [
        UIImage(named: "icon01"),
        UIImage(named: "icon02"),
        UIImage(named: "icon03"),
        UIImage(named: "icon04"),
        UIImage(named: "icon05"),
        UIImage(named: "icon06")
    ]
    
    let nameLabel = UILabel()
    let emailLabel = UILabel()
    let profileImage = UIImageView()
    
    let uinfo = UserInfoManager()

    override func viewDidLoad() {
        super.viewDidLoad()

        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 70))
        
        headerView.backgroundColor = .brown
        
        self.tableView.tableHeaderView = headerView
        
        self.nameLabel.frame = CGRect(x: 70, y: 15, width: 100, height: 30)
        self.nameLabel.textColor = .white
        self.nameLabel.font = UIFont.boldSystemFont(ofSize: 15)
        self.nameLabel.backgroundColor = .clear
        headerView.addSubview(self.nameLabel)
        
        self.emailLabel.frame = CGRect(x: 70, y: 30, width: 130, height: 30)
        self.emailLabel.textColor = .white
        self.emailLabel.font = UIFont.systemFont(ofSize: 11)
        self.emailLabel.backgroundColor = .clear
        headerView.addSubview(self.emailLabel)
        
        self.profileImage.frame = CGRect(x: 10, y: 10, width: 50, height: 50)
        headerView.addSubview(self.profileImage)
        
        // layer은 CALayer.
        // 모든 뷰는 layer을 가짐
        self.profileImage.layer.cornerRadius = (self.profileImage.layer.frame.width / 2)
        self.profileImage.layer.masksToBounds = true // clipping mask 효과
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.nameLabel.text = self.uinfo.name ?? "Guest"
        self.emailLabel.text = self.uinfo.account ?? ""
        self.profileImage.image = self.uinfo.profile
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.titles.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let id = "menucell"
        let cell = tableView.dequeueReusableCell(withIdentifier: id) ?? UITableViewCell(style: .default, reuseIdentifier: id)
        
        cell.textLabel?.text = self.titles[indexPath.row]
        cell.imageView?.image = self.icons[indexPath.row]
        cell.textLabel?.font = UIFont.systemFont(ofSize: 14)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            
            let memoFormVC = self.storyboard?.instantiateViewController(identifier: "MemoForm")
            
            let frontVC = self.revealViewController()?.frontViewController as! UINavigationController
            
            frontVC.pushViewController(memoFormVC!, animated: false)
            
            self.revealViewController()?.revealToggle(self)
        } else if indexPath.row == 5 {
            let _profileVC = self.storyboard?.instantiateViewController(identifier: "_Profile")
            _profileVC?.modalPresentationStyle = .fullScreen
            self.present(_profileVC!, animated: true) {
                self.revealViewController()?.revealToggle(self)
            }
        }
    }

}
