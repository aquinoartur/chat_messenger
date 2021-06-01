import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/text_composer.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'chat_message.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final GoogleSignIn googleSignIn = GoogleSignIn();

  FirebaseUser _currentUser;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    FirebaseAuth.instance.onAuthStateChanged.listen((user) {
        setState(() {
          _currentUser = user;
        });
    });


  }

  Future<FirebaseUser> _getUser() async {

    if(_currentUser != null) return _currentUser;

    try {

      final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.getCredential(
          idToken: googleSignInAuthentication.idToken,
          accessToken: googleSignInAuthentication.accessToken
      );

      final AuthResult authResult = await FirebaseAuth.instance.signInWithCredential(credential);

      final FirebaseUser user = authResult.user;

      return user;

    } catch (error){
      return null;
    }
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text(_currentUser != null ? 'Olá, ${_currentUser.displayName}' : 'Chat', style: TextStyle(fontSize: 18),),
          elevation: 0,
          centerTitle: true,
          actions: [
            _currentUser != null ?
            IconButton(
                icon: Icon(Icons.logout),
                onPressed: (){
                  FirebaseAuth.instance.signOut();
                  googleSignIn.signOut();

                  ScaffoldMessenger.of(_scaffoldKey.currentContext).showSnackBar(
                      SnackBar(content: Text("Você saiu do chat!"),
                        backgroundColor: Colors.blue,)
                  );

                })
            : Container()
          ],
        ),
        body: Column(
          children: [
            Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: Firestore.instance.collection('messages').orderBy('time').snapshots(),
                  builder: (context, snapshot){
                    switch (snapshot.connectionState){

                      case ConnectionState.none:
                      case ConnectionState.waiting:
                        return Center(child: CircularProgressIndicator());

                      default:
                       List<DocumentSnapshot> docs = snapshot.data.documents.reversed.toList();
                       return _currentUser != null? ListView.builder(
                           itemCount: docs.length,
                           reverse: true,
                           itemBuilder: (context, index){
                             return ChatMessage(
                               docs[index].data,
                               docs[index].data['uid'] == _currentUser?.uid,
                               docs[index].documentID,
                               context

                             );
                           }
                       ) : Container(
                         child: _alert(),
                       );
                    }
                  },
                )
            ),
            _isLoading ? LinearProgressIndicator() :
            TextComposer(_sendMessage),
          ],
        ),
      );
  }


  AlertDialog _alert (){
    if(_currentUser == null){
      return AlertDialog(
        title: Text("Nenhum usuário está logado", style: TextStyle(fontSize: 16), textAlign: TextAlign.center,),
        content: Text("Realize login para utilizar o chat", style: TextStyle(fontSize: 14), textAlign: TextAlign.center,),
        actions: [
          // ignore: deprecated_member_use
          FlatButton(
            child: Text(
              "Fazer Login",
              style: TextStyle(color: Colors.blue),
            ),
            onPressed: () {
              _getUser();
            },
          ),
          // ignore: deprecated_member_use
          FlatButton(
            child: Text(
              "Sair do App",
              style: TextStyle(color: Colors.red),

            ),
            onPressed: () {
              SystemNavigator.pop();
            },
          ),
        ],
      );
    }
  }


  void _sendMessage({String text, File imgFile}) async {

    final FirebaseUser user = await _getUser(); //obtive o usuário

    if (user == null){
            ScaffoldMessenger.of(_scaffoldKey.currentContext).showSnackBar(
              SnackBar(content: Text("Não foi possível realizar o login!"),
              backgroundColor: Colors.red,)
            );
    }

    Map<String, dynamic> data = {
      "uid": user.uid,
      "senderName": user.displayName,
      "senderPhotoUrl": user.photoUrl,
      "time": Timestamp.now(),
    };

    if(imgFile != null){
      StorageUploadTask task = FirebaseStorage.instance.ref().child(
       user.uid + DateTime.now().millisecondsSinceEpoch.toString()
      ).putFile(imgFile);

      setState(() {
        _isLoading = true;
      });

     StorageTaskSnapshot taskSnapshot = await task.onComplete;
     String url = await taskSnapshot.ref.getDownloadURL();
     data['imgUrl'] = url;
    }

    setState(() {
      _isLoading = false;
    });

    if(text != null) data['text'] = text;

    Firestore.instance.collection('messages').add(data);
  }
}
