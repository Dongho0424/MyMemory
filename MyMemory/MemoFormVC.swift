//
//  MemoFormVC.swift
//  MyMemory
//
//  Created by 최동호 on 2021/03/08.
//

import UIKit

class MemoFormVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate {
    var subject: String!
    
    @IBOutlet weak var contents: UITextView!
    @IBOutlet weak var preview: UIImageView!
    
    @IBAction func save(_ sender: Any) {
        
        // 1. 내용 입력하지 않았을 경우, 경고한다.
        guard !self.contents.text.isEmpty else {
            let alert = UIAlertController(title: nil, message: "내용을 입력해주세요", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
            return
        }
        // 2. MemoData 객체를 생성하고, 데이터를 담는다.
        let data = MemoData()
        data.contents = self.contents.text
        data.image = self.preview.image
        let date = Date()
        data.regdate = date
        data.title = self.subject
        print(Date())
        
        // 3. 앱 델리게이트 객체 가져와서 저장
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.memoList.append(data)
        
        // 4. 이전 화면
        _ = self.navigationController?.popViewController(animated: true)
        
    }
    
    @IBAction func pick(_ sender: Any) {
        // imagePickerController 인스턴스 생성
        let picker = UIImagePickerController()
        picker.allowsEditing = true // image edit: OK
        
        // delegate
        picker.delegate = self
        
        // source type 정하기
        let alert = UIAlertController(title: nil, message: "이미지를 가져올 곳을 선택해주세요", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "카메라", style: .default, handler: {
                (_) in
                picker.sourceType = .camera
            // imagePickerController 실행
            self.present(picker, animated: true)
        }))
        alert.addAction(UIAlertAction(title: "저장앨범", style: .default, handler: {
            (_) in
            picker.sourceType = .savedPhotosAlbum
        // imagePickerController 실행
        self.present(picker, animated: true)
    }))
        alert.addAction(UIAlertAction(title: "사진 라이브러리", style: .default, handler: {
            (_) in
            picker.sourceType = .photoLibrary
        // imagePickerController 실행
        self.present(picker, animated: true)
    }))

        self.present(alert, animated: true)
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        self.contents.delegate = self
    }
    
    // 사용자가 이미지를 선택하면 자동으로 호출되는 메소드
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        self.preview.image = info[.editedImage] as? UIImage
        
        picker.dismiss(animated: true)
    }
    
    // 사용자가 뭐라도 입력하면 자동 호출~
    func textViewDidChange(_ textView: UITextView) {
        
        let contents = textView.text as NSString
        let length = contents.length > 15 ? 15 : contents.length
        self.subject = contents.substring(with: NSRange(location: 0, length: length))
        
        self.navigationItem.title = self.subject
    }
}
