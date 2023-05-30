import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatGPTApiKeyForm extends StatefulWidget {
  //FIXME : do we need this super ?
  const ChatGPTApiKeyForm({super.key});

  @override
  ChatGPTApiKeyFormState createState() {
    return ChatGPTApiKeyFormState();
  }
}

// Create a corresponding State class.
// This class holds data related to the form.
class ChatGPTApiKeyFormState extends State<ChatGPTApiKeyForm> {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a GlobalKey<FormState>,
  // not a GlobalKey<MyCustomFormState>.
  final _formKey = GlobalKey<FormState>();
  String _chatGPTAPIKey = '';
  bool textLoaded = false;
  final myController = TextEditingController();



  @override
  @protected
  @mustCallSuper
  void initState() {
    super.initState();
    initChatGPTAPIKey();
    textLoaded = true;
  }
  Future<void> initChatGPTAPIKey() async {
    final prefs = await SharedPreferences.getInstance();
    _chatGPTAPIKey = prefs.getString('chat_gtp_api_key') ?? '';
    myController.text = _chatGPTAPIKey;
  }

  Future<void> _setChatGPTAPIKey(String chatGPTAPIKey) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _chatGPTAPIKey = chatGPTAPIKey;
    });
    prefs.setString('chat_gtp_api_key', chatGPTAPIKey);
  }


  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    myController.text = _chatGPTAPIKey;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          textLoaded ?
            TextFormField(
              controller: myController,
              decoration: const InputDecoration(
                hintText: "Your Chat GPT API Key"
              ), 
              // The validator receives the text that the user has entered.
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your Chat GPT API Key';
                }
                return null;
              },
            )
          : 
            const CircularProgressIndicator()
          ,
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: ElevatedButton(
              onPressed: () async {
                // Validate returns true if the form is valid, or false otherwise.
                if (_formKey.currentState!.validate()) {
                  // If the form is valid, display a snackbar. In the real world,
                  // you'd often call a server or save the information in a database.
                  await _setChatGPTAPIKey(myController.text);


                  // ignore: use_build_context_synchronously
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        // Retrieve the text the that user has entered by using the
                        // TextEditingController.
                        content: Text(_chatGPTAPIKey),
                      );
                    },
                  );

                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(_chatGPTAPIKey)),
                  );
                }
              },
              child: const Text('Submit'),
            ),
          ),
        ],
      ),
    );
  }
}