import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'video_size_state.dart';

class VideoSizeCubit extends Cubit<VideoSizeState> {
  VideoSizeCubit() : super(VideoSizeInitial());

/// this for adjust bottom pading video
/// size is from comments sheet size not actual video size
/// 
/// now this event call ond comment height changed
/// on open comment view and close comment view
  changeVideoSize(double size) {
    emit(
      VideoSizeChanged(size: size),
    );
  }
}
