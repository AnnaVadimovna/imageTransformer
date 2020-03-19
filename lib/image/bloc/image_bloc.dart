import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:meta/meta.dart';
import 'dart:ui' as ui;

part 'image_event.dart';
part 'image_state.dart';

class ImageBloc {
  final _eventController = StreamController<ImageEvent>.broadcast(sync: true);

  submitEvent(ImageEvent event) {
    _eventController.sink.add(event);
  }

  Stream<ImageState> state() async* {
    yield ImageInitial();
    await for (var event in _eventController.stream) {
      if (event is Back) {
        yield ImageInitial();
      } else if (event is Open) {
        yield ImageProgress();
        final image = await _loadImage();
        final tranformed = await _transformImage(image);
        yield ImageLoaded(tranformed);
      }
    }
  }

  dispose() {
    _eventController.close();
  }

  Future<ui.Image> _loadImage() async {
    ByteData data = await rootBundle.load("assets/images/wide.jpg");
    var codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    var frame = await codec.getNextFrame();
    return frame.image;
  }

  _ImageTransformation calcTransformation(int originWidth, int originHeight) {
    final destinationSize = 1200.0;
    final destinationW2HRatio = 16 / 9;

    double intermediateHeight;
    double intermediateWidth;
    double scale;

    if (originWidth > originHeight) {
      intermediateWidth = destinationSize;
      scale = destinationSize / originWidth;
      intermediateHeight = originHeight * scale;
    } else {
      intermediateHeight = destinationSize;
      scale = destinationSize / originHeight;
      intermediateWidth = originWidth * scale;
    }

    double destHeight;
    double destWidth;
    Offset offset;
    final intermediateW2HRatio = intermediateWidth / intermediateHeight;
    if (intermediateW2HRatio >= destinationW2HRatio) {
      destHeight = intermediateHeight;
      destWidth = destHeight * destinationW2HRatio;
      offset = Offset((intermediateWidth - destWidth) / -2, 0);
    } else {
      destWidth = intermediateWidth;
      destHeight = destWidth / destinationW2HRatio;
      offset = Offset(0, (intermediateHeight - destHeight) / -2);
    }

    return _ImageTransformation(offset, scale, destWidth, destHeight);
  }

  Future<ImageProvider> _transformImage(ui.Image image) async {
    final trans = calcTransformation(image.width, image.height);
    var rect = new Rect.fromLTWH(0, 0, trans.destWidth, trans.destHeight);
    ui.PictureRecorder recorder = new ui.PictureRecorder();
    Canvas c = new Canvas(recorder);
    c.clipRect(rect);
    Paint paint = new Paint();

    c.scale(trans.scale);
    c.drawImage(image, trans.offset, paint);

    var picture = recorder.endRecording();
    final transformedImage = await picture.toImage(
        trans.destWidth.floor(), trans.destHeight.floor());
    final bd =
        await transformedImage.toByteData(format: ui.ImageByteFormat.png);
    return MemoryImage(bd.buffer.asUint8List());
  }
}

class _ImageTransformation {
  final Offset offset;
  final double scale;
  final double destWidth;
  final double destHeight;
  _ImageTransformation(
      this.offset, this.scale, this.destWidth, this.destHeight);
}
