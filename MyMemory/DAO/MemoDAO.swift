//
//  File.swift
//  MyMemory
//
//  Created by 최동호 on 2021/04/06.
//

import UIKit
import CoreData
import Foundation

class MemoDAO {
    lazy var context: NSManagedObjectContext = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        return context
    }()
    
    // context를 통해 container에서 꺼내와서 복사해서 리스트 만들고 전달
    func fetch(keyword text: String? = nil) -> [MemoData] {
        var memoList = [MemoData]()
        
        // 1. fetch request instance
        let fetchRequest : NSFetchRequest<MemoMO> = MemoMO.fetchRequest()
        
        // 1-1. sort
        let sort = NSSortDescriptor(key: "regdate", ascending: false)
        fetchRequest.sortDescriptors = [sort]
        
        // 1-2. keyword
        if let _text = text, _text.isEmpty == false {
            let predicate = NSPredicate(format: "contents CONTAINS[c] %@", _text)
            fetchRequest.predicate = predicate
        }
        
        do {
            let moSet = try self.context.fetch(fetchRequest)
            
            for mo in moSet {
                let memo = MemoData()
                
                memo.title = mo.title
                memo.regdate = mo.regdate
                memo.contents = mo.contents
                memo.objectId = mo.objectID // for refer to memo
                
                if let imageData = mo.image as Data? {
                    memo.image = UIImage(data: imageData)
                }
                
                memoList.append(memo)
            }
            
        } catch let error as NSError {
            NSLog("An error has occurred : %s", error.localizedDescription)
        }
        
        return memoList
    }
    
    func insert(_ data: MemoData) {
        // 1. managed object 객체 생성
        let object = NSEntityDescription.insertNewObject(forEntityName: "Memo", into: self.context) as! MemoMO
        
        // 2. 값 복사해서
        object.title = data.title
        object.regdate = data.regdate
        object.contents = data.contents
        
        if let image = data.image {
            object.image = image.pngData()
        }
        
        // 3. 영구 저장소에 변경 사항을 저장한다.
        do {
            try self.context.save()
            
            let uinfo = UserInfoManager()
            if uinfo.isLogin == true {
                DispatchQueue.global(qos: .background).async {
                    let sync = DataSync()
                    sync.uploadDatum(object)
                }
            }
        } catch let error as NSError {
            NSLog("An error has occurred : %s", error.localizedDescription)
        }
    }
    
    func delete(_ objectId: NSManagedObjectID) -> Bool {
        let object = self.context.object(with: objectId)
        self.context.delete(object)
        
        do {
            try self.context.save()
            return true
        } catch let error as NSError {
            NSLog("An error has occurred : %s", error.localizedDescription)
            return false
        }
    }
}

