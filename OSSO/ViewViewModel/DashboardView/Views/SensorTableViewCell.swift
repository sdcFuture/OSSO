//
//  SensorTableViewCell.swift
//  OSSO
//
//  Created by Joe Bakalor on 12/11/18.
//  Copyright © 2018 Joe Bakalor. All rights reserved.
//

import UIKit

class SensorTableViewCell: UITableViewCell {

    let cellTitle = UILabel()
    let iconRect = CAShapeLayer()
    let iconImageView = UIImageView()
    let lineSeparatorLayer = CAShapeLayer()
    var valueLabels: [(title: UILabel, value: UILabel)] = []

    var cellData: [(valueLabel: String, value: String)] = []{
        didSet{
            self.setNeedsLayout()
            initView()
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initView()
    }
    
    convenience init(cellData: [(valueLabel: String, value: String)]){
        self.init(style: .default, reuseIdentifier: "DashboardSensorCell")
        self.cellData = cellData
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
        self.contentView.addSubview(cellTitle)
        
        var i = 0
        cellData.forEach{_ in
            let title = UILabel()
            let value = UILabel()
            valueLabels.append((title: title, value: value))
            self.contentView.addSubview(title)
            self.contentView.addSubview(value)
            value.backgroundColor = UIColor.FutureGreen
            value.textAlignment = .center
            value.layer.cornerRadius = 3
            value.clipsToBounds = true
            title.text = cellData[i].valueLabel
            title.adjustsFontSizeToFitWidth = true
            value.adjustsFontSizeToFitWidth = true
            i += 1
        }
        self.contentView.backgroundColor = UIColor.white
        self.contentView.layer.borderColor = UIColor.black.cgColor
        self.contentView.layer.borderWidth = 1
        self.contentView.layer.cornerRadius = 5
        self.backgroundColor = UIColor.clear
        self.contentView.backgroundColor = UIColor.white
        self.contentView.layer.shadowColor           = UIColor.darkGray.cgColor
        self.contentView.layer.shadowOffset          = CGSize(width: 1, height: 2)
        self.contentView.layer.shadowRadius          = 2.0
        self.contentView.layer.shadowOpacity         = 1.0
        self.contentView.layer.masksToBounds         = false
        self.iconImageView.contentMode = .scaleAspectFit
        //self.iconImageView.image = UIImage(imageLiteralResourceName: "SensorPlaceHolder")

        cellTitle.textAlignment = .center
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
        
        let iconOutlineSquare = UIBezierPath(
            roundedRect: CGRect(
            origin: CGPoint(
                x: contentView.bounds.height*0.15/2,
                y: contentView.bounds.height*0.25 + contentView.bounds.height*0.15/2),
            size: CGSize(
                width: contentView.bounds.height*0.65,
                height: contentView.bounds.height*0.6)),
            byRoundingCorners: .allCorners,
            cornerRadii: CGSize(
                width: 7,
                height: 7))
        
        let workingLabelWidth = contentView.bounds.width
            - contentView.bounds.height*0.65
            - contentView.bounds.height*0.15
            - contentView.bounds.height*0.1
        
        if cellData.count == 1{
            valueLabels[0].title.frame = CGRect(
                origin: CGPoint(
                    x: contentView.bounds.height*0.65 + contentView.bounds.height*0.15,
                    y: contentView.bounds.height*0.25 + contentView.bounds.height*0.75/2 - contentView.bounds.height*0.25/2),
                size: CGSize(
                    width: workingLabelWidth*0.7,
                    height: contentView.bounds.height*0.25))
            
            //valueLabels[0].title.text = "SensorLabel"
            
            valueLabels[0].value.frame = CGRect(
                origin: CGPoint(
                    x: valueLabels[0].title.frame.maxX,
                    y: contentView.bounds.height*0.25 + contentView.bounds.height*0.75/2 - contentView.bounds.height*0.25/2),
                size: CGSize(
                    width: workingLabelWidth*0.3,
                    height: contentView.bounds.height*0.25))
            
            valueLabels[0].value.text = cellData[0].value
     
            //valueLabels[0].value.font = UIFont(name: valueLabels[0].value.font.fontName, size: valueLabels[0].value.frame.height*0.35)
        }
        else if cellData.count == 2{
            
            valueLabels[0].title.frame = CGRect(
                origin: CGPoint(
                    x: contentView.bounds.height*0.65 + contentView.bounds.height*0.15,
                    y: contentView.bounds.height*0.25 + contentView.bounds.height*0.15/2),
                size: CGSize(
                    width: workingLabelWidth*0.7,
                    height: contentView.bounds.height*0.25))
            
            
            valueLabels[0].value.frame = CGRect(
                origin: CGPoint(
                    x: valueLabels[0].title.frame.maxX,
                    y: contentView.bounds.height*0.25 + contentView.bounds.height*0.15/2),
                size: CGSize(
                    width: workingLabelWidth*0.3,
                    height: contentView.bounds.height*0.25))
            
            valueLabels[0].value.text = cellData[0].value
            
            valueLabels[1].title.frame = CGRect(
                origin: CGPoint(
                    x: contentView.bounds.height*0.65 + contentView.bounds.height*0.15,
                    y: contentView.bounds.height*0.25 + contentView.bounds.height*0.15/2 + contentView.bounds.height*0.6 - contentView.bounds.height*0.25),
                size: CGSize(
                    width: workingLabelWidth*0.7,
                    height: contentView.bounds.height*0.25))
            
            
            valueLabels[1].value.frame = CGRect(
                origin: CGPoint(
                    x: valueLabels[0].title.frame.maxX,
                    y: contentView.bounds.height*0.25 + contentView.bounds.height*0.15/2 + contentView.bounds.height*0.6 - contentView.bounds.height*0.25),
                size: CGSize(
                    width: workingLabelWidth*0.3,
                    height: contentView.bounds.height*0.25))
            
            valueLabels[1].value.text = cellData[1].value
        }
        
        iconImageView.frame = CGRect(
            origin: CGPoint(
                x: iconOutlineSquare.bounds.origin.x + iconOutlineSquare.bounds.width*0.1/2,
                y: iconOutlineSquare.bounds.origin.y + iconOutlineSquare.bounds.height*0.1/2),
            size: CGSize(
                width: iconOutlineSquare.bounds.width*0.9,
                height: iconOutlineSquare.bounds.height*0.9))
        
        iconRect.path = iconOutlineSquare.cgPath
        iconRect.fillColor = UIColor.clear.cgColor
        iconRect.strokeColor = UIColor.black.cgColor
        iconRect.borderColor = UIColor.black.cgColor
        iconRect.borderWidth = 1
        self.contentView.layer.addSublayer(iconRect)
        
        /*  Add horizontal separation lines */
        let separaterLinePath = UIBezierPath()
        
        /*  Add Left line */
        separaterLinePath.move(to: CGPoint(
            x: 0,
            y: self.contentView.bounds.height*0.25))
        separaterLinePath.addLine(to: CGPoint(
            x: self.contentView.bounds.width,
            y: self.contentView.bounds.height*0.25))

        lineSeparatorLayer.path = separaterLinePath.cgPath
        lineSeparatorLayer.strokeColor = UIColor.black.cgColor
        lineSeparatorLayer.lineWidth = 1.0
        self.contentView.layer.addSublayer(lineSeparatorLayer)
        
        cellTitle.frame = CGRect(
            origin: .zero,
            size: CGSize(
                width: contentView.bounds.width,
                height: contentView.bounds.height*0.25))
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        //super.setSelected(selected, animated: animated)
        
    }

}

extension UIColor{
    static var FutureGreen: UIColor{
        return UIColor(red: 3/255, green: 177/255, blue: 80/255, alpha: 1)
    }
}

