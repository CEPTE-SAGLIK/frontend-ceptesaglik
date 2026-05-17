import 'package:health_asistants/data/model/person.dart';
import 'package:health_asistants/data/model/reminder.dart' show AudienceGroup;

/// Bir kişinin yaş grubunu doğum tarihinden belirler.
/// Eşikler: çocuk < 18 yaş, yaşlı >= 65 yaş, arası yetişkin.
AudienceGroup audienceForPerson(Person person) {
  if (person.isChild) return AudienceGroup.child;
  final now = DateTime.now();
  var age = now.year - person.birthDate.year;
  final hadBirthdayThisYear = now.month > person.birthDate.month ||
      (now.month == person.birthDate.month && now.day >= person.birthDate.day);
  if (!hadBirthdayThisYear) age--;
  if (age < 18) return AudienceGroup.child;
  if (age >= 65) return AudienceGroup.elderly;
  return AudienceGroup.adult;
}
