//
//  ItemTableViewController.swift
//  TalkBoy
//
//  Created by Ryan Miller on 4/12/18.
//  Copyright © 2018 Ryan Miller. All rights reserved.
//

import UIKit
//also import AVFoundation for playback from table
import AVFoundation

class ItemTableViewController: UITableViewController {
    
    //initialize empty array of Sound entities
    var sounds : [Sound] = [];
    //initialize audio player for playback from table
    var audioPlayer : AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    //add function for calling getItems right before table appears
    override func viewWillAppear(_ animated: Bool) {
        getSounds()
    }
    
    //write function to get items out of core data
    func getSounds() {
        //get generic access to core data context
        if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
            //fetch data and return as array of Item objects -- however, this needs a "try?" with it, and since that returns an optional, need to unwrap with "if let"
            if let coreDataStuff = try? context.fetch(Sound.fetchRequest()) as? [Sound] {
                //need to unwrap coreDataStuff since it is itself an optional Array
                if let coreDataSounds = coreDataStuff {
                    //set array in viewcontroller equal to array from coredata
                    sounds = coreDataSounds
                    //reload data so items are seen in table
                    tableView.reloadData()
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return sounds.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //remember to copy identifier name "reuseIdentifier" to prototype cell identifier in storyboard attributes
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        //pull out item at this row
        let sound = sounds[indexPath.row]
        
        // Configure the cell...
        //get title
        cell.textLabel?.text = sound.name

        return cell
    }
    
    //add function for playing back selected sounds in table
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //pull out item at this row
        let sound = sounds[indexPath.row]
        //unwrap audioData and pass it to audio Player
        if let audioData = sound.audioData {
            audioPlayer = try? AVAudioPlayer(data: audioData)
            audioPlayer?.play()
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            //grab sound entity at this row
            let sound = sounds[indexPath.row]
            //get generic access to core data context
            if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
                //delete sound from core data context
                context.delete(sound)
                //rerun getSounds to refresh local array
                getSounds()
            }
        }
    }

}
