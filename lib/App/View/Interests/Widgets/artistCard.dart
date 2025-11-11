import 'dart:convert';
import 'package:dspora/App/View/Interests/Model/historymodel.dart';
import 'package:dspora/App/View/Interests/Model/placemodel.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


// Artist Model


class Artist {

  final String name;
  final String imageUrl;
  final String? location;
  final String? eventDate;
  final String? eventUrl;
  final bool isSelected;

  Artist({
    required this.name,
    required this.imageUrl,
    this.location,
    this.eventDate,
    this.eventUrl,
    this.isSelected = false,
  });


  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'imageUrl': imageUrl,
      'location': location,
      'eventDate': eventDate,
      'eventUrl': eventUrl,
      'isSelected': isSelected,
    };
  }


  factory Artist.fromJson(Map<String, dynamic> json) {
    return Artist(
      name: json['name'],
      imageUrl: json['imageUrl'],
      location: json['location'],
      eventDate: json['eventDate'],
      eventUrl: json['eventUrl'],
      isSelected: json['isSelected'] ?? false,
    );
  }


  Artist copyWith({bool? isSelected}) {
    return Artist(
      name: name,
      imageUrl: imageUrl,
      location: location,
      eventDate: eventDate,
      eventUrl: eventUrl,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}



// SharedPreferences Service for Artists
class ArtistPreferencesService {
  static const String _savedArtistsKey = 'saved_artists';

  // Save an artist
  static Future<bool> saveArtist(Artist artist) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedArtists = await getSavedArtists();
      
      // Check if artist already exists
      final exists = savedArtists.any((a) => a.name == artist.name);
      if (exists) {
        return false; // Artist already saved
      }

      savedArtists.add(artist);
      final jsonList = savedArtists.map((a) => a.toJson()).toList();
      return await prefs.setString(_savedArtistsKey, jsonEncode(jsonList));
    } catch (e) {
      debugPrint('Error saving artist: $e');
      return false;
    }
  }

  // Get all saved artists
  static Future<List<Artist>> getSavedArtists() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_savedArtistsKey);
      
      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }

      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => Artist.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error loading artists: $e');
      return [];
    }
  }

  // Remove an artist
  static Future<bool> removeArtist(String artistName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedArtists = await getSavedArtists();
      
      savedArtists.removeWhere((a) => a.name == artistName);
      final jsonList = savedArtists.map((a) => a.toJson()).toList();
      return await prefs.setString(_savedArtistsKey, jsonEncode(jsonList));
    } catch (e) {
      debugPrint('Error removing artist: $e');
      return false;
    }
  }

  // Check if artist is saved
  static Future<bool> isArtistSaved(String artistName) async {
    final savedArtists = await getSavedArtists();
    return savedArtists.any((a) => a.name == artistName);
  }

  // Clear all saved artists
  static Future<bool> clearAllArtists() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_savedArtistsKey);
    } catch (e) {
      debugPrint('Error clearing artists: $e');
      return false;
    }
  }
}

// SharedPreferences Service for Places
class PlacePreferencesService {
  static const String _savedPlacesKey = 'saved_places';

  // Save a place
  static Future<bool> savePlace(Place place) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedPlaces = await getSavedPlaces();
      
      // Check if place already exists
      final exists = savedPlaces.any((p) => p.name == place.name && p.address == place.address);
      if (exists) {
        return false; // Place already saved
      }

      savedPlaces.add(place);
      final jsonList = savedPlaces.map((p) => p.toJson()).toList();
      return await prefs.setString(_savedPlacesKey, jsonEncode(jsonList));
    } catch (e) {
      debugPrint('Error saving place: $e');
      return false;
    }
  }

  // Get all saved places
  static Future<List<Place>> getSavedPlaces() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_savedPlacesKey);
      
      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }

      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => Place.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error loading places: $e');
      return [];
    }
  }

  // Remove a place
  static Future<bool> removePlace(String placeName, String placeAddress) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedPlaces = await getSavedPlaces();
      
      savedPlaces.removeWhere((p) => p.name == placeName && p.address == placeAddress);
      final jsonList = savedPlaces.map((p) => p.toJson()).toList();
      return await prefs.setString(_savedPlacesKey, jsonEncode(jsonList));
    } catch (e) {
      debugPrint('Error removing place: $e');
      return false;
    }
  }

  // Check if place is saved
  static Future<bool> isPlaceSaved(String placeName, String placeAddress) async {
    final savedPlaces = await getSavedPlaces();
    return savedPlaces.any((p) => p.name == placeName && p.address == placeAddress);
  }

  // Clear all saved places
  static Future<bool> clearAllPlaces() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_savedPlacesKey);
    } catch (e) {
      debugPrint('Error clearing places: $e');
      return false;
    }
  }
}



class HistoryService {
  static const String _historyKey = 'user_history';
  static const int _maxHistoryItems = 100; // Keep last 100 items

  // Add a history item
  static Future<bool> addHistory(HistoryItem item) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final history = await getHistory();
      
      // Add new item at the beginning
      history.insert(0, item);
      
      // Keep only last 100 items
      if (history.length > _maxHistoryItems) {
        history.removeRange(_maxHistoryItems, history.length);
      }

      final jsonList = history.map((h) => h.toJson()).toList();
      return await prefs.setString(_historyKey, jsonEncode(jsonList));
    } catch (e) {
      debugPrint('Error adding history: $e');
      return false;
    }
  }

  // Get all history
  static Future<List<HistoryItem>> getHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_historyKey);
      
      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }

      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => HistoryItem.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error loading history: $e');
      return [];
    }
  }

  // Clear all history
  static Future<bool> clearHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_historyKey);
    } catch (e) {
      debugPrint('Error clearing history: $e');
      return false;
    }
  }
}




class ArtistCardWidget extends StatelessWidget {
  final Artist artist;
  final VoidCallback onTap;
  final VoidCallback? onRemove;

  const ArtistCardWidget({
    Key? key,
    required this.artist,
    required this.onTap,
    this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final imageSize = width * 0.22; // compact but responsive
    final fontSize = width * 0.035;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: imageSize * 2.2,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade100,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                Container(
                  width: imageSize,
                  height: imageSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: NetworkImage(artist.imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: onRemove,
                    child: Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: onRemove != null
                            ? Colors.red
                            : artist.isSelected
                                ? const Color(0xFF00BFA5)
                                : Colors.black,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Icon(
                        onRemove != null
                            ? Icons.close
                            : artist.isSelected
                                ? Icons.check
                                : Icons.add,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              artist.name,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

          ],
        ),
      ),
    );
  }
}
