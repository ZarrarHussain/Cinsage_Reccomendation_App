import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _searchController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.reference();

  String _senderName = '';
  String _currentRoom = '';
  List<ChatRoomTile> chatRoomTiles = [];

  @override
  void initState() {
    super.initState();
    _getSenderName();
    _fetchChatRooms();
  }

  void _getSenderName() async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      DatabaseReference userRef = _database.child('users').child(userId).child('user_name');
      try {
        DatabaseEvent event = await userRef.once();
        DataSnapshot snapshot = event.snapshot;
        setState(() {
          _senderName = snapshot.value as String? ?? 'Unknown';
        });
      } catch (error) {
        print("Failed to retrieve sender's name: $error");
      }
    }
  }

  void _createChatRoom() {
    TextEditingController roomController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create Chat Room'),
          content: TextField(
            controller: roomController,
            decoration: const InputDecoration(hintText: 'Enter chat room name'),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Create'),
              onPressed: () {
                if (roomController.text.isNotEmpty) {
                  _firestore.collection('chatrooms').add({
                    'name': roomController.text,
                    'created_by': _senderName,
                    'created_at': DateTime.now().millisecondsSinceEpoch,
                  });
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _joinChatRoom(String roomId, String roomName) async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId != null) {
      DatabaseReference userRef = _database.child('chatrooms').child(roomId).child('users').child(userId);
      try {
        DatabaseEvent event = await userRef.once();
        DataSnapshot snapshot = event.snapshot;

        if (snapshot.value != null) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ChatRoomPage(
                roomId: roomId,
                roomName: roomName,
                senderName: _senderName,
                database: _database,
              ),
            ),
          );
        } else {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Join Chat Room'),
                content: Text('Do you want to join $roomName?'),
                actions: [
                  TextButton(
                    child: const Text('Cancel'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                    child: const Text('Join'),
                    onPressed: () {
                      Navigator.of(context).pop();
                      _addUserToRoom(roomId, userId);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ChatRoomPage(
                            roomId: roomId,
                            roomName: roomName,
                            senderName: _senderName,
                            database: _database,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          );
        }
      } catch (error) {
        print("Failed to check if user is in chat room: $error");
      }
    }
  }

  void _addUserToRoom(String roomId, String userId) {
    _database.child('chatrooms').child(roomId).child('users').child(userId).set({'joined_at': DateTime.now().millisecondsSinceEpoch});
  }

  void _fetchChatRooms() async {
    QuerySnapshot snapshot = await _firestore.collection('chatrooms').get();
    List<ChatRoomTile> tiles = [];
    for (var chatRoom in snapshot.docs) {
      final roomId = chatRoom.id;
      final roomName = chatRoom['name'];

      tiles.add(ChatRoomTile(
        roomId: roomId,
        roomName: roomName,
        onTap: () => _joinChatRoom(roomId, roomName),
      ));
    }
    setState(() {
      chatRoomTiles = tiles;
    });
  }

  void _searchChatRooms(String query) {
    List<ChatRoomTile> filteredTiles = chatRoomTiles.where((tile) {
      return tile.roomName.toLowerCase().contains(query.toLowerCase());
    }).toList();
    setState(() {
      chatRoomTiles = filteredTiles;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat Rooms'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _createChatRoom,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search chat rooms...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              onChanged: (query) => _searchChatRooms(query),
            ),
          ),
          Expanded(
            child: ListView(
              children: chatRoomTiles,
            ),
          ),
        ],
      ),
    );
  }
}

class ChatRoomTile extends StatelessWidget {
  final String roomId;
  final String roomName;
  final VoidCallback onTap;

  const ChatRoomTile({super.key, required this.roomId, required this.roomName, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
      child: ListTile(
        title: Text(roomName),
        onTap: onTap,
      ),
    );
  }
}

class ChatRoomPage extends StatefulWidget {
  final String roomId;
  final String roomName;
  final String senderName;
  final DatabaseReference database;

  const ChatRoomPage({
    super.key,
    required this.roomId,
    required this.roomName,
    required this.senderName,
    required this.database,
  });

  @override
  _ChatRoomPageState createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  final TextEditingController _controller = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _leaveChatRoom(String roomId) {
    String? userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId != null) {
      DatabaseReference userRef = widget.database.child('chatrooms').child(roomId).child('users').child(userId);

      userRef.remove().then((_) {
        Navigator.of(context).pop();
      }).catchError((error) {
        print("Failed to leave chat room: $error");
      });
    }
  }

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      _firestore.collection('chatrooms').doc(widget.roomId).collection('messages').add({
        'sender_name': widget.senderName,
        'text': _controller.text,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.roomName),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () => _leaveChatRoom(widget.roomId),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: MessageStream(roomId: widget.roomId, senderName: widget.senderName),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Enter your message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MessageStream extends StatelessWidget {
  final String roomId;
  final String senderName;

  const MessageStream({super.key, required this.roomId, required this.senderName});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('chatrooms')
          .doc(roomId)
          .collection('messages')
          .orderBy('timestamp', descending: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final messages = snapshot.data!.docs;

        List<MessageBubble> messageBubbles = [];
        for (var message in messages) {
          final senderName = message['sender_name'];
          final messageText = message['text'];
          final timestamp = message['timestamp'];

          final messageBubble = MessageBubble(
            senderName: senderName,
            text: messageText,
            timestamp: timestamp,
            isMe: senderName == this.senderName,
          );
          messageBubbles.add(messageBubble);
        }

        return ListView(
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
          children: messageBubbles,
        );
      },
    );
  }
}

class MessageBubble extends StatelessWidget {
  final String senderName;
  final String text;
  final int timestamp;
  final bool isMe;

  const MessageBubble({super.key, required this.senderName, required this.text, required this.timestamp, required this.isMe});

  @override
  Widget build(BuildContext context) {
    final DateTime messageTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final String formattedTime = DateFormat('hh:mm a').format(messageTime);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            senderName,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12.0,
            ),
          ),
          Material(
            borderRadius: isMe
                ? const BorderRadius.only(
              topLeft: Radius.circular(10.0),
              bottomLeft: Radius.circular(10.0),
              bottomRight: Radius.circular(10.0),
            )
                : const BorderRadius.only(
              topRight: Radius.circular(10.0),
              bottomLeft: Radius.circular(10.0),
              bottomRight: Radius.circular(10.0),
            ),
            elevation: 5.0,
            color: isMe ? Colors.lightBlueAccent : Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              child: Column(
                crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    style: TextStyle(
                      color: isMe ? Colors.white : Colors.black54,
                      fontSize: 15.0,
                    ),
                  ),
                  const SizedBox(height: 5.0),
                  Text(
                    formattedTime,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 10.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
