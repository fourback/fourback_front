import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'auth.dart';

// 간단한 메모리 캐시
class ImageCacheManager {
  static final Map<String, Uint8List> _cache = {};

  static Uint8List? get(String url) => _cache[url];

  static void set(String url, Uint8List data) {
    _cache[url] = data;
  }
}

class PublicImage extends StatefulWidget {
  final String imageUrl;
  final String placeholderPath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final bool isCircular;

  PublicImage({
    required this.imageUrl,
    required this.placeholderPath,
    this.width,
    this.height,
    required this.fit,
    this.isCircular = false,
    Key? key,
  }) : super(key: key);

  @override
  _PublicImageState createState() => _PublicImageState();
}

class _PublicImageState extends State<PublicImage> {
  late Future<Uint8List> _imageData;

  @override
  void initState() {
    super.initState();
    _imageData = _loadImage();
  }

  @override
  void didUpdateWidget(PublicImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.imageUrl != oldWidget.imageUrl) {
      _imageData = _loadImage();
    }
  }

  Future<Uint8List> ㅋ_loadImage() async {
    // 캐시에서 이미지를 먼저 확인합니다.
    final cachedImage = ImageCacheManager.get(widget.imageUrl);
    if (cachedImage != null) {
      // 캐시된 데이터가 유효한지 추가 검증할 수 있습니다.
      return cachedImage;
    }

    final token = await readAccess();
    if (token == null) {
      throw Exception('Token not found');
    }

    final response = await http.get(
      Uri.parse(widget.imageUrl),
      headers: {
        'access': '$token',
      },
    );

    if (response.statusCode == 200) {
      final imageData = response.bodyBytes;
      // 이미지 데이터가 올바른지 간단히 확인 (예: 크기 검사)
      if (imageData.isNotEmpty) {
        ImageCacheManager.set(widget.imageUrl, imageData);
        return imageData;
      } else {
        throw Exception('Received empty image data');
      }
    } else if (response.statusCode == 401) {
      bool success = await reissueToken(context);
      if (success) {
        return await _loadImage();
      } else {
        throw Exception('Failed to reissue token');
      }
    } else {
      throw Exception('Failed to load image, status code: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List>(
      future: _imageData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Image.asset(
            widget.placeholderPath,
            width: widget.width,
            height: widget.height,
            fit: widget.fit,
          );
        } else if (snapshot.hasError) {
          // 상세한 오류 로그를 남깁니다.
          print('Image loading error: ${snapshot.error}');
          return Icon(Icons.error); // 오류 발생 시 표시할 아이콘
        } else if (snapshot.hasData) {
          return widget.isCircular
              ? ClipOval(
            child: Image.memory(
              snapshot.data!,
              width: widget.width,
              height: widget.height,
              fit: widget.fit,
            ),
          )
              : Image.memory(
            snapshot.data!,
            width: widget.width,
            height: widget.height,
            fit: widget.fit,
          );
        } else {
          return Icon(Icons.error);
        }
      },
    );
  }
}