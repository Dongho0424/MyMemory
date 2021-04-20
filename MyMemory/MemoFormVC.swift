//
//  MemoFormVC.swift
//  MyMemory
//
//  Created by 최동호 on 2021/03/08.
//

import UIKit

class MemoFormVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate {
    // title
    var subject: String!

    // dao instance
    lazy var dao = MemoDAO()

    @IBOutlet var contents: UITextView!
    @IBOutlet var preview: UIImageView!

    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        contents.delegate = self

        let bgImage = UIImage(named: "memo-background.png")!
        view.backgroundColor = UIColor(patternImage: bgImage)

        // text view의 기본 속성
        contents.layer.borderWidth = 0
        contents.layer.borderColor = UIColor.clear.cgColor
        contents.backgroundColor = UIColor.clear

        let style = NSMutableParagraphStyle()
        style.lineSpacing = 9
        contents.attributedText = NSAttributedString(string: " ", attributes: [.paragraphStyle: style])
        contents.text = ""
    }

    // MARK: Actions

    @IBAction func save(_ sender: Any) {
        // 경고창 이미지
        let alertV = UIViewController()
        let iconImage = UIImage(named: "warning-icon-60")
        let imageV = UIImageView(image: iconImage)
        alertV.view.addSubview(imageV)
        if let iconSize = iconImage?.size {
            alertV.preferredContentSize = CGSize(width: iconSize.width, height: iconSize.height + 20)
        } else {
            alertV.preferredContentSize = CGSize.zero
        }

        // 1. 내용 입력하지 않았을 경우, 경고한다.
        guard !contents.text.isEmpty else {
            let alert = UIAlertController(title: nil, message: "내용을 입력해주세요", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            alert.setValue(alertV, forKey: "contentViewController")
            present(alert, animated: true)
            return
        }
        // 2. MemoData 객체를 생성하고, 데이터를 담는다.
        let data = MemoData()
        data.contents = contents.text
        data.image = preview.image
        let date = Date()
        data.regdate = date
        data.title = subject
        print(Date())

        //        // 3. 앱 델리게이트 객체 가져와서 저장
        //        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        //        appDelegate.memoList.append(data)

        // 3. DAO
        dao.insert(data)

        // 4. 이전 화면
        _ = navigationController?.popViewController(animated: true)
    }

    // MARK: - PickerView Delegate

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

    @IBAction func pick(_ sender: Any) {
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

    // 사용자가 이미지를 선택하면 자동으로 호출되는 메소드
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        preview.image = info[.editedImage] as? UIImage

        picker.dismiss(animated: true)
    }

    // MARK: - TextView Delegate

    // 사용자가 뭐라도 입력하면 자동 호출~
    // 제목 자동 생성
    func textViewDidChange(_ textView: UITextView) {
        let contents = textView.text as NSString
        let length = contents.length > 15 ? 15 : contents.length
        subject = contents.substring(with: NSRange(location: 0, length: length))

        navigationItem.title = subject
    }

    // MARK: UIResponder methods

    // Tells the responder when one or more fingers are raised from a view or window.
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let bar = navigationController?.navigationBar
        UIView.animate(withDuration: TimeInterval(0.3)) {
            bar?.alpha = (bar?.alpha == 0) ? 1 : 0
        }
    }
}
