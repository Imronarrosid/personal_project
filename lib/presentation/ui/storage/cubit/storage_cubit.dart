import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:personal_project/data/repository/file_repository.dart';

part 'storage_state.dart';

class StorageCubit extends Cubit<StorageState> {
  StorageCubit(this.repository)
      : super(const StorageInitial(
          status: StorageStatus.initial,
        ));

  void getCacheSize() async {
    try {
      emit(const StorageState(status: StorageStatus.loading));

      int size = await repository.getCacheSize();
      emit(StorageState(
          status: StorageStatus.loaded, size: repository.fileMBSize(size)));
    } catch (e) {
      emit(const StorageState(status: StorageStatus.error));
    }
  }

  void clearCache() async {
    try {
      await repository.clearCacheDir();
      emit(const StorageState(status: StorageStatus.loaded, size: '0'));
    } catch (e) {
      emit(const StorageState(status: StorageStatus.error));
    }
  }

  final FileRepository repository;
}
