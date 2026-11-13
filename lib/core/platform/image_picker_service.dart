import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

/// 사진을 가져오는 곳.
enum PhotoSource { camera, gallery }

/// 사진을 가져오지 못한 이유(권한 거부, 카메라 없음 등). 화면은 문구만 보여 준다.
class PhotoPickException implements Exception {
  const PhotoPickException(this.source);

  final PhotoSource source;
}

/// 갤러리·카메라에서 사진 한 장을 고르는 서비스. 테스트에서는 가짜로 바꿔 끼운다.
/// 취소하면 null, 못 가져오면 [PhotoPickException].
abstract interface class ImagePickerService {
  Future<String?> pick(PhotoSource source);
}

/// `image_picker` 패키지로 만든 실제 구현. 큰 사진은 줄여서(긴 변 1024) 가져온다.
class DeviceImagePickerService implements ImagePickerService {
  DeviceImagePickerService([ImagePicker? picker])
    : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  @override
  Future<String?> pick(PhotoSource source) async {
    try {
      final file = await _picker.pickImage(
        source: source == PhotoSource.camera
            ? ImageSource.camera
            : ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      return file?.path;
    } on PlatformException {
      throw PhotoPickException(source);
    }
  }
}
