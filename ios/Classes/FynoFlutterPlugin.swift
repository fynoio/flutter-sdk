import Flutter
import UIKit
import fyno_push_ios

public class FynoFlutterPlugin: NSObject, FlutterPlugin, FlutterStreamHandler{
    let fynosdk = fyno.app
    
    private var eventSink: FlutterEventSink?
    private var listenerCounts: [String: Int] = [:]
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "fyno_flutter", binaryMessenger: registrar.messenger())
        let eventChannel = FlutterEventChannel(name: "fyno_flutter_plugin/events", binaryMessenger: registrar.messenger())
        let instance = FynoFlutterPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        eventChannel.setStreamHandler(instance)
    }
    
    override init() {
        super.init()
        
        let notificationNames: [NSNotification.Name] = [
            .init("onNotificationClicked"),
        ]
        
        for name in notificationNames {
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(handleNotificationEvent),
                name: name,
                object: nil
            )
        }
    }
        
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
     
    @objc private func handleNotificationEvent(notification: Notification) {
        emitEventWithRetry(notification: notification)
    }
       
    private func emitEventWithRetry(notification: Notification, attempt: Int = 1, maxAttempts: Int = 3) {
        DispatchQueue.main.async {
            if self.listenerCounts[notification.name.rawValue, default: 0] > 0 {
                // If listeners exist, send the event
                self.eventSink?(["event": notification.name.rawValue, "data": notification.object ?? [:]])
            } else if attempt < maxAttempts {
                // Retry with exponential backoff
                let delay = pow(2.0, Double(attempt)) // Exponential backoff
                print("No listeners for \(notification.name.rawValue). Retrying in \(delay) seconds (Attempt \(attempt))...")
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    self.emitEventWithRetry(notification: notification, attempt: attempt + 1, maxAttempts: maxAttempts)
                }
            } else {
                // Max attempts reached, log a failure
                print("Failed to emit \(notification.name.rawValue) after \(maxAttempts) attempts. No listeners registered.")
            }
        }
    }
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        if let eventName = arguments as? String {
            listenerCounts[eventName, default: 0] += 1
            print("Added listener for \(eventName). Count: \(listenerCounts[eventName]!)")
        }
        return nil
    }
        
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        if let eventName = arguments as? String {
            listenerCounts[eventName] = max((listenerCounts[eventName] ?? 0) - 1, 0)
            print("Removed listener for \(eventName). Count: \(listenerCounts[eventName]!)")
        }
        self.eventSink = nil
        return nil
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "init":
            if let arguments = call.arguments as? [String: Any],
               let workspaceId = arguments["workspaceId"] as? String,
               let integrationID = arguments["integrationID"] as? String,
               let userId = arguments["userId"] as? String,
               let version = arguments["version"] as? String {
                fynosdk.initializeApp(
                    workspaceID: workspaceId,
                    integrationID: integrationID,
                    distinctId: userId,
                    version: version
                ){
                    initResult in
                    switch initResult {
                    case .success(_):
                        print("Initialization successful")
                        result(nil)
                        return
                    case .failure(let error):
                        print(error)
                        result(FlutterError(code: "INIT_FAILURE", message: "Init failed with error: \(error.localizedDescription)", details: nil))
                        return
                    }
                }
            } else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            }
        case "identify":
            if let arguments = call.arguments as? [String: Any],
               let distinctID = arguments["distinctID"] as? String,
               let userName = arguments["userName"] as? String {
                fynosdk.identify(newDistinctId: distinctID, userName: userName) { identifyResult in
                    switch identifyResult{
                    case .success(_):
                        print("Identify successful")
                        result(nil)
                        return
                    case .failure(let error):
                        print(error)
                        result(FlutterError(code: "IDENTIFY_FAILURE", message: "Identify failed with error: \(error.localizedDescription)", details: nil))
                        return
                    }
                }
            } else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            }
        case "updateName":
            if let arguments = call.arguments as? [String: Any],
               let userName = arguments["userName"] as? String{
                fynosdk.updateName(userName: userName){ updateResult in
                    switch updateResult{
                    case .success(_):
                        print("Update name successful")
                        result(nil)
                        return
                    case .failure(let error):
                        print(error)
                        result(FlutterError(code: "UPDATE_NAME_FAILED", message: "Update failed with error: \(error.localizedDescription)", details: nil))
                        return
                    }
                }
            } else{
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            }
        case "registerPush":
            if let arguments = call.arguments as? [String: Any],
                let provider = arguments["provider"] as? String {
                let isAPNs = String.lowercased(provider)() == "apns" ? true : false
                fynosdk.registerPush(isAPNs: isAPNs){
                    registerPushResult in
                    switch registerPushResult{
                    case .success(_):
                        print("registerPush successful")
                        result(nil)
                        return
                    case .failure(let error):
                        print(error)
                        result(FlutterError(code: "REGISTER_PUSH_FAILURE", message: "Register push failed with error: \(error.localizedDescription)", details: nil))
                        return
                    }
                }
            } else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            }
        case "registerInapp":
            if let arguments = call.arguments as? [String: Any],
                let integrationID = arguments["integrationID"] as? String {
                fynosdk.registerInapp(integrationID: integrationID){
                    registerInappResult in
                    switch registerInappResult {
                    case .success(_):
                        print("registerInapp successful")
                        result(nil)
                        return
                    case .failure(let error):
                        print(error)
                        result(FlutterError(code: "REGISTER_INAPP_FAILURE", message: "Inapp Register failed with error: \(error.localizedDescription)", details: nil))
                        return
                    }
                }
            } else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            }
        case "mergeProfile":
            if let arguments = call.arguments as? [String: Any],
               let oldDistinctId = arguments["oldDistinctId"] as? String,
               let newDistinctId = arguments["newDistinctId"] as? String {
                fynosdk.mergeProfile(oldDistinctId:oldDistinctId, newDistinctId:newDistinctId){
                    mergeResult in
                    switch mergeResult{
                    case .success(_):
                        print("mergeProfile successful")
                        result(nil)
                        return
                    case .failure(let error):
                        print(error)
                        result(FlutterError(code: "MERGE_PROFILE_FAILURE", message: "Merge profile failed with error: \(error.localizedDescription)", details: nil))
                        return
                    }
                }
            } else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
                return
            }
        case "updateStatus":
            if let arguments = call.arguments as? [String: Any],
               let callbackUrl = arguments["callbackUrl"] as? String,
               let status = arguments["status"] as? String{
                fynosdk.updateStatus(callbackUrl: callbackUrl, status: status){
                    updateStatusResult in
                    switch updateStatusResult{
                    case .success(_):
                        print("updateStatus successful")
                        result(nil)
                        return
                    case .failure(let error):
                        print(error)
                        result(FlutterError(code: "UPDATE_STATUS_FAILURE", message: "Update status failed with error: \(error.localizedDescription)", details: nil))
                        return
                    }
                }
            } else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
                return
            }
        case "resetUser":
            fynosdk.resetUser() {
                resetUserResult in
                switch resetUserResult{
                case .success(_):
                    print("resetUser successful")
                    result(nil)
                    return
                case .failure(let error):
                    print(error)
                    result(FlutterError(code: "RESET_USER_FAILURE", message: "Reset user failed with error: \(error.localizedDescription)", details: nil))
                    return
                }
            }
        case "getNotificationToken":
            let token = fynosdk.getPushNotificationToken()
            if token == "" {
                result(FlutterError(code: "GET_PUSH_NOTIFICATION_FAILED", message: "NO PUSH TOKEN FOUND", details: nil))
                return
            }
            result(fynosdk.getPushNotificationToken())
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}
