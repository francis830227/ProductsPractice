//
//  FetchManager.swift
//  GoodLifeCodePractice
//
//  Created by Francis Tseng on 2017/9/28.
//  Copyright © 2017年 Francis Tseng. All rights reserved.
//

import Foundation

protocol ProductsDelegate: class {
    func didGet(_ products: [Product])
}

protocol ProductDelegate: class {
    func didGet(_ product: Product)
}

class FetchManager {
    
    weak var delegateProducts: ProductsDelegate?
    
    weak var delegateProduct: ProductDelegate?
    
    var accessToken = ""
    
    let apiVersion = 2
    
    let typeSimplifiedId = 1
    
    var page = 1
    
    func fetchToken(_ code: String) {

        let parameters = [
            "grant_type":"authorization_code",
            "code": code,
            "client_id": OAuth.clientID.rawValue,
            "client_secret": OAuth.clientSecret.rawValue,
            "redirect_uri": OAuth.redirectUri.rawValue
        ]
        
        guard let url = URL(string: "http://api.igoodtravel.com/oauth/token") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch let error {
            print(error.localizedDescription)
        }
        
        request.addValue("application/json", forHTTPHeaderField: "content-type")
        
        URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            
            guard error == nil else {
                return
            }
            
            guard let data = data else {
                return
            }
            
            do {

                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                    
                    if let token = json["access_token"] as? String {
                        
                        self.accessToken = token
                        print(self.accessToken)
                        
                        let userDefaults = UserDefaults.standard
                        
                        userDefaults.set(token, forKey: "accessToken")
                        
                    }
                }
            } catch let error {
                print(error.localizedDescription)
            }
        }).resume()
    }
    
    func getProductsList(page: Int) {
        
        var totalProducts = [Product]()
        
        let url = URL(string: "http://api.igoodtravel.com/buy/topics?api_version=\(apiVersion)&key=\(apiKey)&type_simplified_id=\(typeSimplifiedId)&page=\(page)")!
        let request = URLRequest(url: url)
        
        URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            
            guard error == nil else {
                return
            }
            
            guard let data = data else {
                return
            }
            
            do {
                
                if let products = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [[String: Any]] {
                    
                    for product in products {
                        
                        guard let id = product["id"] as? Int else { break }
                        
                        guard let companyName = product["company_name"] as? String else { break }
                        
                        guard let title = product["title"] as? String else { break }
                        
                        guard let salesCount = product["sales_count"] as? Int else { break }
                        
                        guard let price = product["price"] as? Double else { break }
                        
                        guard let storeName = product["store_name"] as? String? else { break }
                        
                        guard let content = product["content"] as? String else { break }
                        
                        guard let link = product["link"] as? String else { break }
                        
                        guard let imageUrl = product["image"] as? String else { break }
                        
                        guard let imageSmallUrl = product["image_small"] as? String else { break }
                        
                        guard let imageOriginalUrl = product["image_original"] as? String else { break }
                        
                        guard let addresses = product["addresses"] as? [[String: Any]] else { break }
                        
                        totalProducts.append(Product(id: id,
                                                        companyName: companyName,
                                                        title: title,
                                                        salesCount: salesCount,
                                                        price: price,
                                                        storeName: storeName,
                                                        content: content,
                                                        link: link,
                                                        imageUrl: imageUrl,
                                                        imageSmallUrl: imageSmallUrl,
                                                        imageOriginalUrl: imageOriginalUrl,
                                                        address: addresses))
                    }
                    
                    self.delegateProducts?.didGet(totalProducts)
                }
            } catch let error {
                print(error.localizedDescription)
            }
        }).resume()
        
    }
    
    func getProduct(_ id: Int) {
        
        var singleProduct: Product?
        
        guard let url = URL(string: "http://api.igoodtravel.com/buy/topics/\(id)?api_version=\(apiVersion)&key=\(apiKey)") else { return }
        
        let request = URLRequest(url: url)
        
        URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            
            guard error == nil else {
                return
            }
            
            guard let data = data else {
                return
            }
            
            do {
                
                if let product = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                        
                        let id = product["id"] as! Int
                        
                        let companyName = product["company_name"] as! String
                        
                        let title = product["title"] as! String
                        
                        let salesCount = product["sales_count"] as! Int
                        
                        let price = product["price"] as! Double
                        
                        let storeName = product["store_name"] as! String?
                        
                        let content = product["content"] as! String
                        
                        let link = product["link"] as! String
                        
                        let imageUrl = product["image"] as! String
                        
                        let imageSmallUrl = product["image_small"] as! String
                        
                        let imageOriginalUrl = product["image_original"] as! String
                        
                        let addresses = product["addresses"] as! [[String: Any]]
                        
                        singleProduct = Product(id: id,
                                                companyName: companyName,
                                                title: title,
                                                salesCount: salesCount,
                                                price: price,
                                                storeName: storeName,
                                                content: content,
                                                link: link,
                                                imageUrl: imageUrl,
                                                imageSmallUrl: imageSmallUrl,
                                                imageOriginalUrl: imageOriginalUrl,
                                                address: addresses)
                    
                        self.delegateProduct?.didGet(singleProduct!)
                }
            } catch let error {
                print(error.localizedDescription)
            }
        }).resume()
        
    }
    
    func addToFavoriteList(_ id: Int) {

        guard let url = URL(string: "http://api.igoodtravel.com/buy/notes?topic_id=\(id)&key=\(apiKey)") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let token = UserDefaults.standard.string(forKey: "accessToken")!
        
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            
            guard error == nil else { return }
            
            guard let data = data else { return }
            
        }).resume()
    }
    
    func deleteFromFavoriteList(_ id: Int) {
        
        guard let url = URL(string: "http://api.igoodtravel.com/buy/notes?topic_id=\(id)&key=\(apiKey)") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        let token = UserDefaults.standard.string(forKey: "accessToken")!
        
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            
            guard error == nil else { return }
            
            guard let data = data else { return }
            
        }).resume()
    }
    
    func getFavoriteList(page: Int) {
        
        var favoriteProducts = [Product]()
        
        guard let url = URL(string: "http://api.igoodtravel.com/buy/notes/index_of_topic?api_version=\(apiVersion)&key=\(apiKey)&page=\(page)") else { return }
        
        var request = URLRequest(url: url)
        
        let token = UserDefaults.standard.object(forKey: "accessToken") as! String
        print(token)
        request.allHTTPHeaderFields = ["Authorization": "Bearer \(token)"]
        
        URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            
            guard error == nil else { return }
            
            guard let data = data else { return }

            do {

                if let products = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [[String: Any]] {

                    for product in products {

                        guard let id = product["id"] as? Int else { return }

                        guard let companyName = product["company_name"] as? String else { return }

                        guard let title = product["title"] as? String else { return }

                        guard let salesCount = product["sales_count"] as? Int else { return }

                        guard let price = product["price"] as? Double else { return }

                        guard let storeName = product["store_name"] as? String? else { return }

                        guard let content = product["content"] as? String else { return }

                        guard let link = product["link"] as? String else { return }

                        guard let imageUrl = product["image"] as? String else { return }

                        guard let imageSmallUrl = product["image_small"] as? String else { return }

                        guard let imageOriginalUrl = product["image_original"] as? String else { return }

                        guard let addresses = product["addresses"] as? [[String: Any]] else { return }

                        favoriteProducts.append(Product(id: id,
                                                     companyName: companyName,
                                                     title: title,
                                                     salesCount: salesCount,
                                                     price: price,
                                                     storeName: storeName,
                                                     content: content,
                                                     link: link,
                                                     imageUrl: imageUrl,
                                                     imageSmallUrl: imageSmallUrl,
                                                     imageOriginalUrl: imageOriginalUrl,
                                                     address: addresses))
                    }
                        self.delegateProducts?.didGet(favoriteProducts)
                    
                }
            } catch let error {
                print(error.localizedDescription)
            }
        }).resume()
        
    }
    
}
