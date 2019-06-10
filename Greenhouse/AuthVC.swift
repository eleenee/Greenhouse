import Foundation
import UIKit

class AuthVC: UIViewController {
    
    @IBOutlet weak var usernameTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    
    @IBOutlet weak var connectButton: UIButton!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        connectButton.layer.cornerRadius = 5
        connectButton.clipsToBounds = true
        
        passwordTF.isSecureTextEntry = true
    }
    
    @IBAction func connectButtonPressed(_ sender: Any) {
        
        if let username = usernameTF.text,
           let password = passwordTF.text,
           !username.isEmpty && !password.isEmpty {
           
            let mqtt = MQTTManager.shared
            mqtt.mqttConnectWith(username: username, password: password) { returnCode in
                
                if returnCode == 0 {
                    _ = UIStoryboardSegue(identifier: "authOK", source: AuthVC(), destination: InfoVC())
                    self.performSegue(withIdentifier: "authOK", sender: self)
                    
                } else {
                    mqtt.disconnect()
                    let alert = UIAlertController(title: "Ошибка", message: "Проверьте логин/пароль", preferredStyle: .alert)
                    let action = UIAlertAction(title: "ОК", style: .default, handler: nil)
                    alert.addAction(action)
                    self.present(alert, animated: true, completion: nil)
                }
            }
            
//            if !status {
//                
//                let alert = UIAlertController(title: "Ошибка", message: "Проверьте логин/пароль", preferredStyle: .alert)
//                let action = UIAlertAction(title: "ОК", style: .default, handler: nil)
//                alert.addAction(action)
//                self.present(alert, animated: true, completion: nil)
//                
//            } else {
//                self.performSegue(withIdentifier: "authOK", sender: self)
//            }
            
        } else {
            
            let alert = UIAlertController(title: "Ошибка", message: "Заполните логин и пароль", preferredStyle: .alert)
            let action = UIAlertAction(title: "ОК", style: .default, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
//    public func connectSuccesfull() {
//        self.performSegue(withIdentifier: "authOK", sender: self)
//    }
    
//    public func errorAlert() {
//        let alert = UIAlertController(title: "Ошибка", message: "Заполните логин и пароль", preferredStyle: .alert)
//        let action = UIAlertAction(title: "ОК", style: .default, handler: nil)
//        alert.addAction(action)
//        self.present(alert, animated: true, completion: nil)
//    }
}
