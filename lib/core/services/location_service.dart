import 'dart:io';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Check and request location permissions
  static Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  // Get current location
  static Future<Position?> getCurrentLocation() async {
    final hasPermission = await _handleLocationPermission();
    
    if (!hasPermission) {
      return null;
    }

    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
  }

  // Save location to Firebase
  static Future<void> saveLocationToFirebase(Position position, String userId) async {
    try {
      // Get booking man ID from SharedPreferences
      String? bookingManId;
      try {
        final prefs = await SharedPreferences.getInstance();
        bookingManId = prefs.getString('booking_man_id');
      } catch (e) {
        print('Error loading booking man ID: $e');
      }

      final locationData = {
        'userId': userId,
        'bookingManId': bookingManId ?? 'unknown',
        'latitude': position.latitude,
        'longitude': position.longitude,
        'accuracy': position.accuracy,
        'altitude': position.altitude,
        'speed': position.speed,
        'heading': position.heading,
        'timestamp': FieldValue.serverTimestamp(),
        'address': await _getAddressFromCoordinates(position),
      };

      // Save to both collections for better tracking
      // 1. Save by userId (existing method)
      await _firestore
          .collection('user_locations')
          .doc(userId)
          .set(locationData, SetOptions(merge: true));

      // 2. Save by booking man ID for separate tracking
      if (bookingManId != null && bookingManId != 'unknown') {
        await _firestore
            .collection('booking_man_locations')
            .doc(bookingManId)
            .set(locationData, SetOptions(merge: true));
        
        print('Location saved to Firebase by BM ID: $bookingManId');
      }

      print('Location saved to Firebase: ${position.latitude}, ${position.longitude}');
    } catch (e) {
      print('Error saving location to Firebase: $e');
    }
  }

  // Get address from coordinates
  static Future<String> _getAddressFromCoordinates(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        return '${place.street}, ${place.locality}, ${place.administrativeArea}';
      }
      return 'Unknown Location';
    } catch (e) {
      print('Error getting address: $e');
      return 'Unknown Location';
    }
  }

  // Get user's last known location from Firebase
  static Future<Map<String, dynamic>?> getUserLocation(String userId) async {
    try {
      final doc = await _firestore
          .collection('user_locations')
          .doc(userId)
          .get();

      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      print('Error getting user location from Firebase: $e');
      return null;
    }
  }

  // Get all users' locations ordered by booking man ID
  static Future<List<Map<String, dynamic>>> getAllUsersLocations() async {
    try {
      final querySnapshot = await _firestore
          .collection('user_locations')
          .orderBy('bookingManId')
          .get();

      List<Map<String, dynamic>> locations = [];
      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        data['documentId'] = doc.id; // Add document ID for reference
        locations.add(data);
      }

      print('Retrieved ${locations.length} user locations ordered by booking man ID');
      return locations;
    } catch (e) {
      print('Error getting all users locations: $e');
      return [];
    }
  }

  // Get all unique booking man IDs with their latest locations
  static Future<List<Map<String, dynamic>>> getAllBookingManIdsWithLocations() async {
    try {
      // First try to get from the dedicated booking man locations collection
      final querySnapshot = await _firestore
          .collection('booking_man_locations')
          .orderBy('bookingManId')
          .get();

      List<Map<String, dynamic>> locations = [];
      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        data['documentId'] = doc.id;
        locations.add(data);
      }

      // If no data in dedicated collection, fall back to user_locations
      if (locations.isEmpty) {
        final userQuerySnapshot = await _firestore
            .collection('user_locations')
            .orderBy('bookingManId')
            .get();

        // Group by booking man ID and get the latest location for each
        Map<String, Map<String, dynamic>> bmIdGroups = {};
        
        for (var doc in userQuerySnapshot.docs) {
          final data = doc.data();
          final bookingManId = data['bookingManId'] ?? 'unknown';
          
          // If this BM ID doesn't exist or this location is newer, update it
          if (!bmIdGroups.containsKey(bookingManId) || 
              (data['timestamp'] != null && 
               (bmIdGroups[bookingManId]!['timestamp'] == null || 
                data['timestamp'].toDate().isAfter(bmIdGroups[bookingManId]!['timestamp'].toDate())))) {
            data['documentId'] = doc.id;
            bmIdGroups[bookingManId] = data;
          }
        }

        locations = bmIdGroups.values.toList();
      }

      locations.sort((a, b) => (a['bookingManId'] ?? '').compareTo(b['bookingManId'] ?? ''));

      print('Retrieved ${locations.length} unique booking man IDs with latest locations');
      return locations;
    } catch (e) {
      print('Error getting booking man IDs with locations: $e');
      return [];
    }
  }

  // Get specific booking man ID location
  static Future<Map<String, dynamic>?> getBookingManIdLocation(String bookingManId) async {
    try {
      // First try to get from the dedicated booking man locations collection
      final doc = await _firestore
          .collection('booking_man_locations')
          .doc(bookingManId)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        data['documentId'] = doc.id;
        return data;
      }

      // Fall back to user_locations collection
      final querySnapshot = await _firestore
          .collection('user_locations')
          .where('bookingManId', isEqualTo: bookingManId)
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final data = querySnapshot.docs.first.data();
        data['documentId'] = querySnapshot.docs.first.id;
        return data;
      }
      return null;
    } catch (e) {
      print('Error getting booking man ID location: $e');
      return null;
    }
  }

  // Get users by booking man ID range
  static Future<List<Map<String, dynamic>>> getUsersByBookingManIdRange(String startId, String endId) async {
    try {
      // First try to get from the dedicated booking man locations collection
      final querySnapshot = await _firestore
          .collection('booking_man_locations')
          .where('bookingManId', isGreaterThanOrEqualTo: startId)
          .where('bookingManId', isLessThanOrEqualTo: endId)
          .orderBy('bookingManId')
          .get();

      List<Map<String, dynamic>> locations = [];
      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        data['documentId'] = doc.id;
        locations.add(data);
      }

      // If no data in dedicated collection, fall back to user_locations
      if (locations.isEmpty) {
        final userQuerySnapshot = await _firestore
            .collection('user_locations')
            .where('bookingManId', isGreaterThanOrEqualTo: startId)
            .where('bookingManId', isLessThanOrEqualTo: endId)
            .orderBy('bookingManId')
            .get();

        for (var doc in userQuerySnapshot.docs) {
          final data = doc.data();
          data['documentId'] = doc.id;
          locations.add(data);
        }
      }

      print('Retrieved ${locations.length} users in booking man ID range $startId to $endId');
      return locations;
    } catch (e) {
      print('Error getting users by booking man ID range: $e');
      return [];
    }
  }

  // Get all active booking man IDs being tracked
  static Future<List<String>> getAllActiveBookingManIds() async {
    try {
      final querySnapshot = await _firestore
          .collection('booking_man_locations')
          .get();

      List<String> bookingManIds = [];
      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final bookingManId = data['bookingManId']?.toString();
        if (bookingManId != null && bookingManId != 'unknown') {
          bookingManIds.add(bookingManId);
        }
      }

      // If no data in dedicated collection, get from user_locations
      if (bookingManIds.isEmpty) {
        final userQuerySnapshot = await _firestore
            .collection('user_locations')
            .get();

        Set<String> uniqueIds = {};
        for (var doc in userQuerySnapshot.docs) {
          final data = doc.data();
          final bookingManId = data['bookingManId']?.toString();
          if (bookingManId != null && bookingManId != 'unknown') {
            uniqueIds.add(bookingManId);
          }
        }
        bookingManIds = uniqueIds.toList();
      }

      bookingManIds.sort();
      print('Retrieved ${bookingManIds.length} active booking man IDs');
      return bookingManIds;
    } catch (e) {
      print('Error getting active booking man IDs: $e');
      return [];
    }
  }

  // Track location continuously
  static Stream<Position> getLocationStream() {
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // Update every 10 meters
    );

    return Geolocator.getPositionStream(locationSettings: locationSettings);
  }

  static StreamSubscription<Position>? _locationSubscription;

  // Save location periodically
  static Future<void> startLocationTracking(String userId) async {
    // Stop any existing tracking
    await stopLocationTracking();
    
    _locationSubscription = getLocationStream().listen((Position position) async {
      await saveLocationToFirebase(position, userId);
    });
    
    // print('✅ Location tracking started automatically for user: $userId');
  }

  // Start location tracking for any user (for automatic tracking)
  static Future<void> startAutomaticLocationTracking(String userId) async {
    try {
      // Get current location first
      final position = await getCurrentLocation();
      if (position != null) {
        await saveLocationToFirebase(position, userId);
        // print('✅ Initial location saved for user: $userId');
      }
      
      // Start continuous tracking
      await startLocationTracking(userId);
    } catch (e) {
      print('❌ Error starting automatic location tracking for user $userId: $e');
    }
  }

  // Stop location tracking
  static Future<void> stopLocationTracking() async {
    if (_locationSubscription != null) {
      await _locationSubscription!.cancel();
      _locationSubscription = null;
      // print('Location tracking stopped');
    }
  }

  // Debug: Show Firebase structure for booking man tracking
  static Future<void> debugBookingManTracking() async {
    try {
      print('=== DEBUG: Booking Man Tracking Structure ===');
      
      // Check booking_man_locations collection
      final bmQuery = await _firestore.collection('booking_man_locations').get();
      print('📊 booking_man_locations collection: ${bmQuery.docs.length} documents');
      for (var doc in bmQuery.docs) {
        final data = doc.data();
        print('  - BM ID: ${data['bookingManId']} | User: ${data['userId']} | Location: ${data['latitude']}, ${data['longitude']}');
      }
      
      // Check user_locations collection
      final userQuery = await _firestore.collection('user_locations').get();
      print('📊 user_locations collection: ${userQuery.docs.length} documents');
      for (var doc in userQuery.docs) {
        final data = doc.data();
        print('  - User: ${doc.id} | BM ID: ${data['bookingManId']} | Location: ${data['latitude']}, ${data['longitude']}');
      }
      
      print('=== END DEBUG ===');
    } catch (e) {
      print('Error debugging booking man tracking: $e');
    }
  }
} 