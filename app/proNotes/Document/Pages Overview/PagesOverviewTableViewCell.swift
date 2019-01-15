//
//  PagesOverviewTableViewCell.swift
//  proNotes
//
//  Created by Leo Thomas on 28/11/15.
//  Copyright © 2015 leonardthomas. All rights reserved.
//

import UIKit

protocol PagesOverviewTableViewCellDelegate: class {
    func showPage(_ index: Int)
}

class PagesOverviewTableViewCell: UITableViewCell {

    static let identifier = "PagesOverViewTableViewCellIdentifier"

    @IBOutlet weak var pageThumbView: UIButton!
    @IBOutlet weak var numberLabel: UILabel!
    
    @IBOutlet weak var pageThumbViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var pageThumbViewWidthConstraint: NSLayoutConstraint!
    
    weak var delegate: PagesOverviewTableViewCellDelegate?
    var index = 0 {
        didSet {
            numberLabel.text = "\(index + 1)"
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        pageThumbView.layer.setUpDefaultShaddow()
        backgroundColor = UIColor.clear
    }

    @IBAction func handlePageButtonPressed(_ sender: AnyObject) {
        delegate?.showPage(index)
    }
    
    override func prepareForReuse() {
        pageThumbView.setBackgroundImage(nil, for: UIControlState())
    }

}
