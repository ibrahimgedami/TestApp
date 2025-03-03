//
//  FilterTableViewCell.swift
//  Seddiqi Retail
//
//  Created by Ibrahim Gedami on 11/12/2023.
//  Copyright © 2023 Amr Elghadban (AmrAngry). All rights reserved.
//

import UIKit

struct FilterViewModel {
    
    var title: String
    var code: String
    var isSelected: Bool
    
}

class FilterTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var checkedImage: UIImageView?
        
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
    }
    
    func configCell(_ model: FilterViewModel) {
        handleIsSelected(isSelected: model.isSelected)
        titleLabel?.text = model.title
    }

    func handleIsSelected(isSelected: Bool) {
         guard isSelected else {
//            checkedImage?.image = UIImage.unCheck
            return
        }
//        checkedImage?.image = UIImage.check
    }
    
}
