import 'package:flutter/material.dart';
import 'package:mts/image/bloc/image_bloc.dart';

void main() => runApp(new MyApp());

ThemeData theme =
    new ThemeData(primaryColor: Colors.black, backgroundColor: Colors.white10);

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Image transformer',
      theme: theme,
      home: Home(),
    );
  }
}

class Home extends StatelessWidget {
  final _bloc = ImageBloc();

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: Text("Image transformer"),
      ),
      body: StreamBuilder<ImageState>(
          stream: _bloc.state(),
          builder: (context, snap) {
            if (snap.hasData) {
              if (snap.data is ImageInitial) {
                return Container(
                  child: Center(
                    child: RaisedButton(
                      color: Colors.red,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6.0)),
                      child: Text("Загрузить изображение",
                          style: TextStyle(fontSize: 16, color: Colors.white)),
                      onPressed: () {
                        _bloc.submitEvent(Open());
                      },
                    ),
                  ),
                );
              } else if (snap.data is ImageLoaded) {
                return Center(
                    child: Image(image: (snap.data as ImageLoaded).image));
              } else {
                return Center(child: CircularProgressIndicator());
              }
            } else {
              return Text("ERROR");
            }
          }),
    );
  }
}
