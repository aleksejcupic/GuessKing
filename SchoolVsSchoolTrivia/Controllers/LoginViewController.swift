//
//  ViewController.swift
//  SchoolVsSchoolTrivia
//
//  Created by Aleksej Cupic on 4/27/22.
//

import UIKit
import FirebaseAuthUI
import FirebaseGoogleAuthUI

class LoginViewController: UIViewController {
    
    var authUI: FUIAuth!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        authUI = FUIAuth.defaultAuthUI()
        // You need to adopt a FUIAuthDelegate protocol to receive callback
        authUI.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        signIn()
    }
    
    func signIn() {
        // note FUIGoogleAuth line was previously: FUIGoogleAuth(), Google changed to line below in latest update
        let providers: [FUIAuthProvider] = [
            FUIGoogleAuth(authUI: authUI!),
        ]
        if authUI.auth?.currentUser == nil { // user has not signed in
            self.authUI.providers = providers // show providers named after let providers: above
            let loginViewController = authUI.authViewController()
            loginViewController.modalPresentationStyle = .fullScreen
            present(loginViewController, animated: true, completion: nil)
        } else { // user is already logged in
            performSegue(withIdentifier: "FirstShowSegue", sender: nil)
        }
    }
    
    func signOut() {
        do {
            try authUI!.signOut()
        } catch {
            print("😡 ERROR: couldn't sign out")
            performSegue(withIdentifier: "FirstShowSegue", sender: nil)
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        // Trait collection has already changed
    }

    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        // Trait collection will change. Use this one so you know what the state is changing to.
    }
    
    @IBAction func unwindSignOutPressed(segue: UIStoryboardSegue) {
        if segue.identifier == "SignOutUnwind" {
            signOut()
        }
    }
}

extension LoginViewController: FUIAuthDelegate {
    func authPickerViewController(forAuthUI authUI: FUIAuth) -> FUIAuthPickerViewController {
        let marginInsets: CGFloat = 16.0 // amount to indent UIImageView on each side
        let topSafeArea = self.view.safeAreaInsets.top
        
        // Create an instance of the FirebaseAuth login view controller
        let loginViewController = FUIAuthPickerViewController(authUI: authUI)
        
        if self.traitCollection.userInterfaceStyle == .dark {
            // user has dark mode enabled - set background color to black
            loginViewController.view.backgroundColor = UIColor.black
            loginViewController.view.subviews[0].backgroundColor = UIColor.black
            loginViewController.view.subviews[0].subviews[0].backgroundColor = UIColor.black
        } else {
            // user has light mode enabled - set background color to white
            loginViewController.view.backgroundColor = UIColor.white
            loginViewController.view.subviews[0].backgroundColor = UIColor.clear
            loginViewController.view.subviews[0].subviews[0].backgroundColor = UIColor.clear
        }

        // Create a frame for a UIImageView to hold our logo
        let x = marginInsets
        let y = marginInsets + topSafeArea
        let width = self.view.frame.width - (marginInsets * 2)
        // let height = loginViewController.view.subviews[0].frame.height - (topSafeArea) - (marginInsets * 2)
        let height = UIScreen.main.bounds.height - (topSafeArea) - (marginInsets * 2)
        
        let logoFrame = CGRect(x: x, y: y, width: width, height: height)
        
        // Create the UIImageView using the frame created above & add the "logo" image
        let logoImageView = UIImageView(frame: logoFrame)
        if self.traitCollection.userInterfaceStyle == .dark {
            // user has dark mode enabled
            logoImageView.image = UIImage(named: "logo_dark_mode")
        } else {
            // user has light mode enabled
            logoImageView.image = UIImage(named: "logo_light_mode")
        }
        // logoImageView.image = UIImage(named: "logo")
        logoImageView.contentMode = .scaleAspectFit // Set imageView to Aspect Fit
        loginViewController.view.addSubview(logoImageView) // Add ImageView to the login controller's main view
        return loginViewController
    }
}
