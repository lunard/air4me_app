import 'package:realm/realm.dart';

part 'LocalDBMeasureModel.g.dart';

@RealmModel()
class _LocalDBMeasure {
  @PrimaryKey()
  late final String id;

  late num TVOC;
  late num eCO2;
  late String date; // DateTime is not supported by MongoDb Realm
  late num lat;
  late num lon;

  late bool synked;
}
