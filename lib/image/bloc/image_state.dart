part of 'image_bloc.dart';

@immutable
abstract class ImageState {}

class ImageInitial extends ImageState {}

class ImageProgress extends ImageState {}

class ImageLoaded extends ImageState {
  final ImageProvider image;
  ImageLoaded(this.image);
}
