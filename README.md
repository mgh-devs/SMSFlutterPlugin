# 📦 SmsFlutter Plugin

`SmsFlutter` is a Flutter plugin for sending and receiving SMS messages, checking SIM count, and managing SMS permissions on Android devices. It allows you to send SMS messages through a specific SIM slot (for dual-SIM devices), receive incoming SMS messages, and request necessary permissions from the user.

---

## 🚀 Features

- Send SMS using a selected SIM card
- Receive SMS messages
- Get the number of active SIM cards
- Check SMS permissions
- Request SMS permissions

---

## 📲 Platform Support

| Platform | Support |
|----------|---------|
| Android  | ✔️       |
| iOS      | ❌       |

---

## 📥 Installation

Add the dependency to your `pubspec.yaml`:

```yaml
dependencies:
  sms_flutter:
    path: ./path_to_your_plugin
```

---

## 🧑‍💻 Usage

Import the plugin:

```dart
import 'package:sms_flutter/sms_flutter.dart';

final sms = SmsFlutter();
```

### Example

```dart
void main() async {
  final sms = SmsFlutter();

  // Check permissions
  bool hasPermission = await sms.checkPermissions();
  if (!hasPermission) {
    await sms.requestPermissions();
  }

  // Get SIM count
  int simCount = await sms.getSimCount();
  print("SIM Count: $simCount");

  // Send SMS
  String result = await sms.sendSmsWithSim(
    phoneNumber: '+1234567890',
    message: 'Hello from Flutter!',
    simSlot: 0,
  );
  print("SMS Send Result: $result");

  // Receive SMS
  Map<String, String> received = await sms.receiveSms();
  print("Received SMS: $received");
}
```

---

## 📊 Function Table

| Function Name           | Parameters                                                                                   | Return Type              | Description                                                                 |
|------------------------|-----------------------------------------------------------------------------------------------|--------------------------|-----------------------------------------------------------------------------|
| `getSimCount()`        | None                                                                                          | `Future<int>`            | Returns the number of SIM cards available on the device.                   |
| `sendSmsWithSim()`     | `phoneNumber: String` <br> `message: String` <br> `simSlot: int (default: 0)`                | `Future<String>`         | Sends an SMS via the specified SIM slot.                                   |
| `receiveSms()`         | None                                                                                          | `Future<Map<String,String>>` | Receives the most recent SMS message (implementation may vary).            |
| `checkPermissions()`   | None                                                                                          | `Future<bool>`           | Checks if SMS permissions are granted.                                     |
| `requestPermissions()` | None                                                                                          | `Future<void>`           | Requests SMS permissions from the user.                                    |

---

## ⚠️ Permissions

Ensure the following permissions are declared in your Android `AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.SEND_SMS"/>
<uses-permission android:name="android.permission.RECEIVE_SMS"/>
<uses-permission android:name="android.permission.READ_SMS"/>
<uses-permission android:name="android.permission.READ_PHONE_STATE"/>
```


### 📬 Support & Contact
If you have any issues or suggestions, feel free to reach out to me:
- 📢 **Telegram**: [@mgh_zdev](https://t.me/mgh_zdev)
- 💻 **GitHub**: [mgh-devs](https://github.com/mgh-devs)
- 🔗 **LinkedIn**: [Ghanizadeh Mohammad](https://www.linkedin.com/in/ghanizadeh-me/)
---


