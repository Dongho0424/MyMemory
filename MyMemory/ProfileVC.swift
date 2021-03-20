//
//  ProfileVC.swift
//  MyMemory
//
//  Created by 최동호 on 2021/03/16.
//

import Foundation
import UIKit

class ProfileVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    let profileImage = UIImageView()
    let tableView = UITableView()
    let uinfo = UserInfoManager()
    
    override func viewDidLoad() {
        self.navigationItem.title = "Profile"
        
        let backBtn = UIBarButtonItem(title: "close", style: .plain, target: self, action: #selector(close(_:)))
        self.navigationItem.leftBarButtonItem = backBtn
        
        // back ground image setting
        let bgImage = UIImageView(image: UIImage(named: "profile-bg.png"))
        bgImage.frame.size = CGSize(width: bgImage.frame.size.width, height: bgImage.frame.size.height)
        bgImage.center = CGPoint(x: self.view.frame.size.width / 2, y: 40)
        bgImage.layer.cornerRadius = bgImage.frame.width / 2
        bgImage.layer.borderWidth = 0
        bgImage.layer.masksToBounds = true
        self.view.addSubview(bgImage)
        self.view.bringSubviewToFront(profileImage)
        self.view.bringSubviewToFront(tableView)
        
        // profile image initial setting
        // let image = UIImage(named: "account@2x.jpg")
        let image = self.uinfo.profile
        self.profileImage.image = image
        self.profileImage.frame.size = CGSize(width: 100, height: 100)
        self.profileImage.center = CGPoint(x: self.view.frame.width / 2, y: 270)
        self.profileImage.layer.cornerRadius = self.profileImage.frame.width / 2
        self.profileImage.layer.borderWidth = 0
        self.profileImage.layer.masksToBounds = true
        self.view.addSubview(self.profileImage)
        
        // table view initial setting
        self.tableView.frame = CGRect(
            x: 0,
            y: self.profileImage.frame.origin.y + self.profileImage.frame.height + 20,
            width: self.view.frame.width,
            height: 100)
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.view.addSubview(self.tableView)
        
        // initial btn
        self.drawBtn()
        
        // profile image set gesture
        let tap = UITapGestureRecognizer(target: self, action: #selector(profile(_:)))
        self.profileImage.addGestureRecognizer(tap)
        self.profileImage.isUserInteractionEnabled = true
        
    }
    
    @objc func close(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    // login!
    @objc func doLogin(_ sender: Any) {
        let loginAlert = UIAlertController(title: "LOGIN", message: nil, preferredStyle: .alert)
        
        loginAlert.addTextField {
            $0.placeholder = "Your Account"
        }
        loginAlert.addTextField {
            $0.placeholder = "Password"
            $0.isSecureTextEntry = true
        }
        loginAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        loginAlert.addAction(UIAlertAction(title: "Login", style: .destructive){
            (_) in
            let account = loginAlert.textFields?[0].text ?? ""
            let password = loginAlert.textFields?[1].text ?? ""
            
            if self.uinfo.login(account: account, password: password) {
                self.tableView.reloadData()
                self.profileImage.image = self.uinfo.profile
                self.drawBtn()
            } else {
                let msg = "failed login"
                let alert = UIAlertController(title: nil, message: msg, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                self.present(alert, animated: true)
            }
        })
        
        self.present(loginAlert, animated: true, completion: nil)
    }
    
    // logout!
    @objc func doLogout(_ sender: Any){
        let msg = "Do you want logout?"
        let alert = UIAlertController(title: nil, message: msg, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "OK", style: .destructive){
            (_) in
            if self.uinfo.logout() {
                self.tableView.reloadData()
                self.profileImage.image = self.uinfo.profile
                self.drawBtn()
            }
        })
        self.present(alert, animated: true, completion: nil)
    }
    
    // 로그아운 혹은 로그인 버튼
    func drawBtn() {
        let v = UIView()
        v.frame = CGRect(
            x: 0,
            y: self.tableView.frame.origin.y + self.tableView.frame.size.height,
            width: self.view.frame.width,
            height: 40)
        v.backgroundColor = UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1.00)
        self.view.addSubview(v)
        
        let btn = UIButton(type: .system)
        btn.frame.size.width = 100
        btn.frame.size.height = 30
        btn.center.x = v.frame.size.width / 2
        btn.center.y = v.frame.size.height / 2
        if self.uinfo.isLogin {
            btn.setTitle("log out", for: .normal)
            btn.addTarget(self, action: #selector(doLogout(_:)), for: .touchUpInside)
        } else {
            btn.setTitle("log in", for: .normal)
            btn.addTarget(self, action: #selector(doLogin(_:)), for: .touchUpInside)
        }
        v.addSubview(btn)
    }
    
    // MARK: - table view delegate methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "cell")
        cell.textLabel?.font = UIFont.systemFont(ofSize: 14)
        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 13)
        cell.accessoryType = .disclosureIndicator
        
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "name"
            cell.detailTextLabel?.text = self.uinfo.name ?? "Login Please"
        case 1:
            cell.textLabel?.text = "account"
            cell.detailTextLabel?.text = self.uinfo.account ?? "Login Please"
        default:
            ()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !self.uinfo.isLogin {
            self.doLogin(self.tableView)
        }
    }
    // MARK: - image picker controller
    func imgPicker(_ source: UIImagePickerController.SourceType) {
        let picker = UIImagePickerController()
        picker.sourceType = source
        picker.delegate = self
        picker.allowsEditing = true
        self.present(picker, animated: true, completion: nil)
    }
    
    @objc func profile(_ sender: Any){
        guard self.uinfo.isLogin else {
            self.doLogin(self)
            return
        }
        
        let alert = UIAlertController(title: nil, message: "사진을 가져올 곳을 선택해 주세요", preferredStyle: .actionSheet)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            alert.addAction(UIAlertAction(title: "카메라", style: .default){
                (_) in
                self.imgPicker(.camera)
            })
        }
        
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            alert.addAction(UIAlertAction(title: "저장된 앨범", style: .default){
                (_) in
                self.imgPicker(.savedPhotosAlbum)
            })
        }
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            alert.addAction(UIAlertAction(title: "포토 라이브러리", style: .default){
                (_) in
                self.imgPicker(.photoLibrary)
            })
        }
        
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        // 사용자가 이미지 고르면 profile로 설정
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            self.profileImage.image = image
            self.uinfo.profile = image
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
}
