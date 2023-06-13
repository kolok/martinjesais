import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer';


class ChatGPTChat extends StatefulWidget {
  const ChatGPTChat({super.key});

  @override
  ChatGPTChatState createState() {
    return ChatGPTChatState();
  }
}

// Create a corresponding State class.
// This class holds data related to the form.
class ChatGPTChatState extends State<ChatGPTChat> {

  String _chatGPTAPIKey = '';
  bool textLoaded = false;

  @override
  @protected
  @mustCallSuper
  void initState() {
    super.initState();
    initChatGPTAPIKey();
  }

  Future<void> initChatGPTAPIKey() async {
    final prefs = await SharedPreferences.getInstance();
    _chatGPTAPIKey = prefs.getString('chat_gtp_api_key') ?? '';
    textLoaded = true;
    log('Chat GPT key loaded: $_chatGPTAPIKey');
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: textLoaded ? 
      ElevatedButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: textLoaded ? Text(_chatGPTAPIKey) : const Text('pending…'),
      ) : 
      const CircularProgressIndicator(),
    );
  }

}
