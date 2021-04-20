//
//  ProfileVC.swift
//  MyMemory
//
//  Created by 최동호 on 2021/03/16.
//

import Foundation
import UIKit
import Alamofire
import LocalAuthentication

class ProfileVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    let profileImage = UIImageView()
    let tableView = UITableView()
    let uinfo = UserInfoManager()
    
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    
    var isCalling = false

    // MARK: - View Life Cycle

    override func viewDidLoad() {
        navigationItem.title = "Profile"

        let backBtn = UIBarButtonItem(title: "close", style: .plain, target: self, action: #selector(close(_:)))
        navigationItem.leftBarButtonItem = backBtn

        // back ground image setting
        let bgImage = UIImageView(image: UIImage(named: "profile-bg.png"))
        bgImage.frame.size = CGSize(width: bgImage.frame.size.width, height: bgImage.frame.size.height)
        bgImage.center = CGPoint(x: view.frame.size.width / 2, y: 40)
        bgImage.layer.cornerRadius = bgImage.frame.width / 2
        bgImage.layer.borderWidth = 0
        bgImage.layer.masksToBounds = true
        view.addSubview(bgImage)
        view.bringSubviewToFront(profileImage)
        view.bringSubviewToFront(tableView)

        // profile image initial setting
        // let image = UIImage(named: "account@2x.jpg")
        let image = uinfo.profile
        profileImage.image = image
        profileImage.frame.size = CGSize(width: 100, height: 100)
        profileImage.center = CGPoint(x: view.frame.width / 2, y: 270)
        profileImage.layer.cornerRadius = profileImage.frame.width / 2
        profileImage.layer.borderWidth = 0
        profileImage.layer.masksToBounds = true
        view.addSubview(profileImage)

        // table view initial setting
        tableView.frame = CGRect(
            x: 0,
            y: profileImage.frame.origin.y + profileImage.frame.height + 20,
            width: view.frame.width,
            height: 100)
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)

        // initial btn
        drawBtn()

        // profile image set gesture
        let tap = UITapGestureRecognizer(target: self, action: #selector(profile(_:)))
        profileImage.addGestureRecognizer(tap)
        profileImage.isUserInteractionEnabled = true
        
        // bring indicator view to front of view
        self.view.bringSubviewToFront(self.indicatorView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tokenValidate()
        
        // print access token
        let token = Token()
        let uinfo = UserInfoManager()
        if
            uinfo.isLogin == true,
            let accessTk = token.load(TokenInfo.serviceId, account: TokenInfo.accessToken)
        {
            print(accessTk)
        }
    }

    // MARK: - Actions

    @objc func close(_ sender: Any) {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }

    // login!
    @objc func doLogin(_ sender: Any) {
        
        if isCalling == false {
            isCalling = true
        } else {
            self.alert(title: nil, message: "응답을 기다리는 중입니다. \n잠시만 기다려주세요.")
            return
        }
        
        let loginAlert = UIAlertController(title: "LOGIN", message: nil, preferredStyle: .alert)

        loginAlert.addTextField {
            $0.placeholder = "Your Account"
        }
        loginAlert.addTextField {
            $0.placeholder = "Password"
            $0.isSecureTextEntry = true
        }
        loginAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel){ _ in
            self.isCalling = false
        })
        loginAlert.addAction(UIAlertAction(title: "Login", style: .destructive) {
            _ in
            
            // indicator start in any case which tap login button
            self.indicatorView.startAnimating()
            
            let account = loginAlert.textFields?[0].text ?? ""
            let password = loginAlert.textFields?[1].text ?? ""
            
            self.uinfo.login(account: account, password: password, success: {
                self.tableView.reloadData()
                self.profileImage.image = self.uinfo.profile
                self.drawBtn()
                
                // stop indicator
                self.indicatorView.stopAnimating()
                self.isCalling = false
                
                // 서버와 데이터 동기화
                let sync = DataSync()
                DispatchQueue.global(qos: .background).async {
                    sync.downloadBackupData()
                }
                DispatchQueue.global(qos: .background).async {
                    sync.uploadData()
                }
            }, fail: {
                msg in
                
                // stop indicator
                self.indicatorView.stopAnimating()
                self.alert(title: "login error", message: msg)
                self.isCalling = false
            })
            
        })

        self.present(loginAlert, animated: true, completion: nil)
    }

    // logout!
    @objc func doLogout(_ sender: Any) {
        
        let msg = "Do you want logout?"
        let alert = UIAlertController(title: nil, message: msg, preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "OK", style: .destructive) { _ in
            
            self.indicatorView.startAnimating()
            
            self.uinfo.logout() {
                self.indicatorView.stopAnimating()
                
                self.tableView.reloadData()
                self.profileImage.image = self.uinfo.profile
                self.drawBtn()
            }
        })
        self.present(alert, animated: true, completion: nil)
    }

    // logout 혹은 로그인 버튼
    func drawBtn() {
        let v = UIView()
        v.frame = CGRect(
            x: 0,
            y: tableView.frame.origin.y + tableView.frame.size.height,
            width: view.frame.width,
            height: 40)
        v.backgroundColor = UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1.00)
        view.addSubview(v)

        let btn = UIButton(type: .system)
        btn.frame.size.width = 100
        btn.frame.size.height = 30
        btn.center.x = v.frame.size.width / 2
        btn.center.y = v.frame.size.height / 2
        if uinfo.isLogin {
            btn.setTitle("log out", for: .normal)
            btn.addTarget(self, action: #selector(doLogout(_:)), for: .touchUpInside)
        } else {
            btn.setTitle("log in", for: .normal)
            btn.addTarget(self, action: #selector(doLogin(_:)), for: .touchUpInside)
        }
        v.addSubview(btn)
    }
    
    // unwind segue
    // using when sign in is finished
    @IBAction func backProfileVC(_ segue: UIStoryboardSegue){}

    // MARK: - TableView Data Source

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
            cell.detailTextLabel?.text = uinfo.name ?? "Login Please"
        case 1:
            cell.textLabel?.text = "account"
            cell.detailTextLabel?.text = uinfo.account ?? "Login Please"
        default:
            ()
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !uinfo.isLogin {
            doLogin(self.tableView)
        }
    }

    // MARK: - ImagePicker Actions

    func imgPicker(_ source: UIImagePickerController.SourceType) {
        if UIImagePickerController.isSourceTypeAvailable(source) {
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.allowsEditing = true

            present(picker, animated: true, completion: nil)
        } else {
            alert(title: nil, message: "사용할 수 없는 타입입니다.")
        }
    }

    @objc func profile(_ sender: Any) {
        guard uinfo.isLogin else {
            doLogin(self)
            return
        }

        let alert = UIAlertController(title: nil, message: "사진을 가져올 곳을 선택해 주세요", preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "카메라", style: .default) {
            _ in
            self.imgPicker(.camera)
        })

        alert.addAction(UIAlertAction(title: "저장된 앨범", style: .default) {
            _ in
            self.imgPicker(.savedPhotosAlbum)
        })

        alert.addAction(UIAlertAction(title: "포토 라이브러리", style: .default) {
            _ in
            self.imgPicker(.photoLibrary)
        })

        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))

        present(alert, animated: true, completion: nil)
    }

    // MARK: - ImagePicker Delegate

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        
        // indicator start
        self.indicatorView.startAnimating()
        
        if let img = info[.editedImage] as? UIImage {
            
            // *** //
//            let token = Token()
//            let header = token.authorizationHeader
//            print(header)
//
//            print(img.pngData()?.base64EncodedString())
            
            self.uinfo.newProfile(img, success: {
                // indicator stop
                self.indicatorView.stopAnimating()
                self.profileImage.image = img
            }, fail: {
                msg in
                self.indicatorView.stopAnimating()
                self.alert(title: nil, message: msg)
            })
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
}
// MARK: - Token Refresh
extension ProfileVC {
    
    // check whether access token is validate or not
    func tokenValidate() {
        // 0. 응답 캐시 삭제
        URLCache.shared.removeAllCachedResponses()
        
        // 1. key chain 에 access token이 없으면 애초에 검증할 필요 없음
        let token = Token()
        guard let header = token.authorizationHeader else {
            return
        }
        
        print("header: \(header)")
        
        self.indicatorView.startAnimating()
        
        // 2. call token validate API
        let url = "http://swiftapi.rubypaper.co.kr:2029/userAccount/tokenValidate"
        let validate = AF.request(url, method: .post, encoding: JSONEncoding.default, headers: header)
        
        // 3. response
        validate.responseJSON { res in
            
            self.indicatorView.stopAnimating()
            
            let responseBody = try! res.result.get()
            print(responseBody)
            
            guard let jsonObject = responseBody as? NSDictionary else {
                self.alert(title: "token validate 오류", message: "에러")
                return
            }
            
            let resultCode = jsonObject["result_code"] as! Int
            if resultCode != 0 { // token is expired
                // local authentification
                self.bioID()
            }
        }
    }
    
    // use bio ID
    func bioID(){
        // 1. LAContext
        let context = LAContext()
        
        // 2. variables used in LA
        var error: NSError?
        let msg = "인증이 필요합니다."
        let deviceAuth = LAPolicy.deviceOwnerAuthenticationWithBiometrics
        
        // 3. check whether local authentication is available or not
        if context.canEvaluatePolicy(deviceAuth, error: &error) {
            // 4. bio ID alert
            context.evaluatePolicy(deviceAuth, localizedReason: msg) { (success, error) in
                if success { // 5. bio 인증 성공: refresh token
                    self.refresh()
                } else { // 6. bio 인증 실패
                    // bio 인증 실패에 대한 케이스들
                    print((error?.localizedDescription)!)
                    
                    switch error!._code {
                    case LAError.systemCancel.rawValue:
                        self.alert(title: "bio error", message: "시스템에 의해 인증이 취소되었습니다.")
                    case LAError.userCancel.rawValue:
                        self.alert(title: "bio error", message: "유저에 의해 인증이 취소되었습니다.") {
                            self.commonLogout(true)
                        }
                    case LAError.userFallback.rawValue:
                        OperationQueue.main.addOperation {
                            self.commonLogout(true)
                        }
                    default:
                        OperationQueue.main.addOperation {
                            self.commonLogout(true)
                        }
                    }
                }
            }
        } else { // 7. LA is not available
            // LA 실패에 대한 케이스들
            print((error?.localizedDescription)!)
            
            switch error!._code {
            case LAError.biometryNotEnrolled.rawValue:
                self.alert(title: "bio not available error", message: "터치 아이디가 등록되어 있지 않습니다."){
                    self.commonLogout(true)
                }
            case LAError.passcodeNotSet.rawValue:
                self.alert(title: "bio not available error", message: "패스 코드가 설정되어 있지 않습니다.")
                {
                    self.commonLogout(true)
                }
            default:
                self.alert(title: "bio not available error", message: "바이오 인증을 사용할 수 없습니다.")
                {
                    self.commonLogout(true)
                }
            }
        }
    }
    
    // refresh access token using refresh token
    func refresh(){
        DispatchQueue.main.async {
            self.indicatorView.startAnimating()
        }
        
        // 1. 인증 헤더
        let token = Token()
        let header = token.authorizationHeader
        
        // 2. refresh token 전달 준비 to refresh access token
        let refreshToken = token.load(TokenInfo.serviceId, account: TokenInfo.refreshToken)
        let param: Parameters = ["refresh_token" : refreshToken!]
        
        // 3. req, res
        let url = "http://swiftapi.rubypaper.co.kr:2029/userAccount/refresh"
        let refresh = AF.request(url, method: .post, parameters: param, headers: header)
        
        refresh.responseJSON { res in
            
            DispatchQueue.main.async {
                self.indicatorView.stopAnimating()
            }
            
            guard
                let responseBody = try? res.result.get(),
                let jsonObject = responseBody as? NSDictionary
            else {
                self.alert(title: "token refresh 오류", message: "에러")
                return
            }
            
            let resultCode = jsonObject["result_code"] as! Int
            if resultCode == 0 { // success: access token updates
                let accessToken = jsonObject["access_token"] as! String
                token.save(TokenInfo.serviceId, account: TokenInfo.accessToken, value: accessToken)
            } else { // fail: Refresh token is also expired. Re-login is needed.
                self.alert(title: nil, message: "다시 로그인 해주세요"){
                    // logout
                    OperationQueue.main.addOperation {
                        self.commonLogout(true)
                    }
                }
            }
        } // end of responseJSON closure
    } // end of func refresh()
    
    // method to device logout, reload table and show login alert by isLogin param
    func commonLogout(_ isLogin: Bool = false) {
        // 1. device logout
        // delete user info to user default and delete token to key chain
        let uinfo = UserInfoManager()
        uinfo.deviceLogout()
        
        // 2.
        self.tableView.reloadData()
        self.profileImage.image = uinfo.profile
        self.drawBtn()
        
        // 3. login alert
        if isLogin {
            self.doLogin(self)
        }
    }
}
