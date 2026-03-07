import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:proximity_sensor/proximity_sensor.dart';
import 'package:sensors_plus/sensors_plus.dart';
class SensorService {
  // Proximity Sensor
  StreamSubscription<dynamic>? _proximitySubscription;
  final _proximityController = StreamController<bool>.broadcast();
  Stream<bool> get proximityStream => _proximityController.stream;
  void startProximitySensor() {
    try {
      _proximitySubscription = ProximitySensor.events.listen((dynamic value) {
        // Convert to int and check if object is near
        final int proximityValue = (value is int) ? value : int.tryParse(value.toString()) ?? 0;
        _proximityController.add(proximityValue > 0);
      }, onError: (error) {
        debugPrint('Proximity sensor error: $error');
      });
    } catch (e) {
      debugPrint('Failed to start proximity sensor: $e');
    }
  }
  void stopProximitySensor() {
    _proximitySubscription?.cancel();
    _proximitySubscription = null;
  }
  // Accelerometer (Shake Detection)
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  final _shakeController = StreamController<void>.broadcast();
  Stream<void> get shakeStream => _shakeController.stream;
  DateTime _lastShakeTime = DateTime.now();
  
  // Shake detection parameters
  static const double _shakeThreshold = 12.0; // Lower threshold for better sensitivity
  static const Duration _shakeCooldown = Duration(seconds: 1);
  
  // Track previous acceleration for change detection
  double _lastX = 0;
  double _lastY = 0;
  double _lastZ = 0;
  bool _isFirstReading = true;
  
  void startAccelerometer() {
    try {
      _accelerometerSubscription = accelerometerEventStream(
        samplingPeriod: const Duration(milliseconds: 100),
      ).listen(
        (AccelerometerEvent event) {
          if (_isFirstReading) {
            _lastX = event.x;
            _lastY = event.y;
            _lastZ = event.z;
            _isFirstReading = false;
            return;
          }
          
          // Calculate change in acceleration (delta)
          final double deltaX = (event.x - _lastX).abs();
          final double deltaY = (event.y - _lastY).abs();
          final double deltaZ = (event.z - _lastZ).abs();
          final double totalDelta = deltaX + deltaY + deltaZ;
          
          _lastX = event.x;
          _lastY = event.y;
          _lastZ = event.z;
          
          if (totalDelta > _shakeThreshold) {
            final now = DateTime.now();
            if (now.difference(_lastShakeTime) > _shakeCooldown) {
              _lastShakeTime = now;
              debugPrint('Shake detected! Delta: $totalDelta');
              _shakeController.add(null);
            }
          }
        },
        onError: (error) {
          debugPrint('Accelerometer error: $error');
        },
        cancelOnError: false,
      );
    } catch (e) {
      debugPrint('Failed to start accelerometer: $e');
    }
  }
  void stopAccelerometer() {
    _accelerometerSubscription?.cancel();
    _accelerometerSubscription = null;
  }
  void dispose() {
    stopProximitySensor();
    stopAccelerometer();
    _proximityController.close();
    _shakeController.close();
  }
}