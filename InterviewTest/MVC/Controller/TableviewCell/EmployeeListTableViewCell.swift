//
//  EmployeeListTableViewCell.swift
//  InterviewTest
//
//  Created by Lalbin on 08/05/22.
//

import UIKit
import Kingfisher

class EmployeeListTableViewCell: UITableViewCell {

    @IBOutlet weak var employeeProfilePicImageView: AnimatedImageView!
    @IBOutlet weak var employeeNameLabel: UILabel!
    @IBOutlet weak var complanyNameLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
