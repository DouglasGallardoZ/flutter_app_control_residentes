import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:guardin/models/access_event.dart';

class AccessEventService {
  static const String _eventsKey = 'access_events';
  final _uuid = Uuid();

  Future<List<AccessEvent>> getAllEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final eventsJson = prefs.getString(_eventsKey);
    
    if (eventsJson == null) {
      await _initializeSampleData();
      return await getAllEvents();
    }

    try {
      final List<dynamic> eventsList = json.decode(eventsJson);
      return eventsList.map((json) => AccessEvent.fromJson(json)).toList();
    } catch (e) {
      await _initializeSampleData();
      return await getAllEvents();
    }
  }

  Future<List<AccessEvent>> getEventsByUserId(String userId) async {
    final events = await getAllEvents();
    return events.where((e) => e.userId == userId).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  Future<List<AccessEvent>> getEventsByDateRange(DateTime start, DateTime end) async {
    final events = await getAllEvents();
    return events.where((e) =>
      e.timestamp.isAfter(start) && e.timestamp.isBefore(end)
    ).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  Future<AccessEvent> createEvent({
    String? userId,
    String? visitId,
    required String eventType,
    required String accessMethod,
    required bool isAuthorized,
    String? notes,
  }) async {
    final events = await getAllEvents();
    
    final newEvent = AccessEvent(
      id: _uuid.v4(),
      userId: userId,
      visitId: visitId,
      eventType: eventType,
      accessMethod: accessMethod,
      timestamp: DateTime.now(),
      isAuthorized: isAuthorized,
      notes: notes,
    );

    events.add(newEvent);
    await _saveEvents(events);
    return newEvent;
  }

  Future<void> _saveEvents(List<AccessEvent> events) async {
    final prefs = await SharedPreferences.getInstance();
    final eventsJson = json.encode(events.map((e) => e.toJson()).toList());
    await prefs.setString(_eventsKey, eventsJson);
  }

  Future<void> _initializeSampleData() async {
    final now = DateTime.now();
    final sampleEvents = [
      AccessEvent(
        id: 'event-1',
        userId: 'user-1',
        eventType: 'entrada',
        accessMethod: 'facial',
        timestamp: now.subtract(Duration(hours: 3)),
        isAuthorized: true,
        notes: 'Acceso autorizado mediante reconocimiento facial',
      ),
      AccessEvent(
        id: 'event-2',
        userId: 'user-1',
        eventType: 'salida',
        accessMethod: 'qr',
        timestamp: now.subtract(Duration(hours: 1)),
        isAuthorized: true,
        notes: 'Salida registrada con código QR',
      ),
      AccessEvent(
        id: 'event-3',
        visitId: 'visit-2',
        eventType: 'entrada',
        accessMethod: 'qr',
        timestamp: now.subtract(Duration(days: 2)),
        isAuthorized: true,
        notes: 'Visitante Juan Pérez autorizado',
      ),
      AccessEvent(
        id: 'event-4',
        userId: 'user-2',
        eventType: 'entrada',
        accessMethod: 'facial',
        timestamp: now.subtract(Duration(hours: 5)),
        isAuthorized: true,
        notes: 'Acceso facial exitoso',
      ),
      AccessEvent(
        id: 'event-5',
        userId: 'user-3',
        eventType: 'entrada',
        accessMethod: 'qr',
        timestamp: now.subtract(Duration(hours: 8)),
        isAuthorized: true,
        notes: 'Acceso con código QR personal',
      ),
    ];

    await _saveEvents(sampleEvents);
  }
}
