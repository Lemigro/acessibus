import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Serviço para buscar rotas usando Google Directions API
class DirectionsService {
  static const String _baseUrl = 'https://maps.googleapis.com/maps/api/directions/json';
  
  // TODO: Usar a mesma chave de API do Google Maps
  // Em produção, use variável de ambiente ou configuração segura
  final String apiKey = 'AIzaSyAJUIqYIgOjI2TVd096SPe9OcT7FGQpWRc';

  /// Busca rota entre dois pontos usando Google Directions API
  /// 
  /// [origin] - Ponto de origem (latitude, longitude)
  /// [destination] - Ponto de destino (latitude, longitude)
  /// [waypoints] - Pontos intermediários (opcional)
  /// [travelMode] - Modo de viagem: 'driving', 'walking', 'transit', 'bicycling'
  Future<DirectionsResult?> getRoute({
    required LatLng origin,
    required LatLng destination,
    List<LatLng>? waypoints,
    String travelMode = 'transit', // Padrão transporte público
  }) async {
    try {
      // Construir URL
      String url = '$_baseUrl?origin=${origin.latitude},${origin.longitude}';
      url += '&destination=${destination.latitude},${destination.longitude}';
      url += '&mode=$travelMode';
      url += '&key=$apiKey';
      
      // Adicionar waypoints se houver
      if (waypoints != null && waypoints.isNotEmpty) {
        String waypointsStr = waypoints
            .map((w) => '${w.latitude},${w.longitude}')
            .join('|');
        url += '&waypoints=$waypointsStr';
      }

      // Fazer requisição
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'OK' && data['routes'].isNotEmpty) {
          return DirectionsResult.fromJson(data['routes'][0]);
        } else {
          print('Erro na API: ${data['status']}');
          return null;
        }
      } else {
        print('Erro HTTP: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Erro ao buscar rota: $e');
      return null;
    }
  }

  /// Busca rota simplificada (apenas pontos para desenhar polyline)
  Future<List<LatLng>?> getRoutePoints({
    required LatLng origin,
    required LatLng destination,
    List<LatLng>? waypoints,
    String travelMode = 'transit',
  }) async {
    final result = await getRoute(
      origin: origin,
      destination: destination,
      waypoints: waypoints,
      travelMode: travelMode,
    );
    
    return result?.points;
  }
}

/// Resultado da busca de rota
class DirectionsResult {
  final List<LatLng> points;
  final String? distance;
  final String? duration;
  final LatLngBounds? bounds;

  DirectionsResult({
    required this.points,
    this.distance,
    this.duration,
    this.bounds,
  });

  factory DirectionsResult.fromJson(Map<String, dynamic> json) {
    // Decodificar polyline
    List<LatLng> points = [];
    if (json['overview_polyline'] != null) {
      points = _decodePolyline(json['overview_polyline']['points']);
    }

    // Obter distância e duração da primeira perna
    String? distance;
    String? duration;
    if (json['legs'] != null && json['legs'].isNotEmpty) {
      final leg = json['legs'][0];
      distance = leg['distance']?['text'];
      duration = leg['duration']?['text'];
    }

    // Obter bounds
    LatLngBounds? bounds;
    if (json['bounds'] != null) {
      final b = json['bounds'];
      bounds = LatLngBounds(
        southwest: LatLng(
          b['southwest']['lat'],
          b['southwest']['lng'],
        ),
        northeast: LatLng(
          b['northeast']['lat'],
          b['northeast']['lng'],
        ),
      );
    }

    return DirectionsResult(
      points: points,
      distance: distance,
      duration: duration,
      bounds: bounds,
    );
  }

  /// Decodifica polyline do Google Maps
  static List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0;
    int len = encoded.length;
    int lat = 0;
    int lng = 0;

    while (index < len) {
      int b;
      int shift = 0;
      int result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0) ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0) ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      points.add(LatLng(lat / 1e5, lng / 1e5));
    }

    return points;
  }
}

