//
//  ComicResponse.swift
//  MarvelApp
//
//  Created by Rafael Lucena on 11/24/19.
//  Copyright © 2019 RLMG. All rights reserved.
//

import Foundation

struct ComicResponse: Codable {
    var id: Int
    var title: String
    var thumbnail: Thumbnail
}
