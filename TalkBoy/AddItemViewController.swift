//
//  AddItemViewController.swift
//  TalkBoy
//
//  Created by Ryan Miller on 4/12/18.
//  Copyright © 2018 Ryan Miller. All rights reserved.
//

import UIKit
//import AVFoundation library with audiovisual functions
import AVFoundation

class AddItemViewController: UIViewController {

    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var nameTextField: UITextField!
    
    //initialize audio recorder and player to be used in functions below
    var audioRecorder : AVAudioRecorder?
    var audioPlayer : AVAudioPlayer?
    //initialize empty NSURL
    var audioURL : URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //create Audio Session (says we're going to be recording audio, has settings etc.)
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(AVAudioSessionCategoryPlayAndRecord)
        try? session.overrideOutputAudioPort(.speaker)
        try? session.setActive(true)
        
        //create URL to save the audio (this is a local URL, not internet) with path components
        if let basePath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first {
            let pathComponents = [basePath, "audio.m4a"]
            if let audioURL = NSURL.fileURL(withPathComponents: pathComponents) {
                
                self.audioURL = audioURL
                //create some settings
                var settings : [String:Any] = [:] //make an empty dictionary
                settings[AVFormatIDKey] = Int(kAudioFormatMPEG4AAC)
                settings[AVSampleRateKey] = 44100.0
                settings[AVNumberOfChannelsKey] = 2
                
                //create the Audio Recorder, references "dictionaries" in [String: Any].
                audioRecorder = try? AVAudioRecorder(url: audioURL, settings: settings)
                //get audio recorder ready to record
                audioRecorder?.prepareToRecord()
            }
        }
        //disable/gray out buttons before recording is made
        playButton.isEnabled = false
        nameTextField.isEnabled = false
        addButton.isEnabled = false
        
    }

    @IBAction func recordTapped(_ sender: Any) {
        
        if let audioRecorder = self.audioRecorder { //unwrap audioRecorder by assigning to local variable of same name within function (you can have same name bc it is local)
            //stop recording if already recording, and start recording if not
            if audioRecorder.isRecording {
                audioRecorder.stop()
                recordButton.setTitle("Record", for: .normal) //change button to say Record. Set control state to ".normal"
                //enable play, title, and add buttons after recording is made
                playButton.isEnabled = true
                nameTextField.isEnabled = true
                addButton.isEnabled = true
            } else {
                audioRecorder.record()
                recordButton.setTitle("Stop", for: .normal)
                //disable play, title, and add buttons during a recording
                playButton.isEnabled = false
                nameTextField.isEnabled = false
                addButton.isEnabled = false
            }
            
        }
        
    }

    @IBAction func playTapped(_ sender: Any) {
        //pass URL for sound file to audio player
        if let audioURL = self.audioURL{
            audioPlayer = try? AVAudioPlayer(contentsOf: audioURL)
            audioPlayer?.play()
        }
    }
    
    @IBAction func addTapped(_ sender: Any) {
        //get generic access to core data context
        if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
            //pass data to a Sound entity in core data for storage
            let sound = Sound(entity: Sound.entity(), insertInto: context)
            sound.name = nameTextField.text
            if let audioURL = self.audioURL{ //have to unwrap audioURL
                sound.audioData = try? Data(contentsOf: audioURL)
                //save context
                try? context.save()
                //return to previous view controller
                navigationController?.popViewController(animated: true)
            }
        }
    }
}
