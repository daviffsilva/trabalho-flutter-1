import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../config/app_config.dart';

class PlacesService {
  static String get _apiKey => AppConfig.googleMapsApiKey;
  static String get _baseUrl => AppConfig.googleMapsBaseUrl;

  Future<List<PlacePrediction>> searchPlaces(String input) async {
    if (input.isEmpty) return [];

    try {
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/place/autocomplete/json?input=$input&key=$_apiKey&language=pt-BR&components=country:br'
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'OK') {
          final predictions = data['predictions'] as List;
          return predictions.map((prediction) => PlacePrediction.fromJson(prediction)).toList();
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<LatLng?> getPlaceCoordinates(String placeId) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/place/details/json?place_id=$placeId&fields=geometry&key=$_apiKey'
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'OK') {
          final result = data['result'];
          final geometry = result['geometry'];
          final location = geometry['location'];
          
          return LatLng(
            location['lat'].toDouble(),
            location['lng'].toDouble(),
          );
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<LatLng?> geocodeAddress(String address) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/geocode/json?address=${Uri.encodeComponent(address)}&key=$_apiKey&language=pt-BR&region=br'
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          final result = data['results'][0];
          final geometry = result['geometry'];
          final location = geometry['location'];
          
          return LatLng(
            location['lat'].toDouble(),
            location['lng'].toDouble(),
          );
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}

class PlacePrediction {
  final String placeId;
  final String description;
  final String mainText;
  final String secondaryText;

  PlacePrediction({
    required this.placeId,
    required this.description,
    required this.mainText,
    required this.secondaryText,
  });

  factory PlacePrediction.fromJson(Map<String, dynamic> json) {
    final structuredFormatting = json['structured_formatting'] ?? {};
    
    return PlacePrediction(
      placeId: json['place_id'] ?? '',
      description: json['description'] ?? '',
      mainText: structuredFormatting['main_text'] ?? '',
      secondaryText: structuredFormatting['secondary_text'] ?? '',
    );
  }
} 