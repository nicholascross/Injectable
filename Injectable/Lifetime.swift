//
//  Lifetime.swift
//  Injectable
//
//  Created by Nicholas Cross on 19/1/19.
//  Copyright © 2019 Nicholas Cross. All rights reserved.
//

import Foundation

public enum Lifetime {
    case ephemeral  //always a new object
    case transient  //a new object unless there is an instance already in memory
    case persistent //always the same object
}
