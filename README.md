# Kotlin SDK in Flutter

## This document helps you with integrating Fyno Kotlin SDK in Flutter application

### 1.Introduction

Flutter gives flexibility for developers to run native Android or iOS code from the Flutter application with Method Channel

#### Creating Flutter platform client

-   Inside your initState method in Flutter create a MethodChannel `const platform = MethodChannel("<YOUR_CHANNEL_NAME>")`
-   Use the platform to trigger your native method `await platform.invokeMethod('init',{wsid,apikey,integration})`
-   To identify user trigger identify native method `await platform.invokeMethod('identify',{distinct_id})`

#### Add an Android platform-specific implementation

Inside your main activity in Android import FlutterEngine and MethodChannel

```kotlin
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
```

Inside your main activity override `configureFlutterEngine()` method and define method channels inside it with `MethodChannel` constructor

```kotlin
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
  private val CHANNEL = "<YOUR_CHANNEL_NAME>"

  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
      call, params, result ->
      if (call.method == "init") {
        FynoSdk.init(call.params)
        //TODO
      } else if(call.method == "identify") {
        FynoSdk.identify(call.params)
      } else {
        result.notImplemented()
      }
    }
  }
}
```

**_NOTE:_** Find all native methods in [kotlin-sdk docs](https://gitlab.com/fyno-app/kotlin-sdk)
