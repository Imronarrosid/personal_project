part of 'edit_profile_pict_cubit.dart';

enum EditProfilePicStatus { initial, loading, error, success }

class EditProfilePictState extends Equatable {
  final EditProfilePicStatus status;
  final String? imageUrl;
  const EditProfilePictState({required this.status, this.imageUrl});

  @override
  List<Object?> get props => [status, imageUrl];
}
