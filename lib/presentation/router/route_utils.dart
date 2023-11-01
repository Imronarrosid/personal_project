// ignore_for_file: camel_case_types

enum APP_PAGE {
  splash,
  login,
  home,
  upload,
  error,
  profile,
  onBoarding,
  videoPreview,
  videoEditor,
  addDetails
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
