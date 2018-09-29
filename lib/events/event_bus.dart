import 'package:event_bus/event_bus.dart' as event_bus;
class EventBus {
  static event_bus.EventBus _instance;
  static event_bus.EventBus get instance  {
    if (_instance == null) {
      _instance = new event_bus.EventBus(sync: true);
    }
    return _instance;
  }
}