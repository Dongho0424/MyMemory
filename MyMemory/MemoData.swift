//
//  MemoData.swift
//  MyMemory
//
//  Created by 최동호 on 2021/03/08.
//

import CoreData
import UIKit

class MemoData {
    var memoIdx : Int?
    var title : String?
    var contents : String?
    var image : UIImage?
    var regdate : Date?
    
    var objectId: NSManagedObjectID?
}
