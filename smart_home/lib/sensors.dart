import 'package:firebase_database/firebase_database.dart';
import 'dart:async';

class Sensors {
  // Gelen verinin tipi başlangıçta önemli değil, fakat
  // sonradan değişemez.
  var value;
  DatabaseReference ref;
  StreamSubscription<Event> subscription;
  DatabaseError error;

  Sensors(this.value) {
    value = value;
  }
  void initSensor(String path) {
    ref = FirebaseDatabase.instance.reference().child(path);
    ref.keepSynced(true);
  }

  void linkValue(Event event) {
    error = null;
    value = event.snapshot.value ?? 0;
  }
}
