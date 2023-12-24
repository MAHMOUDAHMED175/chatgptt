import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';

import '../consts.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

//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
class _ChatPageState extends State<ChatPage> {
  final _openAI = OpenAI.instance.build(
    token: OPENAI_API_KEY,
    baseOption: HttpSetup(
      receiveTimeout: const Duration(
        seconds: 15,
      ),
    ),
    enableLog: true,
  );

  final ChatUser _currentUser =
      ChatUser(id: '1', firstName: 'Mahmoud', lastName: 'Ahmed');

  final ChatUser _gptChatUser = ChatUser(
      id: '2',
      firstName: 'Chat',
      lastName: 'GPT',
      profileImage:
          "https://img.freepik.com/free-vector/floating-robot_78370-3669.jpg");

  List<ChatMessage> _messages = <ChatMessage>[];
  List<ChatUser> _typingUsers = <ChatUser>[];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'GPT Chat',
          style: TextStyle(
            color: Colors.lightBlueAccent,
          ),
        ),
      ),
      body: DashChat(
          messageListOptions: MessageListOptions(
            showDateSeparator: true,
            showFooterBeforeQuickReplies: true,
            loadEarlierBuilder: Text("mahmoud"),
          ),
          currentUser: _currentUser,
          typingUsers: _typingUsers,
          messageOptions: MessageOptions(
            showTime: true,
            currentUserContainerColor: Colors.black.withOpacity(0.1),
            borderRadius: 12,
            currentUserTextColor: Colors.black,
            containerColor: Color.fromRGBO(
              0,
              166,
              126,
              1,
            ),
            textColor: Colors.white,
          ),
          onSend: (ChatMessage m) {
            getChatResponse(m);
          },
          messages: _messages),
    );
  }

  Future<void> getChatResponse(ChatMessage m) async {
    setState(() {
      _messages.insert(0, m);
      _typingUsers.add(_gptChatUser);
    });
    List<Messages> _messagesHistory = _messages.reversed.map((m) {
      if (m.user == _currentUser) {
        return Messages(role: Role.user, content: m.text);
      } else {
        return Messages(role: Role.assistant, content: m.text);
      }
    }).toList();
    final request = ChatCompleteText(
      model: GptTurbo0301ChatModel(),
      messages: _messagesHistory,
      maxToken: 200,
    );
    final response = await _openAI.onChatCompletion(request: request);
    for (var element in response!.choices) {
      if (element.message != null) {
        setState(() {
          _messages.insert(
            0,
            ChatMessage(
                user: _gptChatUser,
                createdAt: DateTime.now(),
                text: element.message!.content),
          );
        });
      }
    }
    setState(() {
      _typingUsers.remove(_gptChatUser);
    });
  }
}
