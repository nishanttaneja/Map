//
//  MapItemTableViewCell.swift
//  Map
//
//  Created by Nishant Taneja on 10/03/21.
//

import UIKit

class MapItemTableViewCell: UITableViewCell {
    // IBOutlets
    @IBOutlet weak var leftImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    // Variable
    var leftImage: UIImage? {
        get { leftImageView.image }
        set { leftImageView.image = newValue }
    }
    var title: String? {
        get { titleLabel.text }
        set { titleLabel.text = newValue }
    }
    var subtitle: String? {
        get { subtitleLabel.text }
        set { subtitleLabel.text = newValue}
    }
    var number: String?
    
    // IBAction
    @IBAction func callButtonAction(_ sender: UIButton) {
        print(number)
    }
}
