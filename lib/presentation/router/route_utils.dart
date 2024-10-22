// ignore_for_file: camel_case_types, constant_identifier_names

enum APP_PAGE {
  splash,
  login,
  home,
  forYou,
  search,
  chat,
  message,
  upload,
  error,
  profile,
  onBoarding,
  videoPreview,
  videoEditor,
  addDetails,
  editProfile,
  editName,
  cropImage,
  menu,
  addGameFav,
  editGameFav,
  videoItem,
  cachesPage,
  languagePage,
  addUserName,
  selectGame,
  videoFromGame,
  followingNFonllowers,
  searchRoom,
  category,
  selectCover,
  mabarChat,
  following,
  followers,
}

extension AppPageExtension on APP_PAGE {
  String get toPath {
    switch (this) {
      case APP_PAGE.home:
        return "/";
      case APP_PAGE.login:
        return "/login";
      case APP_PAGE.upload:
        return "/upload";
      case APP_PAGE.forYou:
        return "/foryou";
      case APP_PAGE.search:
        return "/search";
      case APP_PAGE.message:
        return "/message";
      case APP_PAGE.splash:
        return "/splash";
      case APP_PAGE.error:
        return "/error";
      case APP_PAGE.onBoarding:
        return "/start";
      case APP_PAGE.videoPreview:
        return "/video-preview";
      case APP_PAGE.videoEditor:
        return "/video-editor";
      case APP_PAGE.addDetails:
        return "/add-details";
      case APP_PAGE.profile:
        return "/profile";
      case APP_PAGE.editProfile:
        return "/edit";
      case APP_PAGE.editName:
        return "/name";
      case APP_PAGE.cropImage:
        return "/crop-image";
      case APP_PAGE.menu:
        return "/settings";
      case APP_PAGE.addGameFav:
        return "/add-game-fav";
      case APP_PAGE.editGameFav:
        return "/edit-game-fav";
      case APP_PAGE.selectGame:
        return "/select-game";
      case APP_PAGE.videoItem:
        return "/v";
      case APP_PAGE.cachesPage:
        return "/caches";
      case APP_PAGE.languagePage:
        return "/language";
      case APP_PAGE.addUserName:
        return "/add-username";
      case APP_PAGE.videoFromGame:
        return "/video-from-game";
      case APP_PAGE.followingNFonllowers:
        return "/following-n-follwoers";
      case APP_PAGE.chat:
        return "/chat";
      case APP_PAGE.searchRoom:
        return "/search-room";
      case APP_PAGE.category:
        return "/category";
      case APP_PAGE.selectCover:
        return "/selec-cover";
      case APP_PAGE.mabarChat:
        return "/mabar";
      case APP_PAGE.following:
        return "/following";
      case APP_PAGE.followers:
        return "/followers";
      default:
        return "/";
    }
  }

  String get toName {
    switch (this) {
      case APP_PAGE.home:
        return "HOME";
      case APP_PAGE.login:
        return "LOGIN";
      case APP_PAGE.upload:
        return "UPLOAD";
      case APP_PAGE.forYou:
        return "FORYOU";
      case APP_PAGE.search:
        return "SEARCH";
      case APP_PAGE.message:
        return "Message";
      case APP_PAGE.splash:
        return "SPLASH";
      case APP_PAGE.error:
        return "ERROR";
      case APP_PAGE.onBoarding:
        return "START";
      case APP_PAGE.videoPreview:
        return "VIDEO_PREVIEW";
      case APP_PAGE.videoEditor:
        return "VIDEO_EDITOR";
      case APP_PAGE.addDetails:
        return "ADD-DETAILS";
      case APP_PAGE.profile:
        return "PROFILE";
      case APP_PAGE.editProfile:
        return "EDIT-POFILE";
      case APP_PAGE.editName:
        return "NAME";
      case APP_PAGE.cropImage:
        return "CROP";
      case APP_PAGE.menu:
        return "SETTINGS";
      case APP_PAGE.addGameFav:
        return "ADD-GAME-FAV";
      case APP_PAGE.editGameFav:
        return "EDIT-GAME-FAV";
      case APP_PAGE.selectGame:
        return "SELECT-GAME";
      case APP_PAGE.videoItem:
        return "VIDEO-ITEM";
      case APP_PAGE.cachesPage:
        return "CACHES-PAGE";
      case APP_PAGE.languagePage:
        return "LANGUAGE";
      case APP_PAGE.addUserName:
        return "ADD-USERNAME";
      case APP_PAGE.videoFromGame:
        return "VIDEO-FROM-GAME";
      case APP_PAGE.followingNFonllowers:
        return "FOLLOWING-N-FOLLOWERS";
      case APP_PAGE.chat:
        return "CHAT";
      case APP_PAGE.searchRoom:
        return "SEARCH-ROOM";
      case APP_PAGE.category:
        return "CATEGORY";
      case APP_PAGE.selectCover:
        return "SC";
      case APP_PAGE.mabarChat:
        return "MABAR";
      case APP_PAGE.following:
        return "FOLLOWING";
      case APP_PAGE.followers:
        return "FOLLOWERS";
      default:
        return "HOME";
    }
  }

  String get toTitle {
    switch (this) {
      case APP_PAGE.home:
        return "My App";
      case APP_PAGE.login:
        return "My App Log In";
      case APP_PAGE.splash:
        return "My App Splash";
      case APP_PAGE.error:
        return "My App Error";
      case APP_PAGE.onBoarding:
        return "Welcome to My App";
      default:
        return "My App";
    }
  }
}
