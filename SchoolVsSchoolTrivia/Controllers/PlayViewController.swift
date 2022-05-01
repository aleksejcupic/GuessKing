//
//  PlayViewController.swift
//  SchoolVsSchoolTrivia
//
//  Created by Aleksej Cupic on 4/29/22.
//

import UIKit
import AVFoundation
import Firebase

class PlayViewController: UIViewController {
    // word being revleaded label?
    @IBOutlet weak var guessedLetterTextField: UITextField!
    @IBOutlet weak var guessLetterButton: UIButton!
    @IBOutlet weak var revealImageView: UIImageView!
    @IBOutlet weak var wordBeingRevealedLabel: UILabel!
    @IBOutlet weak var playAgainButton: UIButton!
    @IBOutlet weak var gameStatusMessageLabel: UILabel!
    
    let user = AppUser()
//    var db: Firestore!
    var users = AppUsers()

    var wordsToGuess: [String] = ["ALEKSEJ"]
    var urlString = "https://random-word-api.herokuapp.com/word?length=5"
    var wordToGuess = ""
    
    var currentWordIndex = 0
    var lettersGuessed = ""
    var guessCount = 0
    var audioPlayer: AVAudioPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getData()
        let text = guessedLetterTextField.text!
        guessLetterButton.isEnabled = !(text.isEmpty)
        wordToGuess = wordsToGuess[currentWordIndex]
    }
    
    func getData() {
        print("accessing: \(urlString)")
        var words = [""]
        guard let url = URL(string: self.urlString) else  {
            print("ERROR: could not create URL from \(self.urlString)")
            return
        }
        let session = URLSession.shared
        let task = session.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("ERROR: \(error.localizedDescription)")
            }
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: [])
                words = json as! [String]
                self.wordsToGuess = words
                print(self.wordsToGuess)
            } catch {
                print("ERROR: JSON ERROR \(error.localizedDescription)")
            }
        }
        task.resume()
        return
    }
    
    func updateUIAfterGuess() {
        // dismisses the keyboard
        guessedLetterTextField.resignFirstResponder()
        guessedLetterTextField.text! = ""
        guessLetterButton.isEnabled = false
    }
    
    func formatRevealedWord() {
        // format and show revealedWord in wordBeingRevealedLabel to include new guess
        var revealedWord = ""
        
        // loops through all letters in wordToGuess
        for letter in wordToGuess {
            // check if letter in wordToGuess is in lettersGuessed
            if lettersGuessed.contains(letter) {
                // if so, add this letter + blank to revealedWord
                revealedWord = revealedWord + "\(letter) "
            } else {
                // if not, add an _ + blank to revealedWord
                revealedWord = revealedWord + "_ "
            }
        }
        //     remove the extra space at the end of revealedWord
        revealedWord.removeLast()
        wordBeingRevealedLabel.text = revealedWord
    }
    
    func updateAfterWin() {
        getData()
        users.loadWin(guessCount: guessCount)
        self.guessedLetterTextField.isEnabled = false
        self.guessLetterButton.isEnabled = false
        self.playAgainButton.isHidden = false
    }
    
    func drawFlowerAndPlaySound(currentLetterGuessed: String) {
        // update image if needed and keep track of wrong guesses
        if wordToGuess.contains(currentLetterGuessed) == false {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { [self] in
                UIView.transition(with: self.revealImageView, duration: 0.5, options: .transitionCrossDissolve, animations: {self.revealImageView.image = UIImage(named: "wilt\(8)")})
                { (_) in
                    if self.guessCount != 0 {
                        self.revealImageView.image = UIImage(named: "flower\(5)")
                    } else {
                        self.playSound(name: "word-not-guessed")
                        UIView.transition(with: self.revealImageView, duration: 0.5, options: .transitionCrossDissolve, animations: {                        self.revealImageView.image = UIImage(named: "flower\(self.guessCount)")}, completion: nil)
                    }
                }
                self.playSound(name: "incorrect")
            }
        } else {
            playSound(name: "correct")
        }
    }
    
    func guessALetter() {
        // get current letter guessed and add it to all letters guessed
        let currentLetterGuessed = guessedLetterTextField.text!
        lettersGuessed = lettersGuessed + currentLetterGuessed
        formatRevealedWord()
        drawFlowerAndPlaySound(currentLetterGuessed: currentLetterGuessed)
        // update gameStatusMessageLabel
        guessCount += 1
        let guesses = (guessCount == 1 ? "Guess" : "Guesses")
        gameStatusMessageLabel.text = "You've Made \(guessCount) \(guesses)"
        if wordBeingRevealedLabel.text!.contains("_") == false {
            gameStatusMessageLabel.text = "You've guessed it! It took you \(guessCount) guesses to guess the word."
            playSound(name: "word-guessed")
            updateAfterWin()
        }
    }
    
    func playSound(name: String) {
        if let sound = NSDataAsset(name: name) {
            do {
                try audioPlayer = AVAudioPlayer(data: sound.data)
                audioPlayer.play()
            } catch {
                print("error: \(error.localizedDescription). Could not initializae AVAudioPlayer object")
            }
        } else {
            print("error: could not read data from \(name)")
        }
    }
    
    func play() {
        playAgainButton.isHidden = true
        getData()
        guessedLetterTextField.isEnabled = true
        guessLetterButton.isEnabled = false // dont turn true until char in text field
        wordToGuess = wordsToGuess[currentWordIndex]
        // create word with underscores, one of each space
        wordBeingRevealedLabel.text = "_" + String(repeating: " _", count: wordToGuess.count - 1)
        guessCount = 0
        revealImageView.image = UIImage(named: "flower\(8)")
        lettersGuessed = ""
        gameStatusMessageLabel.text = "You've Made Zero Guesses"
    }
    
    @IBAction func guessedLetterFieldChanged(_ sender: UITextField) {
        sender.text = String(sender.text?.last ?? " ").trimmingCharacters(in: .whitespaces).uppercased()
        guessLetterButton.isEnabled = !(sender.text!.isEmpty)
    }
    
    @IBAction func guessLetterButtonPressed(_ sender: UIButton) {
        guessALetter()
        updateUIAfterGuess()
    }
    
    @IBAction func doneKeyPressed(_ sender: UITextField) {
        guessALetter()
        updateUIAfterGuess()
    }
    
    @IBAction func playAgainButtonPressed(_ sender: UIButton) {
        play()
    }
}
