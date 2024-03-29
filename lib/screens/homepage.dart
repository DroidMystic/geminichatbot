import 'dart:convert';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geminichatbot/auth/secrets.dart';


class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  ChatUser user = ChatUser(id: '1', firstName: 'User');
  ChatUser bot = ChatUser(id: '2', firstName: 'Gemini');

  final url = mySecretKey;
  final header = {
    'Content-Type' : 'application/json'
  };
 
  List<ChatMessage> allmessages = [];
  List<ChatUser> typing = [];

  getData(ChatMessage m) async {
    typing.add(bot);
    allmessages.insert(0, m);
    setState(() {
    });
    var data = {"contents":[{"parts":[{"text":m.text}]}]};

    await http.post(Uri.parse(url),headers:header,body: jsonEncode(data))
    .then((value){
      if(value.statusCode==200){
        var result = jsonDecode(value.body);
        print(result['candidates'][0]['content']['parts'][0]['text']);

        ChatMessage m1= ChatMessage(
          text: result['candidates'][0]['content']['parts'][0]['text'],
          user: bot, 
          createdAt: DateTime.now());

        allmessages.insert(0, m1);
        setState(() {
        });
      }else{
        print("Error Occured");
      }
    })
    .catchError((e){});
    typing.remove(bot);
    setState(() {
    });


  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Gemini ChatBot")),
      body: DashChat(
        typingUsers: typing,
        currentUser: user,
         onSend:(
          ChatMessage m){
            getData(m);
          },
          messages: allmessages),
    );
  }
}