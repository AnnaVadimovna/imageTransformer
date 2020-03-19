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
                return FlatButton(
                    onPressed: () {
                      _bloc.submitEvent(Open());
                    },
                    child: Text("Press me"));
              } else if (snap.data is ImageLoaded) {
                return Image(image: (snap.data as ImageLoaded).image);
              } else {
                return CircularProgressIndicator();
              }
            } else {
              return Text("ERROR");
            }
          }),
    );
  }
}
