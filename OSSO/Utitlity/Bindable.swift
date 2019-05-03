//
//  Bindable.swift
//  OSSO
//
//  Created by Joe Bakalor on 8/30/18.
//  Copyright © 2019 SDC Future Electronics. All rights reserved.
//
import Foundation

class Bindable<T>{
    
    typealias Listener = (T) -> Void
    var listener: Listener?
    
    var value: T{
        didSet{
            listener?(value)
        }
    }
    
    init(_ value: T){
        self.value = value
    }
    
    func bind(listener: Listener?){
        self.listener = listener
        listener?(value)
    }
}
