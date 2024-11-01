//
//  ApiResponse.swift
//  ApiApp
//
//  Created by mba2408.silver kyoei.engine on 2024/10/24.
//

import Foundation
import RealmSwift

struct ApiResponse: Decodable {
    var results: Result
    struct Result: Decodable {
        var shop: [Shop]
        struct Shop: Decodable {
            var id: String
            var name: String
            var logo_image: String
            var address: String //課題で追加
            var coupon_urls: CouponUrls
            struct CouponUrls: Decodable {
                var pc: String
                var sp: String
            }
            
            var isFavorite: Bool {
                if try! Realm().object(ofType: FavoriteShop.self, forPrimaryKey: self.id) != nil {
                    return true
                } else {
                    return false
                }
            }
        }
    }
}
