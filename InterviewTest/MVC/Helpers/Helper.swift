//
//  Helper.swift
//  InterviewTest
//
//  Created by Lalbin on 08/05/22.
//

import Foundation
//import UIKit
import Alamofire
import CoreData

class CheckNetworkState {
    func isConnected() ->Bool {
        return NetworkReachabilityManager()!.isReachable
    }
}


class DeleteDB{
    let managedObjectContext = CoreDataStack.sharedInstance.persistentContainer.viewContext
    func deleteAllData(entity: String)
    {
        let ReqVar = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        let DelAllReqVar = NSBatchDeleteRequest(fetchRequest: ReqVar)
        do { try managedObjectContext.execute(DelAllReqVar) }
        catch { print(error) }
    }
    

}

