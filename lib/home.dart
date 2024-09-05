import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

// Replace with your actual API key
const apiKey = 'AIzaSyCUfX8zK1VyKPu0vG7ZmkTML2nQMrAxfLY';

class MyChatApps extends StatefulWidget {
  const MyChatApps({super.key});

  @override
  _MyChatAppStates createState() => _MyChatAppStates();
}

class _MyChatAppStates extends State<MyChatApps> {
  final TextEditingController textController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  List<Map<String, dynamic>> messages = []; // Stores chat history

  bool isGenerating = false;

  void sendMessage(String text) async {
    setState(() {
      isGenerating = true;
      messages.add({'text': text, 'isUser': true});
    });

    // Scroll to the bottom after sending a message
    scrollController.animateTo(
      scrollController.position.maxScrollExtent + 100,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );

    // Create GenerativeModel instance
    final model = GenerativeModel(model: 'gemini-pro', apiKey: apiKey);

    // Prepare request content
    final content = [Content.text(text)];

    // Generate response
    final response = await model.generateContent(content);

    // Add bot response to chat history
    setState(() {
      messages.add({'text': response.text!, 'isUser': false});
      isGenerating = false;
    });

    // Scroll to the bottom after receiving a response
    scrollController.animateTo(
      scrollController.position.maxScrollExtent + 100,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.amberAccent,
        appBar: AppBar(title: const Text('ChatBot'),centerTitle: true,backgroundColor: Colors.white,),
        body: Container(
          padding:const  EdgeInsets.all(10),
          child: Column(
            children: [
              // Chat history display
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isUser = message['isUser'] as bool;

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 12.0),
                      child: Align(
                        alignment:
                            isUser ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.all(12.0),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.75,
                          ),
                          decoration: BoxDecoration(
                            color: isUser ? Colors.black : Colors.white,
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          child: Text(
                            message['text'],
                            style: TextStyle(
                              color: isUser ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (isGenerating) const Center(child: CircularProgressIndicator(color: Colors.white,)),
              // User input field
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: textController,
                        onSubmitted: (text) {
                          if (text.isNotEmpty) {
                            sendMessage(text);
                            textController.clear();
                          }
                        },
                        decoration: InputDecoration(

                          hintText: 'Type a message',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      color: Colors.blue,
                      icon: const Icon(Icons.send),
                      onPressed: () {
                        if (textController.text.isNotEmpty) {
                          sendMessage(textController.text);
                          textController.clear();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
