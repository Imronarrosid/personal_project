part of 'files_bloc.dart';

sealed class FilesEvent extends Equatable {
  const FilesEvent();

  @override
  List<Object> get props => [];
}

class LoadFilesEvent extends FilesEvent {}
