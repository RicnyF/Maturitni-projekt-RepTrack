

import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rep_track/utils/logger.dart';

class StorageService with ChangeNotifier{
List<String> _imageUrls = [];

bool _isLoading = false;

bool _isUploading = false;


List<String> get imageUrls => _imageUrls;
bool get isLoading => _isLoading;
bool get isUploading => _isUploading;


Future<void> fetchImages() async{
_isLoading = true;

final ListResult result = await FirebaseStorage.instance.ref('uploaded_images/').listAll();

final urls= await Future.wait(result.items.map((ref) => ref.getDownloadURL()));
  _imageUrls= urls;
  _isLoading = false;
  notifyListeners();
}

Future<void> deleteImages(String imageUrl)async{
  AppLogger.logInfo("Attempting to delete image...");

  try{
    _imageUrls.remove(imageUrl);
    final String path= extractPathFromUrl(imageUrl);
    await FirebaseStorage.instance.ref(path).delete();
      AppLogger.logInfo("Image deleted successfully...");

  }
  on FirebaseAuthException catch(e, stackTrace){
      AppLogger.logError("Failed to delete image.", e, stackTrace);
    notifyListeners();
  }
}
String extractPathFromUrl(String url){
  Uri uri = Uri.parse(url);
  String encodedPath = uri.pathSegments.last;
  return Uri.decodeComponent(encodedPath);
}
Future<void> uploadImage()async{
    AppLogger.logInfo("Attempting to upload image...");

  _isUploading = true;
  notifyListeners();
  final ImagePicker picker = ImagePicker();
  final XFile? image= await picker.pickImage(source: ImageSource.gallery);
  if (image==null) return;
  File file = File(image.path);
  try {
    String filePath = 'uploaded_images/${DateTime.now()}';
    await FirebaseStorage.instance.ref(filePath).putFile(file);
    String downloadUrl = await FirebaseStorage.instance.ref(filePath).getDownloadURL();
    _imageUrls.add(downloadUrl);
    notifyListeners();

  }
  on FirebaseAuthException catch(e, stackTrace){
      AppLogger.logError("Failed to update image.", e, stackTrace);
  }
  finally{
    _isUploading = false;
    notifyListeners();
    AppLogger.logInfo("Image uploaded successfully...");

  }
}

}