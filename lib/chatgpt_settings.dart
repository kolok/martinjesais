import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer';
import 'main.dart';

class ChatGPTApiKeyForm extends StatefulWidget {
  const ChatGPTApiKeyForm({super.key});

  @override
  ChatGPTApiKeyFormState createState() {
    return ChatGPTApiKeyFormState();
  }
}

// Create a corresponding State class.
// This class holds data related to the form.
class ChatGPTApiKeyFormState extends State<ChatGPTApiKeyForm> {

  bool _isChecking = false;
  dynamic _validationMsg;
  final myController = TextEditingController();


  Future<dynamic> checkChatGPTApiKey(chatGPTApiKeyInput) async {
    _validationMsg = null;
    setState(() {});
    //do all sync validation
    if (chatGPTApiKeyInput.isEmpty) {
      _validationMsg = "chatGPT api key is required";
      setState(() {});
      return;
    }

    _isChecking = true;
    setState(() {});

    final request = ChatCompleteText(messages: [
      Map.of({"role": "user", "content": 'Hello!'})
    ], maxToken: 1, model: GptTurboChatModel());

    OpenAI openAI;
    openAI = OpenAI.instance.build(token: chatGPTApiKeyInput,baseOption: HttpSetup(receiveTimeout: const Duration(seconds: 5)),enableLog: true);
    openAI.onChatCompletion(request: request).catchError((err){
        if(err is OpenAIAuthError){
          _validationMsg = "Authentication error, please check your chatGPT api key";
        }
        else if(err is OpenAIRateLimitError){
          _validationMsg = "Rate limit is reach for the given chatGPT api key";
        }
        else if(err is OpenAIServerError){
          _validationMsg = "Server return an error when it was call with this chatGPT api key";
        }
        else {
          _validationMsg = "Error while validating chatGPT api key";
        }
        log('$_validationMsg, error detail: ${err.runtimeType} : $err');
        return err;
      });
    _isChecking = false;
  }


  final _formKey = GlobalKey<FormState>();
  String _chatGPTAPIKey = '';
  bool textLoaded = false;



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

          Focus(
            child: 
              textLoaded ?
                TextFormField(
                  controller: myController,
                  decoration: InputDecoration(
                    hintText: "Your Chat GPT API Key",
                    suffixIcon: _isChecking ? Transform.scale(scale: 0.5, child: const CircularProgressIndicator()) : null,
                  ),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (val) => _validationMsg,
                )
              : 
                const CircularProgressIndicator()
              ,
              onFocusChange: (hasFocus) {
                if (!hasFocus) checkChatGPTApiKey(myController.text);
              },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: ElevatedButton(
              onPressed: () async {
                // Validate returns true if the form is valid, or false otherwise.
                if (_formKey.currentState!.validate()) {
                  // If the form is valid, display a snackbar. In the real world,
                  // you'd often call a server or save the information in a database.
                  await _setChatGPTAPIKey(myController.text);

                  // Navigator.of(context).push(
                  //   MaterialPageRoute(
                  //     builder: (context) => const ,
                  //   ),
                  // );
                  if (!context.mounted) return;
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MyChat()),
                  );

                  // // ignore: use_build_context_synchronously
                  // showDialog(
                  //   context: context,
                  //   builder: (context) {
                  //     return AlertDialog(
                  //       // Retrieve the text the that user has entered by using the
                  //       // TextEditingController.
                  //       content: Text(_chatGPTAPIKey),
                  //     );
                  //   },
                  // );

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
