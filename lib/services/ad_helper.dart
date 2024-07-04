import 'dart:io';
class AdHelper{
  static String homePageBanner(){
    if(Platform.isAndroid){
    return "ca-app-pub-9117081028183448/4161653315";
    }
    else{
      return "";
    }
  }

  static String fullPageAD(){
    if(Platform.isAndroid){
    return "ca-app-pub-9117081028183448/2601159636";
    }
    else{
      return "";
    }
  }
}