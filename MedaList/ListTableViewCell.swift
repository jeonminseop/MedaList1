//
//  ListTableViewCell.swift
//  Priority
//
//  Created by 전민섭 on 2017/06/21.
//  Copyright © 2017年 전민섭. All rights reserved.
//

import UIKit

class ListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var listLabel: UILabel!
    @IBOutlet weak var medalImageView: UIImageView!
    @IBOutlet weak var checkBox: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
