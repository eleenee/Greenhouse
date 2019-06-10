import UIKit

class InfoVC: UIViewController {
    
    let subscribedTopics = [MQTTInfo.Topics.outTemperature, MQTTInfo.Topics.outPressure, MQTTInfo.Topics.inTemperature, MQTTInfo.Topics.inHumidity]
    
    @IBOutlet weak var outTemperature: UILabel!
    @IBOutlet weak var outPressure: UILabel!
    
    @IBOutlet weak var inTemperature: UILabel!
    @IBOutlet weak var inHumidity: UILabel!
    
    @IBOutlet weak var lightSwitcher: UISwitch!
    
    //var state = GreenhouseState.shared
    var greenhouse = GreenhouseState()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for topic in subscribedTopics {
            NotificationCenter.default.addObserver(self, selector: #selector(notificationReceived(_:)), name: NSNotification.Name(rawValue: topic), object: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
//        self.outTemperature.text = GreenhouseState.shared.getOutTemperature()
//        self.outPressure.text = GreenhouseState.shared.getOutPressure()
//        self.inTemperature.text = GreenhouseState.shared.getInTemperature()
//        self.inHumidity.text = GreenhouseState.shared.getInHumidity()
//        self.lightSwitcher.setOn(GreenhouseState.shared.isLight(), animated: true)
        
        self.outTemperature.text = greenhouse.getOutTemperature()
        self.outPressure.text = greenhouse.getOutPressure()
        self.inTemperature.text = greenhouse.getInTemperature()
        self.inHumidity.text = greenhouse.getInHumidity()
        self.lightSwitcher.setOn(greenhouse.isLight(), animated: true)
    }
    
//    func updateOutTemperature() {
//        self.outTemperature.text = greenhouse.getOutTemperature()
//    }
    
   
    @IBAction func lightOn(_ sender: Any) {
        if lightSwitcher.isOn {
            MQTTManager.shared.publishMessage(topic: MQTTInfo.Topics.inIsLight, message: "1")
        } else {
            MQTTManager.shared.publishMessage(topic: MQTTInfo.Topics.inIsLight, message: "0")
        }
    }

    @objc func notificationReceived(_ notification: NSNotification) {
        
        if let topic = notification.userInfo?["topic"] as? String {
            
            switch topic {
                
            case MQTTInfo.Topics.outTemperature :
                self.outTemperature.text = notification.userInfo?["message"] as! String
                
            case MQTTInfo.Topics.outPressure:
                self.outPressure.text = notification.userInfo?["message"] as! String
                
            case MQTTInfo.Topics.inTemperature:
                self.inTemperature.text = notification.userInfo?["message"] as! String
                
            case MQTTInfo.Topics.inHumidity:
                self.inHumidity.text = notification.userInfo?["message"] as! String
            
            default:
                break
            }
        }
    }
        
}
