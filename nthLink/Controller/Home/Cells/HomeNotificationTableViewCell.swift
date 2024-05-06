//
//  HomeNotificationTableViewCell.swift
//  nthLink
//
//  Created by Vaneet Modgill on 28/02/24.
//

import UIKit

class HomeNotificationTableViewCell: UITableViewCell {
    @IBOutlet weak var lbNotice: UILabel!


    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupData(data:NotificationData?) {
        lbNotice.text = data?.title ?? ""
    }
    
}
