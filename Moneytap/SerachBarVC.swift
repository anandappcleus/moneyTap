//
//  SerachBarVC.swift
//  Moneytap
//
//  Created by NexGenTech on 23/06/18.
//  Copyright © 2018 Anand. All rights reserved.
//

import UIKit

class SerachBarVC: UIViewController,UISearchBarDelegate,UITableViewDataSource,UITableViewDelegate {
    
  
    @IBOutlet weak var SearchBar: UISearchBar!
    
    @IBOutlet weak var backButton: UIBarButtonItem!
    
    @IBOutlet weak var searchResultsTableView: UITableView!
    
   
    var searchResults = [[String:Any]]()
    {
        didSet
        {
            DispatchQueue.main.async(execute: { () -> Void in
                self.searchResultsTableView.reloadData()
            })
            
        }
    }

    override func viewDidLoad()
    {
        super.viewDidLoad()
        //Changing Search bar Text color
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).textColor = UIColor.gray
        self.SearchBar.tintColor = UIColor.darkGray
        searchResultsTableView.tableFooterView = UIView(frame: CGRect.zero)
        self.searchResultsTableView.isHidden = true

        
    }
    
    
    
    
    @IBAction func backButtonAction(_ sender: UIBarButtonItem) {
        
        _ = self.navigationController?.popViewController(animated: true)
    }
    @IBAction func closeButtonAction(_ sender: UIButton)
    {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: Search Bar Delegate Method

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
    {
        if searchText.characters.count >= 3
        {
           loadSearchData(searchText)
            self.searchResultsTableView.isHidden = false

        }
        else
        {
            self.searchResults = []
            self.searchResultsTableView.isHidden = true

        }
    }
    
    func loadSearchData(_ query:String)
    {
        let urlString = "https://en.wikipedia.org/w/api.php?action=query&formatversion=2&prop=pageimages&prop=pageimages%7Cpageterms&titles=\(query.replacingOccurrences(of: " ", with: "+"))&format=json&pilimit=20"

        
        let url = URL(string: urlString)
        var request = URLRequest(url: url!)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with:request) { (data, response, error) in
            if error != nil {
                print(error)
            } else {
                do {
                    
                    let parsedDictionaryArray = try JSONSerialization.jsonObject(with: data!) as? [String:AnyObject]
                    
                    if let query = parsedDictionaryArray!["query"] as?[String:AnyObject]
                    {
                        if let pages = query["pages"] as? [[String : Any]]
                        {
                            self.searchResults = pages
                        }
                        
                    }
                   
                } catch let error as NSError {
                    print(error)
                }
            }
            
            }.resume()
    }
    
    //MARK: UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchResultCell") as? SearchResultCell
        
         cell?.title.text = self.searchResults[indexPath.row]["title"] as? String
            if let terms =  self.searchResults[indexPath.row]["terms"] as? [String:Any]
            {
                if let description = terms["description"] as? [String]
                {
                    cell?.value.text = description.first
                }
                
            }
        if let thumbnail =  self.searchResults[indexPath.row]["thumbnail"] as? [String:Any]
        {
            if let source = thumbnail["source"] as? String
            {
                let url = URL(string: source)
                
                DispatchQueue.global().async {
                    let data = try? Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
                    DispatchQueue.main.async {
                        cell?.thumbnail.image = UIImage(data: data!)
                    }
                }
            }
            
        }
        
        
        return cell!
    }
    
    //MARK: UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        self.SearchBar.resignFirstResponder()
        
    }
    
    
}




