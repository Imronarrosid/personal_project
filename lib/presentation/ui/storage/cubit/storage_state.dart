part of 'storage_cubit.dart';

enum StorageStatus { initial, loading, loaded, error }

final class StorageState extends Equatable {
  final StorageStatus status;
  final String? size;
  const StorageState({
    required this.status,
    this.size,
  });

  @override
  List<Object?> get props => [status, size];
}

final class StorageInitial extends StorageState {
  const StorageInitial({required super.status});
}
