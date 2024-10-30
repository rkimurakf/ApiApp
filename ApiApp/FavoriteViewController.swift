//
//  FavoriteViewController.swift
//  ApiApp
//
//  Created by mba2408.silver kyoei.engine on 2024/10/23.
//

import UIKit
import RealmSwift
import AlamofireImage

class FavoriteViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var statusLabel: UILabel!
    
    let realm = try! Realm() //chapter6.3で追加
    var favoriteArray = try! Realm().objects(FavoriteShop.self)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self //chapter6.2で追加
        tableView.dataSource = self //chapter6.2で追加
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func tapFavoriteButton(_ sender: UIButton) {
        let point = sender.convert(CGPoint.zero, to: tableView) //chapter6.3で追加
        let indexPath = tableView.indexPathForRow(at: point)!//chapter6.3で追加
        let favoriteShop = favoriteArray[indexPath.row]//chapter6.3で追加
        
        let alert = UIAlertController(title: favoriteShop.name, message: "この店舗をお気に入りから削除してもよろしいですか?", preferredStyle: .alert)//chapter6.3で追加
        
        let okAction = UIAlertAction(title: "OK", style: .default) { action in//chapter6.3で追加
            print("「\(favoriteShop.name)」をお気に入りから削除します")//chapter6.3で追加
            try! self.realm.write {//chapter6.3で追加
                self.realm.delete(favoriteShop)//chapter6.3で追加
            }
            self.tableView.reloadData()//chapter6.3で追加
            if self.favoriteArray.count == 0 {//chapter6.3で追加
                self.statusLabel.text = "お気に入りはまだ登録されていません"//chapter6.3で追加
            } else {
                self.statusLabel.text = ""//chapter6.3で追加
            }
        }
        alert.addAction(okAction)//chapter6.3で追加
        
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel)//chapter6.3で追加
        alert.addAction(cancelAction)//chapter6.3で追加
        
        present(alert, animated: true)//chapter6.3で追加
    }
    
    
    

    
    override func viewWillAppear(_ animated: Bool) {//chapter6.2で追加
        super.viewWillAppear(animated)//chapter6.2で追加
        
        tableView.reloadData()//chapter6.2で追加
        if favoriteArray.count == 0 {//chapter6.2で追加
            statusLabel.text = "お気に入りはまだ登録されていません"//chapter6.2で追加
        } else {//chapter6.2で追加
            statusLabel.text = ""//chapter6.2で追加
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {//chapter6.2で追加
        return favoriteArray.count//chapter6.2で追加
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {//chapter6.2で追加
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! shopCell//chapter6.2で追加
        let favoriteShop = favoriteArray[indexPath.row]//chapter6.2で追加
        let url = URL(string: favoriteShop.logoImageURL)!//chapter6.2で追加
        cell.logoImageView.af.setImage(withURL: url)//chapter6.2で追加
        cell.shopNameLabel.text = favoriteShop.name//chapter6.2で追加
        cell.shopAddress.text = favoriteShop.address// 課題で追加
        return cell//chapter6.2で追加
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
