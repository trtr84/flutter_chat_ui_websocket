import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:uuid/uuid.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final channel = WebSocketChannel.connect(
    Uri.parse('wss://echo.websocket.org'),
  );

  // Future<void> chatWs() async {
  //   await channel.ready;
  //   channel.stream.listen(

  //   );
  // }

  final List<types.Message> _messages = [];

  void _addMessage(types.Message message) {
    _messages.insert(0, message);
  }

  var user = const Uuid().v1();
  var _channel = Uuid().v4();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: StreamBuilder(
          stream: channel.stream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.connectionState == ConnectionState.active) {
              _addMessage(
                types.TextMessage(
                    author: types.User(id: _channel),
                    id: Random().nextInt(100000).toString(),
                    text: snapshot.data),
              );
              return Chat(
                messages: _messages,
                onSendPressed: (val) {
                  channel.sink.add(val.text);
                  _addMessage(
                    types.TextMessage(
                        author: types.User(id: user),
                        id: Random().nextInt(100000).toString(),
                        text: val.text),
                  );
                },
                user: types.User(id: user),
              );
            } else {
              return const Center(
                child: Text('Something went wrong'),
              );
            }
          },
        ),
      ),
    );
  }
}
