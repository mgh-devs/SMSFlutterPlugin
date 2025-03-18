import 'package:flutter/material.dart';
import 'package:sms_flutter/sms_flutter.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final List<Map<String, String>> _smsList = [];
  int _simCount = 0;

  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
final SmsFlutter sms=SmsFlutter();
  @override
  void initState() {
    super.initState();
    _init();
  }

  void _startListeningForSms() async {
    while (true) {
      final result = await sms.receiveSms();
      if (result.containsKey('sender') && result.containsKey('message')) {
        setState(() {
          _smsList.add({
            'sender': result['sender']!,
            'message': result['message']!,
          });
        });
      } else {
        print('error: $result');
        await Future.delayed(const Duration(seconds: 2));
      }
    }
  }

  void _getSimCount() async {

    int count = await sms.getSimCount();
    setState(() {
      _simCount = count;
    });
  }

  void _init() async {
    if(await sms.checkPermissions()){
      _startListeningForSms();
      _getSimCount();
    }else{
      await sms.requestPermissions();
      _init();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.grey.shade200,
        appBar: AppBar(
          title: const Text("SMS Flutter"),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: "phone number",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _messageController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: "message",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              Column(
                children: List.generate(_simCount, (index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: ElevatedButton(
                      onPressed: () async {
                        final phone = _phoneController.text.trim();
                        final message = _messageController.text.trim();

                        if (phone.isEmpty || message.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("PhoneNumber or Message Empty")),
                          );
                          return;
                        }

                        await sms.sendSmsWithSim(
                          phoneNumber: phone,
                          message: message,
                          simSlot: index,
                        );
                      },
                      child: Text("send whit sim${index + 1}"),
                    ),
                  );
                }),
              ),
              const Divider(thickness: 1),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ElevatedButton(
                  onPressed: () async {
                    sms.requestPermissions();
                    if(await sms.checkPermissions()){
                      _init();
                    }
                  },
                  child: Text("Get Permissions"),
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _smsList.length,
                itemBuilder: (context, index) {
                  final sms = _smsList[index];
                  return Card(
                    margin: const EdgeInsets.all(8),
                    child: ListTile(
                      title: Text("فرستنده: ${sms['sender']}"),
                      subtitle: Text(sms['message'] ?? ""),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}


