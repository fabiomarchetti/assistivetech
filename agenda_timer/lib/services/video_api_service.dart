import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/video_educatore.dart';

class VideoApiService {
  // URL relativo - funziona sempre sul dominio corrente
  static const String _apiEndpoint = '/agenda_timer/api/api_video_educatore.php';

  // Headers standard per le richieste
  static const Map<String, String> _headers = {
    'Content-Type': 'application/json; charset=utf-8',
    'Accept': 'application/json',
  };

  // Ottieni tutti i video
  Future<List<VideoEducatore>> getAllVideo() async {
    try {
      final response = await http.get(
        Uri.parse('$_apiEndpoint?action=get_all_video'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true) {
          final List<dynamic> data = jsonResponse['data'] ?? [];
          return data.map((json) => VideoEducatore.fromJson(json)).toList();
        } else {
          throw Exception('API Error: ${jsonResponse['error']}');
        }
      } else {
        throw Exception('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Errore getAllVideo: $e');
      rethrow;
    }
  }

  // Ottieni video per utente specifico
  Future<List<VideoEducatore>> getVideoPerUtente(String nomeUtente) async {
    try {
      final response = await http.get(
        Uri.parse('$_apiEndpoint?action=get_video_per_utente&nome_utente=${Uri.encodeComponent(nomeUtente)}'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true) {
          final List<dynamic> data = jsonResponse['data'] ?? [];
          return data.map((json) => VideoEducatore.fromJson(json)).toList();
        } else {
          throw Exception('API Error: ${jsonResponse['error']}');
        }
      } else {
        throw Exception('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Errore getVideoPerUtente: $e');
      rethrow;
    }
  }

  // Ottieni video per agenda specifica
  Future<List<VideoEducatore>> getVideoPerAgenda(String nomeAgenda) async {
    try {
      final response = await http.get(
        Uri.parse('$_apiEndpoint?action=get_video_per_agenda&nome_agenda=${Uri.encodeComponent(nomeAgenda)}'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true) {
          final List<dynamic> data = jsonResponse['data'] ?? [];
          return data.map((json) => VideoEducatore.fromJson(json)).toList();
        } else {
          throw Exception('API Error: ${jsonResponse['error']}');
        }
      } else {
        throw Exception('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Errore getVideoPerAgenda: $e');
      rethrow;
    }
  }

  // Salva nuovo video
  Future<VideoEducatore> salvaVideo(VideoEducatore video) async {
    try {
      final Map<String, dynamic> requestBody = {
        'action': 'salva_video',
        'nome_video': video.nomeVideo,
        'categoria': video.categoria,
        'link_youtube': video.linkYoutube,
        'nome_agenda': video.nomeAgenda,
        'nome_utente': video.nomeUtente,
      };

      print('Invio richiesta salva video: $requestBody');

      final response = await http.post(
        Uri.parse(_apiEndpoint),
        headers: _headers,
        body: json.encode(requestBody),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true) {
          return VideoEducatore.fromJson(jsonResponse['data']);
        } else {
          throw Exception('API Error: ${jsonResponse['error']}');
        }
      } else {
        throw Exception('HTTP Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Errore salvaVideo: $e');
      rethrow;
    }
  }

  // Elimina video
  Future<void> eliminaVideo(int idVideo) async {
    try {
      final response = await http.delete(
        Uri.parse('$_apiEndpoint?action=elimina_video&id_video=$idVideo'),
        headers: _headers,
      );

      print('Delete response status: ${response.statusCode}');
      print('Delete response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] != true) {
          throw Exception('API Error: ${jsonResponse['error']}');
        }
      } else {
        throw Exception('HTTP Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Errore eliminaVideo: $e');
      rethrow;
    }
  }

  // Ottieni categorie disponibili
  Future<List<String>> getCategorie() async {
    try {
      final response = await http.get(
        Uri.parse('$_apiEndpoint?action=get_categorie'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true) {
          final List<dynamic> data = jsonResponse['data'] ?? [];
          return data.map((item) => item['categoria'].toString()).toList();
        } else {
          throw Exception('API Error: ${jsonResponse['error']}');
        }
      } else {
        throw Exception('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Errore getCategorie: $e');
      return []; // Restituisce lista vuota in caso di errore
    }
  }
}