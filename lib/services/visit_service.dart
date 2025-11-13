import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:guardin/models/visit.dart';

class VisitService {
  static const String _visitsKey = 'visits';
  final _uuid = Uuid();

  Future<List<Visit>> getAllVisits() async {
    final prefs = await SharedPreferences.getInstance();
    final visitsJson = prefs.getString(_visitsKey);
    
    if (visitsJson == null) {
      await _initializeSampleData();
      return await getAllVisits();
    }

    try {
      final List<dynamic> visitsList = json.decode(visitsJson);
      return visitsList.map((json) => Visit.fromJson(json)).toList();
    } catch (e) {
      await _initializeSampleData();
      return await getAllVisits();
    }
  }

  Future<List<Visit>> getVisitsByResidentId(String residentId) async {
    final visits = await getAllVisits();
    return visits.where((v) => v.residentId == residentId).toList()
      ..sort((a, b) => b.visitDate.compareTo(a.visitDate));
  }

  Future<Visit?> getVisitByQrCode(String qrCode) async {
    final visits = await getAllVisits();
    try {
      return visits.firstWhere((v) => v.qrCode == qrCode);
    } catch (e) {
      return null;
    }
  }

  Future<Visit> createVisit({
    required String residentId,
    required String visitorName,
    required DateTime visitDate,
    required String motivo,
  }) async {
    final visits = await getAllVisits();
    final now = DateTime.now();
    
    final newVisit = Visit(
      id: _uuid.v4(),
      residentId: residentId,
      visitorName: visitorName,
      visitDate: visitDate,
      motivo: motivo,
      qrCode: 'VISIT-${_uuid.v4()}',
      status: 'pendiente',
      createdAt: now,
      updatedAt: now,
    );

    visits.add(newVisit);
    await _saveVisits(visits);
    return newVisit;
  }

  Future<Visit> updateVisit(Visit visit) async {
    final visits = await getAllVisits();
    final index = visits.indexWhere((v) => v.id == visit.id);
    
    if (index == -1) {
      throw Exception('Visita no encontrada');
    }

    visits[index] = visit.copyWith(updatedAt: DateTime.now());
    await _saveVisits(visits);
    return visits[index];
  }

  Future<Visit> updateVisitStatus(String visitId, String newStatus) async {
    final visits = await getAllVisits();
    final visit = visits.firstWhere((v) => v.id == visitId);
    return await updateVisit(visit.copyWith(status: newStatus));
  }

  Future<void> deleteVisit(String visitId) async {
    final visits = await getAllVisits();
    visits.removeWhere((v) => v.id == visitId);
    await _saveVisits(visits);
  }

  Future<void> _saveVisits(List<Visit> visits) async {
    final prefs = await SharedPreferences.getInstance();
    final visitsJson = json.encode(visits.map((v) => v.toJson()).toList());
    await prefs.setString(_visitsKey, visitsJson);
  }

  Future<void> _initializeSampleData() async {
    final now = DateTime.now();
    final sampleVisits = [
      Visit(
        id: 'visit-1',
        residentId: 'user-1',
        visitorName: 'Ana López',
        visitDate: now.add(Duration(days: 1)),
        motivo: 'Visita familiar',
        qrCode: 'VISIT-ana-lopez-001',
        status: 'pendiente',
        createdAt: now.subtract(Duration(hours: 2)),
        updatedAt: now.subtract(Duration(hours: 2)),
      ),
      Visit(
        id: 'visit-2',
        residentId: 'user-1',
        visitorName: 'Juan Pérez',
        visitDate: now.subtract(Duration(days: 2)),
        motivo: 'Entrega de paquete',
        qrCode: 'VISIT-juan-perez-002',
        status: 'completada',
        createdAt: now.subtract(Duration(days: 3)),
        updatedAt: now.subtract(Duration(days: 2)),
      ),
      Visit(
        id: 'visit-3',
        residentId: 'user-2',
        visitorName: 'Laura Ramírez',
        visitDate: now.add(Duration(hours: 5)),
        motivo: 'Reunión social',
        qrCode: 'VISIT-laura-ramirez-003',
        status: 'pendiente',
        createdAt: now.subtract(Duration(hours: 6)),
        updatedAt: now.subtract(Duration(hours: 6)),
      ),
      Visit(
        id: 'visit-4',
        residentId: 'user-3',
        visitorName: 'Roberto Silva',
        visitDate: now.add(Duration(days: 2)),
        motivo: 'Trabajo de mantenimiento',
        qrCode: 'VISIT-roberto-silva-004',
        status: 'pendiente',
        createdAt: now.subtract(Duration(hours: 1)),
        updatedAt: now.subtract(Duration(hours: 1)),
      ),
    ];

    await _saveVisits(sampleVisits);
  }
}
