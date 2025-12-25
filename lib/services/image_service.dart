class ImageService {
  static const String _placeholderBase = 'https://picsum.photos';
  
  /// Get a placeholder image URL for development
  static String getPlaceholderImage({
    int width = 400,
    int height = 300,
    int? seed,
    bool grayscale = false,
    bool blur = false,
  }) {
    String url = '$_placeholderBase/$width/$height';
    
    List<String> params = [];
    
    if (seed != null) {
      url += '?random=$seed';
    }
    
    if (grayscale) {
      params.add('grayscale');
    }
    
    if (blur) {
      params.add('blur');
    }
    
    if (params.isNotEmpty) {
      String separator = url.contains('?') ? '&' : '?';
      url += '$separator${params.join('&')}';
    }
    
    return url;
  }
  
  /// Get room placeholder images
  static String getRoomPlaceholder(String roomType, {int width = 400, int height = 300}) {
    // Use consistent seeds for room types
    int seed = roomType.hashCode.abs() % 1000;
    return getPlaceholderImage(width: width, height: height, seed: seed);
  }
  
  /// Get hotel placeholder images
  static String getHotelPlaceholder(String hotelId, {int width = 600, int height = 400}) {
    int seed = hotelId.hashCode.abs() % 1000;
    return getPlaceholderImage(width: width, height: height, seed: seed);
  }
}