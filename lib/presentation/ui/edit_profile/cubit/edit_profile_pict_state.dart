part of 'edit_profile_pict_cubit.dart';

enum EditProfilePicStatus { initial, loading, error, success }

class EditProfilePictState extends Equatable {
  final EditProfilePicStatus status;
  final File? imageFile;
  const EditProfilePictState({required this.status, this.imageFile});

  @override
  List<Object?> get props => [status, imageFile];
}
