import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' show Vector3;

class ImageScalePage extends StatefulWidget {
  final String urlImage;

  ImageScalePage(this.urlImage);

  @override
  _ImageScalePageState createState() => _ImageScalePageState();
}

class _ImageScalePageState extends State<ImageScalePage> {
  double _scale = 1.0;
  double _previousScale = 1.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Detalhes da Imagem", style: TextStyle(color: Colors.blue, fontSize: 18),),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        iconTheme: IconThemeData(
          color: Colors.blue
        ),
      ),
      body: Center(
        child: GestureDetector(

          onScaleStart: (ScaleStartDetails details){
            _previousScale = _scale;

            setState(() {});
          },
          onScaleUpdate: (ScaleUpdateDetails details){
            _scale = _previousScale * details.scale;

            setState(() {});
          },
          onScaleEnd: (ScaleEndDetails details){
            _previousScale = 1.0;

            setState(() {});
          },

          child: RotatedBox(
            quarterTurns: 0,
            child: Transform(
              alignment: FractionalOffset.center,
              transform: Matrix4.diagonal3(Vector3(_scale, _scale, _scale)),
              child: Image.network(
                widget.urlImage,
                width: 300,
              ),
            ),
          ),
          onTap: () {

          },
        ),
      ),
    );
  }
}
