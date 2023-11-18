part of 'edit_bio_cubit.dart';

enum EditBioStatus { initial, loading, succes, error }

class EditBioState extends Equatable {
  final EditBioStatus status;
  final String? bio;
  const EditBioState({required this.status, this.bio});

  @override
  List<Object?> get props => [status, bio];
}
