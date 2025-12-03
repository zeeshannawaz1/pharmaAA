import 'package:flutter/material.dart';
import '../services/location_service.dart';
import 'package:intl/intl.dart';

class AllUsersLocationWidget extends StatefulWidget {
  const AllUsersLocationWidget({super.key});

  @override
  State<AllUsersLocationWidget> createState() => _AllUsersLocationWidgetState();
}

class _AllUsersLocationWidgetState extends State<AllUsersLocationWidget> {
  List<Map<String, dynamic>> _allUsersLocations = [];
  bool _isLoading = false;
  String _searchRange = '';

  @override
  void initState() {
    super.initState();
    _loadAllUsersLocations();
  }

  Future<void> _loadAllUsersLocations() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Use the new method that groups by booking man ID
      final locations = await LocationService.getAllBookingManIdsWithLocations();
      setState(() {
        _allUsersLocations = locations;
      });
    } catch (e) {
      print('Error loading all users locations: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _searchByBookingManIdRange() async {
    if (_searchRange.isEmpty) {
      _loadAllUsersLocations();
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Parse range (e.g., "100-200" or "100")
      List<String> parts = _searchRange.split('-');
      String startId = parts[0].trim();
      String endId = parts.length > 1 ? parts[1].trim() : startId;

      final locations = await LocationService.getUsersByBookingManIdRange(startId, endId);
      setState(() {
        _allUsersLocations = locations;
      });
    } catch (e) {
      print('Error searching by booking man ID range: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.people,
                  color: Colors.blue.shade600,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'All Users Location Tracking',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Search by Booking Man ID Range
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search by BM ID (e.g., 100-200 or single ID)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      prefixIcon: const Icon(Icons.search),
                    ),
                    onChanged: (value) {
                      _searchRange = value;
                    },
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _searchByBookingManIdRange,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Search'),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_allUsersLocations.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                child: const Center(
                  child: Text(
                    'No users found',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              Column(
                children: [
                  Text(
                    'Found ${_allUsersLocations.length} booking man IDs:',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ..._allUsersLocations.map((userData) => _buildUserLocationCard(userData)),
                ],
              ),
            
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _loadAllUsersLocations,
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('Refresh All'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserLocationCard(Map<String, dynamic> userData) {
    final userId = userData['userId'] ?? 'Unknown';
    final bookingManId = userData['bookingManId'] ?? 'Unknown';
    final latitude = userData['latitude']?.toString() ?? 'N/A';
    final longitude = userData['longitude']?.toString() ?? 'N/A';
    final accuracy = userData['accuracy']?.toString() ?? 'N/A';
    final address = userData['address'] ?? 'Unknown Location';
    final timestamp = userData['timestamp'];
    
    String formattedTime = 'Unknown';
    if (timestamp != null) {
      try {
        final dateTime = timestamp.toDate();
        formattedTime = DateFormat('MMM dd, HH:mm').format(dateTime);
      } catch (e) {
        formattedTime = 'Invalid Time';
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.blue.shade300),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.badge,
                      size: 12,
                      color: Colors.blue.shade700,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'BM ID: $bookingManId',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'User: $userId',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '📍 $address',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    formattedTime,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Text(
                      '${accuracy}m',
                      style: TextStyle(
                        fontSize: 9,
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.location_on,
                  size: 14,
                  color: Colors.blue.shade600,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Coordinates: $latitude, $longitude',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.blue.shade700,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 