part of 'edit_profile_pict_cubit.dart';

enum EditProfilePicStatus { initial, loading, error, success }

class EditProfilePictState extends Equatable {
  final EditProfilePicStatus status;
  const EditProfilePictState({
    required this.status,
  });

  @override
  List<Object> get props => [
        status,
      ];
}
