//
//  FavoriteShop.swift .swift
//  ApiApp
//
//  Created by mba2408.silver kyoei.engine on 2024/10/25.
//

import RealmSwift

class FavoriteShop: Object {
    // 店舗id
    @Persisted(primaryKey: true) var id = ""

    // 店舗名
    @Persisted var name = ""

    // 店舗画像URL
    @Persisted var logoImageURL = ""

    // クーポン画面URL
    @Persisted var couponURL = ""

    //課題で追加　アドレス
    @Persisted var address = ""
}
