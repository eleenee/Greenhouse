import Foundation
import Moscapsule

class MQTTManager {
    
    static let shared = MQTTManager()

    private var mqttClient: MQTTClient?
    
    private init() {
        moscapsule_init()
    }
    
    func mqttConnectWith(username: String, password: String, completion: @escaping (_ returnCode: Int) -> ()) {
        
        let mqttConfig = MQTTConfig(clientId: UIDevice.current.name, host: MQTTInfo.server.host, port: MQTTInfo.server.port, keepAlive: 300)
        
        mqttConfig.mqttAuthOpts = MQTTAuthOpts(username: username, password: password)
        mqttConfig.mqttReconnOpts = MQTTReconnOpts(delay: 1000000, max: 1, exponentialBackoff: false)
        
        mqttConfig.onConnectCallback = { returnCode in
            NSLog("Return Code is \(returnCode.description)")
            completion(returnCode.rawValue)
        }
        
        mqttConfig.onMessageCallback = { mqttMessage in
            NSLog(("MQTT Message received: \"\(mqttMessage.topic)\" - \"\(mqttMessage.payloadString!)\""))
            
            DispatchQueue.main.async() {
                let data = [ "id": mqttMessage.messageId,
                             "topic" : mqttMessage.topic,
                             "message": mqttMessage.payloadString] as [String : Any]
                let notificationName = Notification.Name(mqttMessage.topic)
                NotificationCenter.default.post(name: notificationName, object: nil, userInfo: data)
            }
        }
        mqttClient = MQTT.newConnection(mqttConfig, connectImmediately: true)
    }
    
    func disconnect() {
        mqttClient?.disconnect()
    }
    
    func publishMessage(topic: String, message: String) {
        mqttClient?.publish(string: message, topic: topic, qos: 2, retain: true)
    }
}
