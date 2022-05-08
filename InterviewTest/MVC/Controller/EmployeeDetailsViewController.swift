//
//  EmployeeDetailsViewController.swift
//  InterviewTest
//
//  Created by Lalbin on 08/05/22.
//

import UIKit
import Kingfisher
class EmployeeDetailsViewController: UIViewController {
    var employeeDetailsArray = EmployeeListViewController.employeeStruct()
    
    @IBOutlet weak var profilePicImageView: AnimatedImageView!
    @IBOutlet weak var empDetailsLabel: UILabel!
    @IBOutlet weak var companyDetailsLabel: UILabel!
    
    @IBOutlet weak var companyCard: UIView!
    fileprivate func displayEmployeeDetails(){
        companyCard.layer.cornerRadius = 10
        let empData = self.employeeDetailsArray
        profilePicImageView.layer.cornerRadius = 25
        let imageURL = URL(string: empData.image ?? "")
        profilePicImageView.kf.setImage(with: imageURL, placeholder: UIImage(named: "DefaultUserImage"), options: .none, progressBlock: nil, completionHandler: { result in
            switch result {
            case .success(let value):
                print("Image: \(value.image). Got from: \(value.cacheType)")
                
            case .failure(let error):
                print("Error: \(error)")
                self.profilePicImageView.image = UIImage(named: "DefaultUserImage")
            }
        })
        self.empDetailsLabel.text = "\(empData.name ?? "") \n UserName: \(empData.username ?? "")\n Email: \(empData.email ?? "") \n Phone: \(empData.phone ?? "") \n Address: \(empData.address ?? "")"
        
        self.companyDetailsLabel.text = "Company name: \(empData.companyName ?? "")\n Catch Phrase: \(empData.catchPhrase ?? "")"
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.displayEmployeeDetails()

        
        
    }
    

   

}
