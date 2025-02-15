//
//  ViewController3.swift
//  IncidentTableView
//
//  Created by Tiger Coder on 1/26/21.
//

import UIKit
import Firebase

class ViewController3: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var titleOutlet: UILabel!
    @IBOutlet weak var tableview: UITableView!
    
    var ind: IndexPath!
    var tableList: [Incident] = []
    
    var defaults = UserDefaults.standard
    var currentIncidentKey = "DemoIncident"
    let db = Firestore.firestore()
    var infoListener: ListenerRegistration!
    
    var incType: String = ""
    var clickedIncident = Incident(inc: .other)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleOutlet.text = "Additional Information \n Incident: \(incType)"
        
        tableview.delegate = self
        tableview.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if let sesh = defaults.object(forKey: "currentIncidentKey") as? String {
            currentIncidentKey = sesh
            print(currentIncidentKey)
        }
        
        infoListener = db.collection("incidents").document(currentIncidentKey).collection("subInformation").addSnapshotListener { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                
                self.tableList = []
                
                for document in querySnapshot!.documents {
                    // print("\(document.documentID) => \(document.data())")
                    
                    let incidentMade = Incident(inc: .other)
                    incidentMade.key = document.documentID
                    
                    // Temporary Debug Statement: Prints each map coordinate in the console.s
                    // print("Incident (\(document.documentID) - PointX: \(incidentMade.pointx ?? 0), PointY: \(incidentMade.pointy ?? 0)")
                    
                    var returnInfo = ""
                    for dt in document.data() {
                        if dt.key == "info" {
                            returnInfo = dt.value as? String ?? "Info receive error."
                            incidentMade.info = returnInfo
                        }
                        if dt.key == "location" {
                            returnInfo = dt.value as? String ?? "Location receive error."
                            incidentMade.location = returnInfo
                        }
                        if dt.key == "pointx" {
                            incidentMade.pointx = dt.value as? CGFloat
                        }
                        if dt.key == "pointy" {
                            incidentMade.pointy = dt.value as? CGFloat
                        }
                        if dt.key == "time" {
                            incidentMade.timeCreated = dt.value as? Timestamp
                            
                            let formatter = DateFormatter()
                            formatter.dateFormat = "HH:mm"
                            
                            let convertTime = formatter.string(from: incidentMade.timeCreated!.dateValue())
                            
                            incidentMade.timeDisplay = convertTime
                        }
                    }
                    
                    // print(returnList)
                    
                    self.tableList.append(incidentMade)
                }
            }
            // print(self.tableList.count)
            
            self.tableList.sort(by: {$0.timeCreated!.dateValue() > $1.timeCreated!.dateValue()} )
            self.tableview.reloadData()
        }
    }
    
    func alert() {
        
        let alert = UIAlertController(title: "Oops!", message: "Looks like you already have this item.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: { _ in
            //Cancel Action
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        infoListener.remove()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableview.dequeueReusableCell(withIdentifier: "myCell") as! CustomCell2
        
        //incident.location & incident.info for the parameters 
        cell.configure(room: tableList[indexPath.row].location ?? "N/A", addInfo: tableList[indexPath.row].info ?? "No info to display.")
        
        // print(tableList[indexPath.row].location ?? "no")
        // print(tableList[indexPath.row].info ?? "no info")
        
        return cell
    }
    
    @IBAction func next(_ sender: UIButton) {
        ViewController4.fromAddInfo = true
        performSegue(withIdentifier: "next", sender: nil)
    }
    
    @IBAction func unwindVC3(_ seg: UIStoryboardSegue ) {
    }
    
    
}
