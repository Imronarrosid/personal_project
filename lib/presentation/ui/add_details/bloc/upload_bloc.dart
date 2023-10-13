import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:personal_project/domain/reporsitory/video_repository.dart';

part 'upload_event.dart';
part 'upload_state.dart';

class UploadBloc extends Bloc<UploadEvent, UploadState> {
  UploadBloc(this.videoRepository) : super(UploadInitial()) {
    on<UploadVideoEvent>((event, emit) async {
      emit(Uploading());
      try {
        await videoRepository.uploapVideo(
            songName: 'tidak diketahui',
            caption: event.caption,
            videoPath: event.videoPath);
        emit(VideoUploaded());
      } catch (e) {
        emit(UploadError(e.toString()));
      }
    });
  }
  VideRepository videoRepository;
}
