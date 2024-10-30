//
//  ApiViewController.swift
//  ApiApp
//
//  Created by mba2408.silver kyoei.engine on 2024/10/23.
//

import UIKit
import Alamofire
import AlamofireImage
import RealmSwift
import SafariServices//chapter7.1で追加

class ApiViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,UISearchBarDelegate{
    
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!    
    @IBOutlet weak var searchField: UISearchBar!
    
    let realm = try! Realm()

    var shopArray: [ApiResponse.Result.Shop] = []

    var apiKey: String = ""

    var isLoading = false
    var isLastLoaded = false
    var currentKeyword: String = "居酒屋"//課題で追加①

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        searchField.delegate = self

        // APIキー読み込み
        let filePath = Bundle.main.path(forResource: "ApiKey", ofType:"plist" )
        let plist = NSDictionary(contentsOfFile: filePath!)!
        apiKey = plist["Key"] as! String

        // shopArray読み込み
        updateShopArray(keyword: currentKeyword)//課題で追加②

        // RefreshControlの設定
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        tableView.reloadData()
    }

    @objc func refresh() {
        // shopArray再読み込み
        updateShopArray(keyword: currentKeyword)//引数に値を追加③
    }

    func updateShopArray(keyword: String, appendLoad: Bool = false) {//課題で引数いkeywordを追加④
        // 現在読み込み中なら読み込みを開始しない
        if isLoading {
            return
        }
        // 最後まで読み込んでいるなら、追加読み込みしない
        if appendLoad && isLastLoaded {
            return
        }
        // 読み込み開始位置を設定
        let startIndex: Int
        if appendLoad {
            startIndex = shopArray.count + 1
        } else {
            startIndex = 1
        }
        // 読み込み中状態開始
        isLoading = true
        
        let parameters: [String: Any] = [
            "key": apiKey,
            "start": startIndex,
            "count": 20,
            "keyword": keyword,//課題で値を変更⑤
            "format": "json"
        ]
        print("APIリクエスト 開始位置: \(parameters["start"]!) 読み込み店舗数: \(parameters["count"]!)")
        AF.request("https://webservice.recruit.co.jp/hotpepper/gourmet/v1/", method: .get, parameters: parameters).responseDecodable(of: ApiResponse.self) { response in
            // 読み込み中状態終了
            self.isLoading = false
            // リフレッシュ表示動作停止
            if self.tableView.refreshControl!.isRefreshing {
                self.tableView.refreshControl!.endRefreshing()
            }
            // レスポンス受信処理
            switch response.result {
            case .success(let apiResponse):
                // print("受信データ: \(apiResponse)")
                print("受信店舗数: \(apiResponse.results.shop.count)")
                if appendLoad {
                    // 追加読み込みの場合は、現在のshopArrayに追加
                    self.shopArray += apiResponse.results.shop
                } else {
                    // 追加読み込みでない場合はそのまま代入し、isLastLoadedをリセット
                    self.shopArray = apiResponse.results.shop
                    self.isLastLoaded = false
                }
                // 読み込み数が0なら最後まで読み込まれたと判断
                if apiResponse.results.shop.count == 0 {
                    self.isLastLoaded = true
                }
                self.statusLabel.text = ""
            case .failure(let error):
                print(error)
                self.shopArray = []
                self.isLastLoaded = true
                self.statusLabel.text = "データの取得が失敗しました"
            }
            self.tableView.reloadData()
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        currentKeyword = searchText
        updateShopArray(keyword: currentKeyword)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shopArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! shopCell
        let shop = shopArray[indexPath.row]
        let url = URL(string: shop.logo_image)!
        cell.logoImageView.af.setImage(withURL: url)
        cell.shopNameLabel.text = shop.name
        cell.shopAddress.text = shop.address
        let starImageName = shop.isFavorite ? "star.fill" : "star"
        let starImage = UIImage(systemName: starImageName)?.withRenderingMode(.alwaysOriginal)
        cell.favoriteButton.setImage(starImage, for: .normal)

        // 追加データの読み込みが必要か確認
        if shopArray.count - indexPath.row < 10 {
            self.updateShopArray(keyword:currentKeyword, appendLoad: true)
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let shop = shopArray[indexPath.row]
        let urlString: String
        if shop.coupon_urls.sp == "" {
            urlString = shop.coupon_urls.pc
        } else {
            urlString = shop.coupon_urls.sp
        }
        let url = URL(string: urlString)!
        let safariViewController = SFSafariViewController(url: url)
        safariViewController.modalPresentationStyle = .pageSheet
        present(safariViewController, animated: true)
    }

    @IBAction func tapFavoriteButton(_ sender: UIButton) {
        let point = sender.convert(CGPoint.zero, to: tableView)
        let indexPath = tableView.indexPathForRow(at: point)!
        let shop = shopArray[indexPath.row]

        if shop.isFavorite {
            print("「\(shop.name)」をお気に入りから削除します")
            try! realm.write {
                let favoriteShop = realm.object(ofType: FavoriteShop.self, forPrimaryKey: shop.id)!
                realm.delete(favoriteShop)
            }
        } else {
            print("「\(shop.name)」をお気に入りに追加します")
            try! realm.write {
                let favoriteShop = FavoriteShop()
                favoriteShop.id = shop.id
                favoriteShop.name = shop.name
                favoriteShop.logoImageURL = shop.logo_image
                favoriteShop.address = shop.address
                if shop.coupon_urls.sp == "" {
                    favoriteShop.couponURL = shop.coupon_urls.pc
                } else {
                    favoriteShop.couponURL = shop.coupon_urls.sp
                }
                realm.add(favoriteShop)
            }
        }
        tableView.reloadData()
    }
    
    
    
    
}
