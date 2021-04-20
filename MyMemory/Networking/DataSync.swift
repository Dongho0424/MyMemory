//
//  DataSync.swift
//  MyMemory
//
//  Created by 최동호 on 2021/04/13.
//

import Foundation
import UIKit
import CoreData
import Alamofire

class DataSync {
    // context of core data
    var context: NSManagedObjectContext!
    
    init() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.context = appDelegate.persistentContainer.viewContext
    }
    
    // download data for the first time that user downlaod this app
    // so that this func is only called at once
    func downloadBackupData() {
        // 1. only the first time
        let ud = UserDefaults.standard
        guard ud.value(forKey: "firstLogin") == nil else {
            return
        }
        
        // 2. header
        let header = Token().authorizationHeader
        
        // 3. API
        let url = "http://swiftapi.rubypaper.co.kr:2029/memo/search"
        let call = AF.request(url, method: .post, encoding: JSONEncoding.default, headers: header)
        
        // 4. response handling
        call.responseJSON { res in
            // 5. bad response -> return
            guard
                let jsonObject = try? res.result.get() as? NSDictionary,
                let list = jsonObject["list"] as? NSArray
            else {
                return
            }
            
            // 6. save each memo data to core data
            for memo in list {
                guard let record = memo as? NSDictionary else { return }
                
                // 7. create Managed Object instace with context
                guard
                    let entity = NSEntityDescription.entity(forEntityName: "Memo", in: self.context),
                    let memoMO = NSManagedObject(entity: entity, insertInto: self.context) as? MemoMO
                else { return }
                
                memoMO.title = record["title"] as? String
                memoMO.contents = record["contents"] as? String
                memoMO.regdate = self.stringToDate((record["create_date"] as! String))
                memoMO.sync = true
                
                // 8. if image exists
                if let imagePath = record["image_path"] as? String {
                    print("downloadBackUpdata, imagePath exists")
                    let url = URL(string: imagePath)!
                    memoMO.image = try! Data(contentsOf: url)
                }
            } // for memo in list
            
            // 9. commit to persistant container
            do {
                try self.context.save()
            } catch let e as NSError {
                self.context.rollback()
                NSLog("An error has occurred : %s", e.localizedDescription)
            }
            
            // 10.
            ud.setValue(true, forKey: "firstLogin")
        }
    }
    
    func uploadData(indicatorView: UIActivityIndicatorView? = nil){
        // 1. 요청 객체
        let fetchRequest : NSFetchRequest<MemoMO> = MemoMO.fetchRequest()
        
        // 2. ORDER BY
        let order = NSSortDescriptor(key: "regdate", ascending: false)
        fetchRequest.sortDescriptors = [order]
        
        // 3. WHERE
        fetchRequest.predicate = NSPredicate(format: "sync == false")
        
        // 4. upload
        do {
            let resultSet = try self.context.fetch(fetchRequest)
            
            // start indicator
            indicatorView?.startAnimating()
            
            for memo in resultSet {
                uploadDatum(memo){
                    if memo === resultSet.last {
                        // if last one, stop animating
                        indicatorView?.stopAnimating()
                    }
                }
            }
        } catch let e as NSError {
            print(e.localizedDescription)
        }
    }
    
    func uploadDatum(_ item: MemoMO, complete: (() -> Void)? = nil) {
        // 1. header
        let tk = Token()
        guard let header = tk.authorizationHeader else {
            print("uploadDatum error. user is guest so that could not upload data to server")
            return
        }
        
        // 2. param
        var param = SyncReq(title: item.title!,
                            contents: item.contents!,
                            createDate: self.dateToString(item.regdate!),
                            image: "")
        if let imageData = item.image as Data? {
            
            param.image = imageData.base64EncodedString()
        }
        
        // 3. req
        let url = "http://swiftapi.rubypaper.co.kr:2029/memo/save"
        let call = AF.request(url, method: .post, parameters: param, encoder: JSONParameterEncoder.default, headers: header)
        
        // 4. res
        call.responseJSON { res in
            guard let jsonObject = try? res.result.get() as? NSDictionary else {
                print("uploadDatum. res error")
                return
            }
            
            let resultCode = jsonObject["result_code"] as! Int
            if resultCode == 0 {
                print("[\(item.title!)]이(가) 서버와 동기화 되었습니다.")
                
                // core data에 반영
                do {
                    item.sync = true
                    try self.context.save()
                } catch let e as NSError {
                    self.context.rollback()
                    print(e.localizedDescription)
                }
            } else {
                print(jsonObject["error_msg"] as! String)
            }
        } // end of responseJSON closure
        complete?()
    }
    
}
// MARK: - Utils
extension DataSync {
    // String => Date
    func stringToDate(_ value: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter.date(from: value)!
    }
    
    // Date => String
    func dateToString(_ value: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter.string(from: value)
    }
}

