//
//  LeftChatCell.swift
//  Burst Dissertation
//
//  Created by Marawan Alwaraki on 30/12/2017.
//  Copyright © 2017 Marawan Alwaraki. All rights reserved.
//

import UIKit

class LeftChatCell: UITableViewCell {

    @IBOutlet weak var sender: UILabel!
    @IBOutlet weak var message: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
