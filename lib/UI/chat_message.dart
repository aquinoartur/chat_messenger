import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'image_scale_page.dart';


class ChatMessage extends StatelessWidget {

  final Map<String, dynamic> data;
  final bool mine;
  final String dataID;
  final BuildContext context;


  ChatMessage(this.data, this.mine, this.dataID, this.context);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Row(
        children: [
          !mine
              ? CircleAvatar(
            backgroundImage: NetworkImage(data['senderPhotoUrl']),
          )
              : Container(),
          SizedBox(
            width: 10,
          ),
          Expanded(
              child: data['imgUrl'] == null
                  ? Column( //mensagem do tipo texto
                crossAxisAlignment: mine
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  Text(
                    data['senderName'],
                    textAlign:
                    mine ? TextAlign.end : TextAlign.start,
                    style: TextStyle(
                        color: mine ? Colors.deepPurpleAccent : Colors.blue[500],
                        fontSize: 12,
                        fontWeight: FontWeight.w500),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                   GestureDetector(
                     onLongPress: (){
                       showDialog(context: context, builder: (_)=> _alert(dataID));
                     },
                     child: Container( //balão colorido
                        padding: EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                            color: mine ? Colors.deepPurpleAccent : Colors.blue[500],
                            borderRadius: BorderRadius.circular(20)),
                        child: Column(
                          crossAxisAlignment: mine
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            Text(
                              data['text'],
                              style: TextStyle(fontSize: 15, color: Colors.white),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 10,
                            ),
                          ],
                        ),
                      ),
                   ),

                ],
              )
                  : Container( //mensagem do tipo imagem
                child: Column(
                  crossAxisAlignment: mine
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['senderName'],
                      textAlign: mine ? TextAlign.end : TextAlign.start,
                      style: TextStyle(
                          color: mine ? Colors.deepPurpleAccent : Colors.blue,
                          fontSize: 12,
                          fontWeight: FontWeight.w500),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    GestureDetector(
                      child: Image.network(
                        data['imgUrl'],
                        width: 200,
                      ),
                      onLongPress: (){
                        showDialog(context: context, builder: (_)=> _alert(dataID));
                      },
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    ImageScalePage(data['imgUrl'])));
                      },
                    )
                  ],
                ),
              )),
          SizedBox(
            width: 10,
          ),
          mine
              ? CircleAvatar(
            backgroundImage: NetworkImage(data['senderPhotoUrl']),
          )
              : Container(),
        ],
      ),
    );
  }

  Widget _alert (String documentID){
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: EdgeInsets.all(80),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.transparent,
                  elevation: 0,
                  shadowColor: Colors.transparent
                ),
                  onPressed: (){
                    Firestore.instance.collection('messages').document(documentID).delete();
                    Navigator.pop(context);
                  },
                  child: Text("Excluir mensagem", style: TextStyle(color: Colors.red),)
              ),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      primary: Colors.transparent,
                      elevation: 0,
                      shadowColor: Colors.transparent
                  ),
                  onPressed: (){
                    Navigator.pop(context);
                  },
                  child: Text("Cancelar", style: TextStyle(color: Colors.blue),)
              ),

            ],
          )

        ],
      ),
    );
  }

}
