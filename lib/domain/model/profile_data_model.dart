class ProfileData {
  final String name;
  final String userName;
  final String bio;
  final String photoUrl;
  final List<String> gameFavoritesId;

  ProfileData(
      {required this.userName,
      required this.photoUrl,
      required this.name,
      required this.bio,
      required this.gameFavoritesId});
}
