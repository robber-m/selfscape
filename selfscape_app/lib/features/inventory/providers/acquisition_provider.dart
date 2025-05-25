// lib/features/inventory/providers/acquisition_provider.dart
import 'dart:io'; // For File type
import 'package:flutter/foundation.dart'; // For ChangeNotifier

import '../models/acquisition_model.dart';
import '../data/inventory_api_service.dart';

class AcquisitionProvider with ChangeNotifier {
  final InventoryApiService _apiService;

  List<Acquisition> _acquisitions = [];
  bool _isLoading = false;
  bool _isItemLoading = false; // For single item operations (create, update, delete)
  String? _error;

  // Getters
  List<Acquisition> get acquisitions => _acquisitions;
  bool get isLoading => _isLoading;
  bool get isItemLoading => _isItemLoading;
  String? get error => _error;

  // Constructor
  AcquisitionProvider(this._apiService) {
    fetchAcquisitions(); // Initial fetch when provider is created
  }

  Future<void> fetchAcquisitions() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _acquisitions = await _apiService.getAcquisitions();
      _error = null;
    } catch (e) {
      _acquisitions = [];
      _error = e.toString();
      // In a real app, distinguish between error types or use a custom error object
      print('Error fetching acquisitions: $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Primarily fetches from local cache.
  // Optional: Implement API call as fallback if not found locally and needed.
  Acquisition? getAcquisitionById(String id) {
    try {
      return _acquisitions.firstWhere((acq) => acq.id == id);
    } catch (e) { // firstWhere throws StateError if no element is found
      // Optionally, trigger an API call here if specific item fetching is desired
      // print('Acquisition with id $id not found in local cache.');
      return null;
    }
  }

  // Example of fetching a single item from API if not in cache (more complex state)
  // Future<Acquisition?> fetchAcquisitionByIdIfNotInCache(String id) async {
  //   var existing = getAcquisitionById(id);
  //   if (existing != null) return existing;

  //   // _isItemLoading = true; // Or a specific loader for single item
  //   // _error = null;
  //   // notifyListeners();
  //   try {
  //     final acquisition = await _apiService.getAcquisitionById(id);
  //     // Optionally add to _acquisitions list if you want to cache it
  //     // _acquisitions.add(acquisition); 
  //     // notifyListeners();
  //     return acquisition;
  //   } catch (e) {
  //     _error = e.toString();
  //     // notifyListeners(); // If you want to show this error globally
  //     return null;
  //   } finally {
  //     // _isItemLoading = false;
  //     // notifyListeners();
  //   }
  // }

  Future<bool> createAcquisition(Acquisition acquisitionData, File? imageFile) async {
    _isItemLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newAcquisition = await _apiService.createAcquisition(acquisitionData, imageFile);
      _acquisitions.add(newAcquisition); // Add to the start or end depending on desired order
      _error = null;
      return true;
    } catch (e) {
      _error = e.toString();
      print('Error creating acquisition: $_error');
      return false;
    } finally {
      _isItemLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateAcquisition(String id, Acquisition acquisitionData, File? imageFile) async {
    _isItemLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedAcquisition = await _apiService.updateAcquisition(id, acquisitionData, imageFile);
      final index = _acquisitions.indexWhere((acq) => acq.id == id);
      if (index != -1) {
        _acquisitions[index] = updatedAcquisition;
        _error = null;
      } else {
        // Should not happen if ID is valid and item was fetched
        _error = "Failed to find item in local cache after update.";
        print(_error);
        // Optionally, re-fetch all to sync state if this happens
        return false;
      }
      return true;
    } catch (e) {
      _error = e.toString();
      print('Error updating acquisition: $_error');
      return false;
    } finally {
      _isItemLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteAcquisition(String id) async {
    _isItemLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _apiService.deleteAcquisition(id);
      _acquisitions.removeWhere((acq) => acq.id == id);
      _error = null;
      return true;
    } catch (e) {
      _error = e.toString();
      print('Error deleting acquisition: $_error');
      return false;
    } finally {
      _isItemLoading = false;
      notifyListeners();
    }
  }
}
