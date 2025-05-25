// lib/features/inventory/data/inventory_api_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart'; // Required for MediaType

import '../models/acquisition_model.dart';

class InventoryApiService {
  // TODO: Make this configurable, possibly through an environment variable or a DI system.
  // For Android emulator, 10.0.2.2 typically points to the host machine's localhost.
  // For iOS simulator, localhost or 127.0.0.1 usually works directly.
  final String _baseUrl = Platform.isAndroid ? 'http://10.0.2.2:8000' : 'http://localhost:8000';

  Future<List<Acquisition>> getAcquisitions() async {
    final response = await http.get(Uri.parse('$_baseUrl/acquisitions/'));

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      List<Acquisition> acquisitions = body.map((dynamic item) => Acquisition.fromJson(item)).toList();
      return acquisitions;
    } else {
      // Log error: response.body or response.reasonPhrase
      throw Exception('Failed to load acquisitions. Status: ${response.statusCode}');
    }
  }

  Future<Acquisition> getAcquisitionById(String id) async {
    final response = await http.get(Uri.parse('$_baseUrl/acquisitions/$id'));

    if (response.statusCode == 200) {
      return Acquisition.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 404) {
      throw Exception('Acquisition not found. Status: ${response.statusCode}');
    } else {
      // Log error
      throw Exception('Failed to load acquisition $id. Status: ${response.statusCode}');
    }
  }

  Future<Acquisition> createAcquisition(Acquisition acquisitionData, File? imageFile) async {
    var request = http.MultipartRequest('POST', Uri.parse('$_baseUrl/acquisitions/'));
    
    request.fields['name'] = acquisitionData.name;
    request.fields['description'] = acquisitionData.description;
    request.fields['dateAcquired'] = acquisitionData.dateAcquired.toIso8601String();
    request.fields['source'] = acquisitionData.source;
    request.fields['tags'] = acquisitionData.tags.join(',');

    if (imageFile != null) {
      final mimeType = lookupMimeType(imageFile.path);
      request.files.add(
        await http.MultipartFile.fromPath(
          'image', // This 'image' field name must match the backend (FastAPI File parameter name)
          imageFile.path,
          contentType: MediaType.parse(mimeType ?? 'application/octet-stream'),
        ),
      );
    } else {
      // Backend expects an image, so this case might need specific handling
      // or the backend API should allow creation without an image.
      // For now, assuming image is mandatory as per typical create operations.
      // If image is optional on backend, this is fine.
      // If image is mandatory, backend will return an error.
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 201) { // HTTP 201 Created
      return Acquisition.fromJson(jsonDecode(response.body));
    } else {
      // Log error: response.body
      throw Exception('Failed to create acquisition. Status: ${response.statusCode}, Body: ${response.body}');
    }
  }

  Future<Acquisition> updateAcquisition(String id, Acquisition acquisitionData, File? imageFile) async {
    var request = http.MultipartRequest('PUT', Uri.parse('$_baseUrl/acquisitions/$id'));

    // Add fields that are present in acquisitionData.
    // The backend PUT expects optional fields.
    // Using toJsonForUpsert or similar which excludes id and possibly imageUrl.
    Map<String, dynamic> fieldsToUpdate = acquisitionData.toJsonForUpsert();

    fieldsToUpdate.forEach((key, value) {
      if (value is List) { // Specifically for tags
          request.fields[key] = (value as List<String>).join(',');
      } else if (value != null) {
          request.fields[key] = value.toString();
      }
    });
    
    // Override fields from toJsonForUpsert if they are explicitly part of the model for update
    // This ensures correct formatting, e.g. for date.
    request.fields['name'] = acquisitionData.name; // Assuming name is always part of the update/model
    request.fields['description'] = acquisitionData.description;
    request.fields['dateAcquired'] = acquisitionData.dateAcquired.toIso8601String();
    request.fields['source'] = acquisitionData.source;
    request.fields['tags'] = acquisitionData.tags.join(',');


    if (imageFile != null) {
      final mimeType = lookupMimeType(imageFile.path);
      request.files.add(
        await http.MultipartFile.fromPath(
          'image', // Must match backend parameter name
          imageFile.path,
          contentType: MediaType.parse(mimeType ?? 'application/octet-stream'),
        ),
      );
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return Acquisition.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 404) {
       throw Exception('Acquisition $id not found for update. Status: ${response.statusCode}, Body: ${response.body}');
    }
    else {
      // Log error
      throw Exception('Failed to update acquisition $id. Status: ${response.statusCode}, Body: ${response.body}');
    }
  }

  Future<void> deleteAcquisition(String id) async {
    final response = await http.delete(Uri.parse('$_baseUrl/acquisitions/$id'));

    if (response.statusCode == 204) { // HTTP 204 No Content
      return; // Successfully deleted
    } else if (response.statusCode == 404) {
      throw Exception('Acquisition $id not found for deletion. Status: ${response.statusCode}, Body: ${response.body}');
    } else {
      // Log error
      throw Exception('Failed to delete acquisition $id. Status: ${response.statusCode}, Body: ${response.body}');
    }
  }
}
