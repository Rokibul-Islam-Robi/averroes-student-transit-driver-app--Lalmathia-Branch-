import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

// ════════════════════════════════════════════════════════════════════════════
// MODELS
// ════════════════════════════════════════════════════════════════════════════

// ── 1. Bus Schedule (route + stops + timing) ────────────────────────────────
class BusStop {
  final String stopName;
  final String pickupTime;
  final String dropTime;
  final int stopOrder;

  BusStop({
    required this.stopName,
    required this.pickupTime,
    required this.dropTime,
    required this.stopOrder,
  });

  factory BusStop.fromJson(Map<String, dynamic> json) {
    return BusStop(
      stopName: json['stop_name']?.toString() ?? '',
      pickupTime: json['pickup_time']?.toString() ?? '',
      dropTime: json['drop_time']?.toString() ?? '',
      stopOrder: int.tryParse(json['stop_order'].toString()) ?? 0,
    );
  }
}

class BusSchedule {
  final String routeName;
  final String busNumber;
  final String driverName;
  final String driverPhone;
  final String helperPhone;
  final List<BusStop> stops;

  BusSchedule({
    required this.routeName,
    required this.busNumber,
    required this.driverName,
    required this.driverPhone,
    required this.helperPhone,
    required this.stops,
  });

  factory BusSchedule.fromJson(Map<String, dynamic> json) {
    final List stopsRaw = json['stops'] ?? [];
    return BusSchedule(
      routeName: json['route_name']?.toString() ?? '',
      busNumber: json['bus_number']?.toString() ?? '',
      driverName: json['driver_name']?.toString() ?? '',
      driverPhone: json['driver_phone']?.toString() ?? '',
      helperPhone: json['helper_phone']?.toString() ?? '',
      stops: stopsRaw.map((e) => BusStop.fromJson(e)).toList()
        ..sort((a, b) => a.stopOrder.compareTo(b.stopOrder)),
    );
  }
}

// ── 2. Bus Entry/Out log (boarding & alighting events) ──────────────────────
class BusLogEntry {
  final String date;
  final String entryTime; // student boarded the bus
  final String exitTime; // student got off the bus
  final String status; // "On Time", "Late", "Missed", etc.

  BusLogEntry({
    required this.date,
    required this.entryTime,
    required this.exitTime,
    required this.status,
  });

  factory BusLogEntry.fromJson(Map<String, dynamic> json) {
    return BusLogEntry(
      date: json['date']?.toString() ?? '',
      entryTime: json['entry_time']?.toString() ?? '--',
      exitTime: json['exit_time']?.toString() ?? '--',
      status: json['status']?.toString() ?? '',
    );
  }
}

// ── 3 & 4. Live Location / Live Tracking ────────────────────────────────────
class BusLiveLocation {
  final double latitude;
  final double longitude;
  final String lastUpdated;
  final double? speedKmh;
  final double? heading; // direction in degrees, for rotating the marker icon

  BusLiveLocation({
    required this.latitude,
    required this.longitude,
    required this.lastUpdated,
    this.speedKmh,
    this.heading,
  });

  factory BusLiveLocation.fromJson(Map<String, dynamic> json) {
    return BusLiveLocation(
      latitude: double.tryParse(json['latitude'].toString()) ?? 0.0,
      longitude: double.tryParse(json['longitude'].toString()) ?? 0.0,
      lastUpdated: json['last_updated']?.toString() ?? '',
      speedKmh: json['speed_kmh'] != null
          ? double.tryParse(json['speed_kmh'].toString())
          : null,
      heading: json['heading'] != null
          ? double.tryParse(json['heading'].toString())
          : null,
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// CONTROLLER
// ════════════════════════════════════════════════════════════════════════════
class BusController extends GetxController {
  // ── Base API config ────────────────────────────────────────────────────────
  static const String _baseUrl = 'https://averroesint.com/averroes_school_erp/api';
  static const String _scheduleEndpoint = '/transport/bus-schedule';
  static const String _logEndpoint = '/transport/bus-log';
  static const String _liveLocationEndpoint = '/transport/live-location';

  String? _authToken;

  void setAuthToken(String token) => _authToken = token;

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (_authToken != null) 'Authorization': 'Bearer $_authToken',
  };

  // ── 1. Bus Schedule state ───────────────────────────────────────────────
  var scheduleLoading = true.obs;
  var scheduleHasError = false.obs;
  var scheduleErrorMessage = ''.obs;
  Rx<BusSchedule?> schedule = Rx<BusSchedule?>(null);

  // ── 2. Bus Entry/Out log state ──────────────────────────────────────────
  var logLoading = true.obs;
  var logHasError = false.obs;
  var logErrorMessage = ''.obs;
  var busLogs = <BusLogEntry>[].obs;

  // ── 3 & 4. Live location / live tracking state ──────────────────────────
  var liveLoading = true.obs;
  var liveHasError = false.obs;
  var liveErrorMessage = ''.obs;
  Rx<BusLiveLocation?> liveLocation = Rx<BusLiveLocation?>(null);

  var isLiveTrackingActive = false.obs;
  Timer? _pollTimer;
  static const Duration _pollInterval = Duration(seconds: 10);

  @override
  void onInit() {
    super.onInit();
    fetchSchedule();
    fetchBusLog();
    fetchLiveLocation();
  }

  @override
  void onClose() {
    _pollTimer?.cancel();
    super.onClose();
  }

  // ────────────────────────────────────────────────────────────────────────
  // 1. BUS SCHEDULE
  // ────────────────────────────────────────────────────────────────────────
  Future<void> fetchSchedule() async {
    try {
      scheduleLoading(true);
      scheduleHasError(false);

      final uri = Uri.parse('$_baseUrl$_scheduleEndpoint');
      final response = await http.get(uri, headers: _headers).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded['status'] == 'success' && decoded['data'] != null) {
          schedule.value = BusSchedule.fromJson(decoded['data']);
        } else {
          scheduleHasError(true);
          scheduleErrorMessage.value = decoded['message']?.toString() ?? 'Failed to load bus schedule.';
        }
      } else if (response.statusCode == 401) {
        scheduleHasError(true);
        scheduleErrorMessage.value = 'Session expired. Please log in again.';
      } else {
        scheduleHasError(true);
        scheduleErrorMessage.value = 'Server error (${response.statusCode}).';
      }
    } catch (e) {
      scheduleHasError(true);
      scheduleErrorMessage.value = 'Could not connect to server. Please check your internet connection.';
    } finally {
      scheduleLoading(false);
    }
  }

  // ────────────────────────────────────────────────────────────────────────
  // 2. BUS ENTRY/OUT LOG
  // ────────────────────────────────────────────────────────────────────────
  Future<void> fetchBusLog() async {
    try {
      logLoading(true);
      logHasError(false);

      final uri = Uri.parse('$_baseUrl$_logEndpoint');
      final response = await http.get(uri, headers: _headers).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded['status'] == 'success' && decoded['data'] != null) {
          final List rows = decoded['data'];
          busLogs.value = rows.map((e) => BusLogEntry.fromJson(e)).toList();
        } else {
          logHasError(true);
          logErrorMessage.value = decoded['message']?.toString() ?? 'Failed to load bus log.';
        }
      } else if (response.statusCode == 401) {
        logHasError(true);
        logErrorMessage.value = 'Session expired. Please log in again.';
      } else {
        logHasError(true);
        logErrorMessage.value = 'Server error (${response.statusCode}).';
      }
    } catch (e) {
      logHasError(true);
      logErrorMessage.value = 'Could not connect to server. Please check your internet connection.';
    } finally {
      logLoading(false);
    }
  }

  // ────────────────────────────────────────────────────────────────────────
  // 3. LIVE LOCATION (single snapshot fetch)
  // ────────────────────────────────────────────────────────────────────────
  Future<void> fetchLiveLocation() async {
    try {
      liveLoading(true);
      liveHasError(false);

      final uri = Uri.parse('$_baseUrl$_liveLocationEndpoint');
      final response = await http.get(uri, headers: _headers).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded['status'] == 'success' && decoded['data'] != null) {
          liveLocation.value = BusLiveLocation.fromJson(decoded['data']);
        } else {
          liveHasError(true);
          liveErrorMessage.value = decoded['message']?.toString() ?? 'Failed to load live location.';
        }
      } else if (response.statusCode == 401) {
        liveHasError(true);
        liveErrorMessage.value = 'Session expired. Please log in again.';
      } else {
        liveHasError(true);
        liveErrorMessage.value = 'Server error (${response.statusCode}).';
      }
    } catch (e) {
      liveHasError(true);
      liveErrorMessage.value = 'Could not connect to server. Please check your internet connection.';
    } finally {
      liveLoading(false);
    }
  }

  // ────────────────────────────────────────────────────────────────────────
  // 4. LIVE TRACKING (Polling)
  // ────────────────────────────────────────────────────────────────────────
  void startLiveTracking() {
    if (isLiveTrackingActive.value) return;
    isLiveTrackingActive(true);
    _pollTimer = Timer.periodic(_pollInterval, (_) {
      fetchLiveLocation();
    });
  }

  void stopLiveTracking() {
    isLiveTrackingActive(false);
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  // ── Pull-to-refresh helpers ──
  Future<void> refreshSchedule() async => fetchSchedule();
  Future<void> refreshBusLog() async => fetchBusLog();
  Future<void> refreshLiveLocation() async => fetchLiveLocation();
}