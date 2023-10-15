part of 'files_bloc.dart';

sealed class FilesState extends Equatable {
  const FilesState();

  @override
  List<Object> get props => [];
}

final class FilesInitial extends FilesState {}

final class FileLoaded extends FilesState {
  final List<String> listFile;
  const FileLoaded(this.listFile);

  @override
  List<Object> get props => [listFile];
}
