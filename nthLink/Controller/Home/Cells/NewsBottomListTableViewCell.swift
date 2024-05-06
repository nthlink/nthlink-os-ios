//
//  NewsBottomListTableViewCell.swift
//  nthLink
//
//  Created by Vaneet Modgill on 28/02/24.
//

import UIKit

class NewsBottomListTableViewCell: UITableViewCell {
    @IBOutlet weak var lbNews: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    
    func setupData(data:HeadlineNewsData?,index:Int) {
        lbNews.text = data?.title ?? ""
        
        if (index % 2 != 0) {
            self.contentView.backgroundColor = AppColors.newsListBackgroundCreamColor
        } else {
            self.contentView.backgroundColor = UIColor.white
        }
    }
    
}
