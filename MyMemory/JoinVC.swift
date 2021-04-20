//
//  JoinVC.swift
//  MyMemory
//
//  Created by 최동호 on 2021/04/08.
//

import UIKit
import Alamofire

class JoinVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var profile: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    
    // managing API call status
    // to prevent overlapping call API
    var isAPICalling = false
    
    var fieldAccount: UITextField!
    var fieldPassword: UITextField!
    var fieldName: UITextField!
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        // make profile image circle
        self.profile.layer.cornerRadius = self.profile.frame.width / 2
        self.profile.clipsToBounds = true
        
        // 프로필 이미지에 제스처 설정 및 액션
        let touchGesture = UITapGestureRecognizer(target: self, action: #selector(tappedProfile(_:)))
        self.profile.addGestureRecognizer(touchGesture)
        
        // 인디케이터 뷰 맨 앞으로
        self.view.bringSubviewToFront(self.indicatorView)
    }
    
    
    // MARK: - API Actions
    
    @IBAction func submit(_ sender: Any) {
        // prevent overlapping call API
        if self.isAPICalling == false {
            self.isAPICalling = true
        } else {
            self.alert(title: nil, message: "loading...")
            return
        }
        
        // indicator view start animating
        self.indicatorView.startAnimating()
        
        // 1. request용 param 정의
        let joinReq = JoinReq(
            account: self.fieldAccount.text!,
            passwd: self.fieldPassword.text!,
            name: self.fieldName.text!,
            profileImage: (self.profile.image?.pngData()?.base64EncodedString())!
        )
        
        // 2. API 호출
        let url = "http://swiftapi.rubypaper.co.kr:2029/userAccount/join"
        let call = AF.request(url, method: .post, parameters: joinReq, encoder: JSONParameterEncoder.default)
        
        // 3. response 처리
        call.responseDecodable(of: JoinRes.self) {
            res in
            
            // indicatorView stop animating
            self.indicatorView.stopAnimating()
            
            switch res.result {
            // decoding 성공
            case .success(let result):
                let resultCode = result.resultCode
                if resultCode == 0 {
                    self.alert(title: nil, message: "가입이 완료되었습니다."){
                        // back to LoginVC
                        self.performSegue(withIdentifier: "backProfileVC", sender: self)
                    }
                } else {
                    // 오류이므로 재 가입 해야됨
                    self.isAPICalling = false
                    
                    let errorMsg = result.errorMsg
                    self.alert(title: "오류발생", message: "오류 내용: \(errorMsg)")
                }
            // decoding 실패
            case .failure(let err):
                // err 내용 출력
                print(err)
                self.alert(title: "오류발생", message: "decode error")
                // 오류이므로 재 가입 해야됨
                self.isAPICalling = false
                return
            }
        }
        
    }
    
    // MARK: - TableView Data Source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "cell")!
        let frame = CGRect(x: 20, y: 0, width: cell.bounds.width - 20, height: 37)
        
        switch indexPath.row {
        case 0:
            self.fieldAccount = UITextField(frame: frame)
            self.fieldAccount.placeholder = "계정(이메일)"
            self.fieldAccount.borderStyle = .none
            self.fieldAccount.autocapitalizationType = .none
            self.fieldAccount.font = UIFont.systemFont(ofSize: 14)
            cell.addSubview(self.fieldAccount)
        case 1:
            self.fieldPassword = UITextField(frame: frame)
            self.fieldPassword.placeholder = "비밀번호"
            self.fieldPassword.borderStyle = .none
            self.fieldPassword.isSecureTextEntry = true
            self.fieldPassword.font = UIFont.systemFont(ofSize: 14)
            cell.addSubview(self.fieldPassword)
        case 2:
            self.fieldName = UITextField(frame: frame)
            self.fieldName.placeholder = "이름"
            self.fieldName.borderStyle = .none
            self.fieldName.font = UIFont.systemFont(ofSize: 14)
            cell.addSubview(self.fieldName)
        default:
            ()
        }
        
        return cell
    }
    
    // MARK: - TableView Delegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    // MARK: - ImagePicker Actions
    
    @objc func tappedProfile(_ sender: Any) {
        let msg = "프로필 이미지를 읽어올 곳을 선택해주세요"
        let actionSheet = UIAlertController(title: nil, message: msg, preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        actionSheet.addAction(UIAlertAction(title: "카메라", style: .default){
            (_) in
            imgPicker(source: .camera)
        })
        actionSheet.addAction(UIAlertAction(title: "저장앨범", style: .default, handler: {
            (_) in
            imgPicker(source: .savedPhotosAlbum)
        }))
        actionSheet.addAction(UIAlertAction(title: "사진 라이브러리", style: .default, handler: {
            (_) in
            imgPicker(source: .photoLibrary)
        }))
        self.present(actionSheet, animated: true, completion: nil)
        
        func imgPicker(source: UIImagePickerController.SourceType){
            if UIImagePickerController.isSourceTypeAvailable(source){
                let picker = UIImagePickerController()
                picker.delegate = self
                picker.allowsEditing = true
                
                self.present(picker, animated: true, completion: nil)
            } else {
                self.alert(title: nil, message: "사용할 수 없는 타입입니다.")
            }
        }
    }
    
    // MARK: - ImagePicker Delegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.editedImage] as? UIImage {
//            print("edited image is available: imagePickerController. JoinVC")아니
            self.profile.image = image
        }
        self.dismiss(animated: true, completion: nil)
    }
}
