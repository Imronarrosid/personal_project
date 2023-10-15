import 'package:bloc/bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:personal_project/data/repository/file_repository.dart';
import 'package:personal_project/domain/model/files_model.dart';

part 'files_event.dart';
part 'files_state.dart';

class FilesBloc extends Bloc<FilesEvent, FilesState> {
  FilesBloc(this.fileRepository) : super(FilesInitial()) {
    on<LoadFilesEvent>((event, emit) async {
      try {
        await fileRepository.listAllVideoFiles();
        emit(FileLoaded(fileRepository.videoPaths));
      } catch (e) {
        debugPrint(e.toString());
      }
    });
  }
  final FileRepository fileRepository;
}
