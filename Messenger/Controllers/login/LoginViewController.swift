//
//  LoginViewController.swift
//  Messenger
//
//  Created by Perennial Systems on 14/02/22.
//

import UIKit
import FirebaseAuth
import FBSDKLoginKit



class LoginViewController: UIViewController {
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "logo")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let emailFields: UITextField = {
        let field = UITextField()
        field.autocapitalizationType =  .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Email Address.."
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        return field
    }()
    
    private let passwordField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType =  .none
        field.autocorrectionType = .no
        field.returnKeyType = .done
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Password.."
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        field.isSecureTextEntry = true
        return field
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton()
        button.setTitle("Log In", for: .normal)
        button.backgroundColor = .link
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        return button
    }()
    
    private let fbLoginButton : FBLoginButton = {
        let button = FBLoginButton()
        button.permissions = ["public_profile", "email"]
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Log In"
        view.backgroundColor = .white
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Register", style: .done, target: self, action: #selector(didTapRegister))
        
        
        
        loginButton.addTarget(self, action: #selector(loginButtontapped), for: .touchUpInside)
        
        emailFields.delegate = self
        passwordField.delegate = self
        fbLoginButton.delegate = self
        
        // adding subviews
        
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(emailFields)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(loginButton)
        scrollView.addSubview(fbLoginButton)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        let size = scrollView.width/4
        imageView.frame = CGRect(x:
                                    (scrollView.width-size)/2,
                                 y: 40,
                                 width: size,
                                 height: size)
        emailFields.frame = CGRect(x: 30,
                                   y: imageView.bottom+30,
                                   width: scrollView.width-60,
                                   height: 52)
        passwordField.frame = CGRect(x: 30,
                                     y: emailFields.bottom+20,
                                     width: scrollView.width-60,
                                     height: 52)
        loginButton.frame = CGRect(x: 30,
                                   y: passwordField.bottom+10,
                                   width: scrollView.width-60,
                                   height: 52)
        
        fbLoginButton.frame = CGRect(x: 30,
                                     y: loginButton.bottom+10,
                                     width: scrollView.width-60,
                                     height: 52)
        fbLoginButton.frame.origin.y = loginButton.bottom+30
        
    }
    
    
    @objc private func loginButtontapped(){
        
        emailFields.resignFirstResponder()
        passwordField.resignFirstResponder()
        
        guard let email = emailFields.text , let password = passwordField.text,
              !email.isEmpty, !password.isEmpty , password.count >= 5 else {
                  alertUserLoginError()
                  return
              }
        
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password, completion: {[weak self ] authResults , error in
            guard let strongSelf = self else {
                return
            }
            guard let results = authResults , error == nil else {
                print("Failed to login \(email)")
                return
            }
            let user = results.user
            print("Logged In \(user)")
            strongSelf.navigationController?.dismiss(animated: true, completion: nil)
            
        })
    }
    func alertUserLoginError(){
        let alert = UIAlertController(title: "Woops", message: "Pls enter all info to login", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        present(alert, animated: true)    }
    
    @objc private func didTapRegister() {
        
        let vc = RegisterViewController()
        vc.title = "Create Account "
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension LoginViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailFields {
            passwordField.becomeFirstResponder()
        }
        else if textField ==  passwordField {
            loginButtontapped()
        }
        return true
    }
}

extension LoginViewController : LoginButtonDelegate{
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        // no Operations
    }
    
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        guard let token = result?.token?.tokenString else {
            print("User failed to login with FaceBook")
            return
        }
        
        let facebookRequest = FBSDKLoginKit.GraphRequest(graphPath: "me", parameters: ["fields": "email , name"], tokenString: token, version: nil, httpMethod: .get)
        
        facebookRequest.start(completion: { _ , result, error in
            
            guard let result = result as? [String: Any] , error == nil else {
                
                print("failed to make facebook graph request")
                return
            }
            print ("\(result)")
            
            guard let userName = result["name"] as? String,
                    let email = result["email"] as? String else {
                        print("Failed to get email and name from fb")
                        return
                    }
            let nameComponents = userName.components(separatedBy: " ")
            guard nameComponents.count == 2 else {
                return
            }
            let firstName = nameComponents[0]
            let lastName = nameComponents[1]
            
            DatabaseManager.shared.userExists(with: email, completion:{exists in
                if !exists {
                    
                    DatabaseManager.shared.insertUser(with: ChatAppUser(firstName: firstName, lastName: lastName, emailAddress: email))
                }
                
            })
            
            let credential = FacebookAuthProvider.credential(withAccessToken:   token)
            FirebaseAuth.Auth.auth().signIn(with: credential, completion: {[weak self ] authResult , error in
                
                guard let strongSelf = self else {
                    return
                }
                guard  authResult != nil, error == nil else {
                    if let error = error{
                        print("Facebook  credentials login failed, MFA may be needed - \(error)")
                    }
                    
                    return
                }
                
                print("Successfully logged in ")
                
                strongSelf.navigationController?.dismiss(animated:true,completion:nil)
                
            })
        })
      
        
    }
    
    
}
