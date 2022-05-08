//
//  EmployeeListViewController.swift
//  InterviewTest
//
//  Created by Lalbin on 08/05/22.
//

import UIKit
import Alamofire
import Kingfisher
import CoreData

class EmployeeListViewController: UIViewController {
    struct employeeStruct{
        var name,username,image,email,phone,website,address,companyName,catchPhrase:String?
    }
    
    
    
    var employeeDetailsArray = [employeeStruct]()
    var networkState = CheckNetworkState()
    var deleteDBData = DeleteDB()
    typealias FinishedDBFetch = () -> ()
    let managedObjectContext = CoreDataStack.sharedInstance.persistentContainer.viewContext
    @IBOutlet weak var loadApiBtn: UIButton!
    @IBOutlet weak var employeeListTableView: UITableView!
    
    
    
    @IBAction func loadApiBtnTouchin(_ sender: Any) {
        self.loadDataFromApi()
    }
    
    func loadDataFromApi(){
        if self.networkState.isConnected(){
            let parameters = ["" : ""]
            let url = URL(string: ServerClass.ConnectionURL.getEmployeeDetailsURL)!
            print(url)
            var jsonData: Data? = nil
            do {
                jsonData = try JSONSerialization.data(withJSONObject: parameters, options: [])
            } catch {
                
            }
            print(parameters)
            
            let urlString = "data= \(String(data: jsonData!, encoding: .utf8) ?? "")"
            print(urlString)
            let postData = urlString.data(using: .ascii, allowLossyConversion: true)
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Accept")
            request.setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "content-type")
            request.httpBody = postData
            
            Alamofire.request(request).responseJSON {
                response in switch response.result {
                case.success(let JSON):
                    let resultArray = JSON as! NSArray
                    print(resultArray)
                    
                    if(resultArray.count > 0){
                        let context = CoreDataStack.sharedInstance.persistentContainer.viewContext
                         self.deleteDBData.deleteAllData(entity: "Employee")
                        for employeeData in resultArray{
                            let eachEmployee = employeeData as? NSDictionary
                            var employeeAddress,companyName,phrase:String?
                            
                            
                            let empId = eachEmployee?.value(forKey: "id") as? Int
                            let empName = eachEmployee?.value(forKey: "name") as? String
                            let empUsername = eachEmployee?.value(forKey: "username") as? String
                            let empWebsite = eachEmployee?.value(forKey: "website") as? String
                            let empPhone = eachEmployee?.value(forKey: "phone") as? String
                            let empImage = eachEmployee?.value(forKey: "profile_image") as? String
                            let empEmail = eachEmployee?.value(forKey: "email") as? String
                            let empAddressArray = eachEmployee?.value(forKey: "address") as? NSArray
                            let empCompanyArray = eachEmployee?.value(forKey: "company") as? NSArray
                            if(empAddressArray?.count ?? 0 > 0){
                                for empAddress in empAddressArray!{
                                    let address = empAddress as? NSDictionary
                                    let city = address?.value(forKey: "city") as? String
                                    let street = address?.value(forKey: "street") as? String
                                    let suite = address?.value(forKey: "suite") as? String
                                    let zipcode = address?.value(forKey: "zipcode") as? String
                                    employeeAddress = "\(city ?? ""), \(street ?? ""), \(suite ?? ""), \(zipcode ?? "")"
                                }
                            }
                            if(empCompanyArray?.count ?? 0 > 0){
                                for empCompany in empCompanyArray!{
                                    let companyDetails = empCompany as? NSDictionary
                                    let name = companyDetails?.value(forKey: "name") as? String
                                    let catchPhrase = companyDetails?.value(forKey: "catchPhrase") as? String
                                    companyName = name ?? ""
                                    phrase = catchPhrase ?? ""
                                }
                            }
                            if let employeeEntity = NSEntityDescription.insertNewObject(forEntityName: "Employee", into: context) as? Employee {
                                employeeEntity.id = Int32(empId ?? 0)
                                employeeEntity.name = empName ?? ""
                                employeeEntity.website = empWebsite ?? ""
                                employeeEntity.userName = empUsername ?? ""
                                employeeEntity.phone = empPhone ?? ""
                                employeeEntity.image = empImage ?? ""
                                employeeEntity.email = empEmail ?? ""
                                employeeEntity.companyName = companyName ?? ""
                                employeeEntity.catchPhrase = phrase ?? ""
                                employeeEntity.address = employeeAddress ?? ""
                            
                            
                            
                            
                        }
                    }
                        do {
                            try CoreDataStack.sharedInstance.persistentContainer.viewContext.save()
                            
                                } catch let error {
                                print(error)
                                    print("DB insert error--->>>")
                        }
                    
                    }
                    self.fetchEmployeeDataFromDB{ () -> () in
                        self.displayEmployeeDetails()
                     }

                case .failure(let error):
                    print("Request failed with error: \(error)")
                    let alertController = UIAlertController(title: "Employee register", message: "Something went wrong. Request cannot be processed", preferredStyle: UIAlertController.Style.alert)
                      let cancelAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel)
                      alertController.addAction(cancelAction)
                      self.present(alertController, animated: true, completion: nil)
                }
                
            }
            
        }else{
            let alertController = UIAlertController(title: "Employee register", message: "Your internet connection has been lost, Please try after some time", preferredStyle: UIAlertController.Style.alert)
              let okAction = UIAlertAction(title: "Retry", style: .default, handler: { (AlertAction) in
                  self.loadDataFromApi()
              })
              let cancelAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel)
              alertController.addAction(cancelAction)
              alertController.addAction(okAction)
              self.present(alertController, animated: true, completion: nil)
        }
    }
    
    
    
    func fetchEmployeeDataFromDB(completed: FinishedDBFetch){
        let classListRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Employee")
        classListRequest.returnsObjectsAsFaults = false
        do {
            let result = try managedObjectContext.fetch(classListRequest)
            self.employeeDetailsArray.removeAll()
            for data in result as! [NSManagedObject] {
                
                let name = data.value(forKey: "name") as? String
                let userName = data.value(forKey: "userName") as? String
                let image = data.value(forKey: "image") as? String
                let email = data.value(forKey: "email") as? String
                let phone = data.value(forKey: "phone") as? String
                let website = data.value(forKey: "website") as? String
                let address = data.value(forKey: "address") as? String
                let companyName = data.value(forKey: "companyName") as? String
                let catchPhrase = data.value(forKey: "catchPhrase") as? String
                
                
                self.employeeDetailsArray.append(employeeStruct(name: name ?? "",
                                                                username: userName ?? "",
                                                                image: image ?? "",
                                                                email: email ?? "",
                                                                phone: phone ?? "",
                                                                website: website ?? "",
                                                                address: address ?? "",
                                                                companyName: companyName ?? "",
                                                                catchPhrase: catchPhrase ?? ""
                                                               ))
            }
            
        }
        catch {
            print("Data fetch from DB Failed---->>")
        }
        completed()
    }
    
    func displayEmployeeDetails(){
        self.employeeListTableView.isHidden = false
        self.employeeListTableView.delegate = self
        self.employeeListTableView.dataSource = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.hidesBarsOnTap = true
        self.employeeListTableView.isHidden = true

        self.fetchEmployeeDataFromDB{ () -> () in
            if(self.employeeDetailsArray.count > 0){
                self.displayEmployeeDetails()
            }else{
                self.loadDataFromApi()
            }
        }
    }
    

   

}

//MARK:- Extension for tableview
extension EmployeeListViewController: UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.employeeDetailsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let employeeCell = employeeListTableView.dequeueReusableCell(withIdentifier: "EmployeeListTableViewCell") as? EmployeeListTableViewCell else { return UITableViewCell()}
        let employeeData = self.employeeDetailsArray[indexPath.row]
        
        employeeCell.employeeNameLabel.text = employeeData.name ?? ""
        employeeCell.complanyNameLabel.text = employeeData.companyName ?? ""
        employeeCell.employeeProfilePicImageView.layer.cornerRadius = 25
        let imageURL = URL(string: employeeData.image ?? "")
        employeeCell.employeeProfilePicImageView.kf.setImage(with: imageURL, placeholder: UIImage(named: "DefaultUserImage"), options: .none, progressBlock: nil, completionHandler: { result in
               switch result {
               case .success(let value):
                   print("Image: \(value.image). Got from: \(value.cacheType)")
                   
               case .failure(let error):
                   print("Error: \(error)")
                   employeeCell.employeeProfilePicImageView.image = UIImage(named: "DefaultUserImage")
               }
        })
        
        return employeeCell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let employeeDetailsVC = UIStoryboard(name: "Main", bundle:nil).instantiateViewController(withIdentifier: "EmployeeDetails") as? EmployeeDetailsViewController else {return}
        let selectedEmpData = self.employeeDetailsArray[indexPath.row]
        employeeDetailsVC.employeeDetailsArray = selectedEmpData
        employeeDetailsVC.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(employeeDetailsVC, animated: true)
//        self.present(employeeDetailsVC, animated: true, completion: nil)
        
    }
    
    
}
