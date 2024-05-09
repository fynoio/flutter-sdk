import Flutter
import UIKit
import fyno_push_ios

public class FynoFlutterPlugin: NSObject, FlutterPlugin {
    let fynosdk = fyno.app
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "fyno_flutter", binaryMessenger: registrar.messenger())
        let instance = FynoFlutterPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
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
               let newDistinctId = arguments["newDistinctId"] as? String {
                fynosdk.mergeProfile(newDistinctId:newDistinctId){
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
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}
