//
//  LMCatalogViewController.swift
//  LAVESHMUSIC
//
//  Created by Tony Wang on 1/4/19.
//  Copyright © 2019 Tony Wang. All rights reserved.
//

import UIKit
import JHSpinner
import Firebase
import SDWebImage

class LMCatalogViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tblViCatalog: UITableView!
    
    let sharedManager:Singleton = Singleton.sharedInstance
    var arrGenres = [LMGenre]()
    var selectedGenreId = "0"
    
    private let reuseIdentifier = "GenreCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        tblViCatalog.register(UINib(nibName: "GenreTableViewCell", bundle: nil), forCellReuseIdentifier: reuseIdentifier)
        
        for tabBarItem in (self.tabBarController?.tabBar.items!)!
        {
            tabBarItem.title = ""
            tabBarItem.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0)
        }
        
        self.loadGenres()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "showPlayer" {
            let viCtrlPlayer = segue.destination as! LMPlayerViewController
            viCtrlPlayer.genre_id = self.selectedGenreId
        }
    }
    
    
    // MARK: - Own Methods
    func loadGenres(){
        
        let spinner = JHSpinnerView.showOnView(view, spinnerColor:ColorPalette.laveshOrange, overlay:.roundedSquare, overlayColor:UIColor.darkGray.withAlphaComponent(0.8), text:nil)
        self.view.addSubview(spinner)
        
        let dbRef = Database.database().reference()
        dbRef.child("genres").observeSingleEvent(of: .value, with: { (snapshot) in
            spinner.dismiss()
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshots {
                    if let dicGenre = snap.value as? Dictionary<String, AnyObject> {
                        
                        let genre = LMGenre()
                        genre.setValues(withDictionary: dicGenre)
                        
                        self.arrGenres.append(genre)
                    }
                }
            }
            self.tblViCatalog.reloadData()
            
        }, withCancel: { (getUserInfoError) in
            spinner.dismiss()
            self.present(self.sharedManager.getErrorAlert(withError: getUserInfoError), animated: true, completion: nil)
        })
    }
    
    // MARK: - UITableView Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrGenres.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as? GenreTableViewCell
            else {
                return UITableViewCell()
        }
        
        let genre = self.arrGenres[indexPath.row]
        cell.lblTitle.text = genre.title.uppercased()
        cell.imgViBg.sd_setImage(with: genre.thumbImageURL, completed: nil)
                
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let genre = self.arrGenres[indexPath.row]
        self.selectedGenreId = genre.id
        performSegue(withIdentifier: "showPlayer", sender: tableView.cellForRow(at: indexPath))
    }
}
