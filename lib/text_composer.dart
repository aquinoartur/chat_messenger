import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class TextComposer extends StatefulWidget {

  TextComposer(this.sendMessage);

 final Function({String text, File imgFile}) sendMessage;

  @override
  _TextComposerState createState() => _TextComposerState();
}

class _TextComposerState extends State<TextComposer> {

  bool _isComposing = false;

  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final ImagePicker _picker = ImagePicker();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
      child: Row(
        children: [
          IconButton(
              icon: Icon(Icons.photo_camera, color: Colors.blue,),
              onPressed: () async{
                  final pickedFile = await _picker.getImage(source: ImageSource.gallery);

                  if (pickedFile == null) return;
                  File imgFile = File(pickedFile.path);

                  widget.sendMessage(imgFile: imgFile);
              }),
          Expanded(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: 'Digite uma mensagem...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20)
                  )
                ),
                onChanged: (txt){
                    setState(() {
                      _isComposing = txt.isNotEmpty;
                    });
                },
                onSubmitted: (txt){
                    widget.sendMessage(text: txt);
                    _reset();
                },
              ),
          ),
          IconButton(
              icon: Icon(Icons.send, color: _isComposing ? Colors.blue : Colors.grey,),
              onPressed: _isComposing ? (){
                widget.sendMessage(text: _controller.text);
                _reset();
              } : null,
          ),
        ],
      ),
    );
  }

  void _reset (){
    _controller.clear();

    setState(() {
      _isComposing = false;
    });
  }
}
