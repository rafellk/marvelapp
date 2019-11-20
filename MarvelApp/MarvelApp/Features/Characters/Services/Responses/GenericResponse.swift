//
//  GenericResponse.swift
//  MarvelApp
//
//  Created by Rafael Lucena on 11/18/19.
//  Copyright © 2019 RLMG. All rights reserved.
//

import Foundation

struct GenericResponse<T>: Codable where T: Codable {
    var code: Int
    var data: T
}
