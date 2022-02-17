//
//  RegisterViewController.swift
//  Messenger
//
//  Created by Perennial Systems on 14/02/22.
//

import UIKit
import FirebaseAuth

class RegisterViewController: UIViewController {
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person.circle")
        imageView.tintColor = .gray
        imageView.contentMode = .scaleAspectFit
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UIColor.lightGray.cgColor
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
    
    private let firstName: UITextField = {
        let field = UITextField()
        field.autocapitalizationType =  .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "First Name"
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        return field
    }()
    
    private let lastName: UITextField = {
        let field = UITextField()
        field.autocapitalizationType =  .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Last Name"
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
    
    private let registerButton: UIButton = {
        let button = UIButton()
        button.setTitle("Register", for: .normal)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Register"
        view.backgroundColor = .white
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Register", style: .done, target: self, action: #selector(didTapRegister))
        
        
        
        registerButton.addTarget(self, action: #selector(registerButtontapped), for: .touchUpInside)
        
        emailFields.delegate = self
        passwordField.delegate = self
        
        // adding subviews
        
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(emailFields)
        scrollView.addSubview(firstName)
        scrollView.addSubview(lastName)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(registerButton)
        
        imageView.isUserInteractionEnabled = true
        scrollView.isUserInteractionEnabled = true
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapProfilePic))
        gesture.numberOfTapsRequired = 1
        gesture.numberOfTouchesRequired = 1
        
        imageView.addGestureRecognizer(gesture)
    }
    
    @objc private  func  didTapProfilePic(){
        print("change the pic")
        presentphotoActionSheet()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        let size = scrollView.width/3
        imageView.frame = CGRect(x:
                                    (scrollView.width-size)/2,
                                 y: 20,
                                 width: size,
                                 height: size)
        
        imageView.layer.cornerRadius    = imageView.width/2.0
        emailFields.frame = CGRect(x: 30,
                                   y: imageView.bottom+10,
                                   width: scrollView.width-60,
                                   height: 52)
        firstName.frame = CGRect(x: 30,
                                 y: emailFields.bottom+10,
                                 width: scrollView.width-60,
                                 height: 52)
        lastName.frame = CGRect(x: 30,
                                y: firstName.bottom+10,
                                width: scrollView.width-60,
                                height: 52)
        passwordField.frame = CGRect(x: 30,
                                     y: lastName.bottom+10,
                                     width: scrollView.width-60,
                                     height: 52)
        registerButton.frame = CGRect(x: 30,
                                      y: passwordField.bottom+10,
                                      width: scrollView.width-60,
                                      height: 52)
    }
    
    
    @objc private func registerButtontapped(){
        
        emailFields.resignFirstResponder()
        passwordField.resignFirstResponder()
        firstName.resignFirstResponder()
        lastName.resignFirstResponder()
        
        guard let email = emailFields.text ,let firstname = firstName.text , let lastname = lastName.text, let password = passwordField.text,
              !email.isEmpty,
              !firstname.isEmpty,
              !lastname.isEmpty,
              password.count >= 5 else {
                  alertUserLoginError()
                  return
              }
        
        // fireBase Login
        
        DatabaseManager.shared.userExists(with: email, completion: {[weak self]exists in
         
            guard let strongSelf = self else {
                return
            }
            guard !exists  else {
                // user already exists
                strongSelf.alertUserLoginError(message: "email already exits")
                return
            }
            FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password, completion: { authResults , error  in
                
               
                
                guard  authResults != nil, error == nil else {
                    print("Error createing user")
                    return
                }
                DatabaseManager.shared.insertUser(with: ChatAppUser(firstName: firstname,
                                                                    lastName: lastname,      emailAddress: email))
                
                strongSelf.navigationController?.dismiss(animated: true, completion: nil)

            })
            
        })
        
      
    }
    func alertUserLoginError(message: String = "please enter all info to register"){
        let alert = UIAlertController(title: "Woops", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        present(alert, animated: true)
        
    }
    
    @objc private func didTapRegister() {
        
        let vc = RegisterViewController()
        vc.title = "Crete Account "
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension RegisterViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailFields {
            passwordField.becomeFirstResponder()
        }
        else if textField ==  passwordField {
            registerButtontapped()
        }
        return true
    }
}

extension RegisterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func  presentphotoActionSheet(){
        let actionSheet = UIAlertController(title: "Profile Picture",
                                            message:" How would you like to select photo",
                                            preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Cancle",
                                            style: .cancel,
                                            handler: nil))
        actionSheet.addAction(UIAlertAction(title: "Take Photo",
                                            style: .default,
                                            handler: {[weak self]_ in
            
            self?.presentCamera()
        }))
        
        
        
        actionSheet.addAction(UIAlertAction(title: "Choose Photo",
                                            style: .default,
                                            handler:  {[weak self] _ in
            
            self?.presentPhotoPicker()

        }))
        
        present(actionSheet, animated: true)
        
    }
    
    func presentCamera(){
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.delegate = self
        vc.allowsEditing = true
        present(vc ,animated: true)
    }
    
    func presentPhotoPicker(){
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc ,animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        print(info)
        guard let  selectedImage =  info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        
        self.imageView.image = selectedImage

    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        picker.dismiss(animated: true, completion: nil)
    }
}
