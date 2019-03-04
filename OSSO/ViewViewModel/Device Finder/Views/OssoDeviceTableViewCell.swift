//
//  OssDeviceTableViewCell.swift
//  OSSO
//
//  Created by Joe Bakalor on 12/11/18.
//  Copyright © 2018 Joe Bakalor. All rights reserved.
//

import Foundation
import UIKit

class OssoDeviceTableViewCell: UITableViewCell {
    
    let iconImageView = UIImageView()
    let deviceIdLabel = UILabel()
    let deviceIdValue = UILabel()
    let rssiValue = UILabel()
    let lineSeparatorLayer = CAShapeLayer()
    
    var cellData: (rssi: Int, index: Int)? {
        didSet{
            if let newData = cellData{
                self.deviceIdValue.text = "OSSO - 0\(newData.index)"
                self.rssiValue.text = "\(newData.rssi)"
                self.setNeedsLayout()
            }
            
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initView()
    }
    
    convenience init(){
        self.init(style: .default, reuseIdentifier: "LightControlCell")
        initView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initView()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initView()
    }
    
    func initView(){
        //set properties and add subviews
        self.contentView.addSubview(iconImageView)
        self.contentView.addSubview(deviceIdLabel)
        self.contentView.addSubview(deviceIdValue)
        self.contentView.addSubview(rssiValue)
        self.contentView.layer.borderColor = UIColor.black.cgColor
        self.contentView.layer.borderWidth = 1
        self.contentView.layer.cornerRadius = 5
        self.backgroundColor = UIColor.clear
        self.contentView.backgroundColor = UIColor.white
        self.iconImageView.contentMode = .scaleAspectFit
        self.iconImageView.image = UIImage(imageLiteralResourceName: "MediumDog")
        self.contentView.backgroundColor = UIColor.white
        self.contentView.layer.shadowColor           = UIColor.darkGray.cgColor
        self.contentView.layer.shadowOffset          = CGSize(width: 1, height: 2)
        self.contentView.layer.shadowRadius          = 2.0
        self.contentView.layer.shadowOpacity         = 1.0
        self.contentView.layer.masksToBounds         = false
        //iconImageView.backgroundColor = UIColor.black
    }
    
    override func layoutSubviews() {
        //layout frames
        super.layoutSubviews()
        let padding: CGFloat = self.bounds.width*0.01
        
        self.contentView.frame = CGRect(
            origin: CGPoint(
                x: self.bounds.width*0.075,
                y: self.bounds.height*0.1),
            size: CGSize(
                width: self.bounds.width*0.85,
                height: self.bounds.height*0.8))

        rssiValue.frame = CGRect(
            origin: CGPoint(
                x: self.contentView.bounds.width*0.825,
                y: 0),
            size: CGSize(
                width: contentView.bounds.width*0.175,
                height: (contentView.bounds.width*0.175)))
        
        //rssiValue.text = "-98"
        rssiValue.textAlignment = .center
        rssiValue.font = UIFont(name: rssiValue.font.fontName, size: rssiValue.frame.height*0.5)
        rssiValue.baselineAdjustment = .alignBaselines
        rssiValue.textColor = UIColor.black
        
        iconImageView.frame = CGRect(
            origin: CGPoint(
                x: contentView.bounds.height*0.1,
                y: contentView.bounds.height*0.1),
            size: CGSize(
                width: contentView.bounds.height*0.8,
                height: (contentView.bounds.height*0.8)))
        
        deviceIdLabel.frame = CGRect(
            origin: CGPoint(
                x: self.contentView.bounds.width*0.175 + padding,
                y: contentView.bounds.height/12),
            size: CGSize(
                width: contentView.bounds.width - contentView.bounds.width*0.175*2,
                height: (contentView.bounds.height/3)))
        
        deviceIdValue.frame = CGRect(
            origin: CGPoint(
                x: self.contentView.bounds.width*0.175 + padding,
                y: deviceIdLabel.frame.maxY),
            size: CGSize(
                width: contentView.bounds.width - contentView.bounds.width*0.175*2,
                height: (contentView.bounds.height/2)))
        
        deviceIdLabel.text = "Device ID:"
        //deviceIdValue.text = "C0:7A:20:39:2E:30"
        
        /*  Add horizontal separation lines */
        let separaterLinePath = UIBezierPath()
        
        /*  Add Left line */
        separaterLinePath.move(to: CGPoint(
            x: self.contentView.bounds.width*0.175,
            y: 0))
        separaterLinePath.addLine(to: CGPoint(
            x: self.contentView.bounds.width*0.175,
            y: self.contentView.bounds.height))
        
        /*  Add right line */
        separaterLinePath.move(to: CGPoint(
            x: self.contentView.bounds.width*0.825,
            y: 0))
        separaterLinePath.addLine(to: CGPoint(
            x: self.contentView.bounds.width*0.825,
            y: self.contentView.bounds.height))

        lineSeparatorLayer.path = separaterLinePath.cgPath
        lineSeparatorLayer.strokeColor = UIColor.black.cgColor
        lineSeparatorLayer.lineWidth = 1.0
        self.contentView.layer.addSublayer(lineSeparatorLayer)
        self.bringSubviewToFront(rssiValue)
        
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        self.contentView.backgroundColor = UIColor.white
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        //super.setSelected(selected, animated: animated)
        self.contentView.backgroundColor = UIColor.white
    }
}
