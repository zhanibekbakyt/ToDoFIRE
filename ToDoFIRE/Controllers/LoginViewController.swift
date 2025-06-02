//
//  ViewController.swift
//  ToDoFIRE
//
//  Created by Zhanibek Bakyt on 05.02.2025.
//

import UIKit
import Firebase
import FirebaseAuth

class LoginViewController: UIViewController {
    
    var ref: DatabaseReference!
    
    @IBOutlet weak var warnLabel: UILabel!
    
    @IBOutlet var scrollView: UIScrollView!
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    func displayWarningLabel(withText text: String) {
        warnLabel.text = text
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.7, animations: { [weak self] in
            self?.warnLabel.alpha = 1
        }) { [weak self] complete in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                UIView.animate(withDuration: 0.5) {
                    self?.warnLabel.alpha = 0
                }
            }
        }
    }

    
    @IBAction func loginTapped(_ sender: UIButton) {
        guard let email = emailTextField.text, let password = passwordTextField.text, email != "", password != "" else {
            displayWarningLabel(withText: "Please enter email and password.")
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password, completion: { [weak self] (result, error) in
            if let error = error as NSError? {
                if let errorCode = AuthErrorCode(rawValue: error.code) {
                    switch errorCode {
                    case .invalidEmail:
                        self?.displayWarningLabel(withText: "Please enter a valid email address.")
                    case .wrongPassword:
                        self?.displayWarningLabel(withText: "Wrong password.")
                    case .userNotFound:
                        self?.displayWarningLabel(withText: "No user found with this email.")
                    default:
                        self?.displayWarningLabel(withText: error.localizedDescription)
                    }
                }
                return
            }
            
            self?.performSegue(withIdentifier: "tasksSegue", sender: nil)
        })
    }
    
    @IBAction func registerTapped(_ sender: UIButton) {
        guard let email = emailTextField.text, let password = passwordTextField.text, email != "", password != "" else {
            displayWarningLabel(withText: "Please enter email and password.")
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self = self else { return }
            
            if let error = error as NSError? {
                if let errorCode = AuthErrorCode(rawValue: error.code) {
                    switch errorCode {
                    case .invalidEmail:
                        self.displayWarningLabel(withText: "Please enter a valid email address.")
                    case .emailAlreadyInUse:
                        self.displayWarningLabel(withText: "This email is already registered.")
                    case .weakPassword:
                        self.displayWarningLabel(withText: "Password should be at least 6 characters.")
                    default:
                        self.displayWarningLabel(withText: error.localizedDescription)
                    }
                }
                return
            }
            
            if let user = authResult?.user {
                let userRef = self.ref.child(user.uid)
                userRef.setValue(["email": user.email])
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference(withPath: "users")
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        warnLabel.alpha = 0
        
        Auth.auth().addStateDidChangeListener({ [weak self] (auth, user) in
            if user != nil {
                self?.performSegue(withIdentifier: "tasksSegue", sender: nil)
            }
        })

    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }


}

