//
//  shopCell.swift
//  ApiApp
//
//  Created by mba2408.silver kyoei.engine on 2024/10/23.
//

import UIKit

class shopCell: UITableViewCell {
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var shopNameLabel: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!    
    @IBOutlet weak var shopAddress: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
