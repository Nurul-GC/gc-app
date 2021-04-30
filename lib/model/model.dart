import '../util/utils.dart';

class Task{
  int id;
  String title;
  String expiration;

  int freqYear;
  int freqHalfYear;
  int freqQuarter;
  int freqMonth;

  Task(this.title, this.expiration, this.freqYear,
      this.freqHalfYear, this.freqQuarter, this.freqMonth);
  Task.withId(this.id, this.title, this.expiration, this.freqYear,
      this.freqHalfYear, this.freqQuarter, this.freqMonth);

  Map<String, dynamic> toMap(){
    var map = Map<String, dynamic>();

    map["title"] = this.title;
    map["expiration"] = this.expiration;

    map["freqYear"] = this.freqYear;
    map["freqHalfYear"] = this.freqHalfYear;
    map["freqQuarter"] = this.freqQuarter;
    map["freqMonth"] = this.freqMonth;

    if (id != null) {
      map["id"] = id;
    }
    return map;
  }

  Task.fromOject(dynamic object) {
    this.id = object["id"];
    this.title = object["title"];
    this.expiration = DateUtil.trimDate(object["expiration"]);
    this.freqYear = object["freqYear"];
    this.freqHalfYear = object["freqHalfYear"];
    this.freqQuarter = object["freqQuarter"];
    this.freqMonth = object["freqMonth"];
  }
}
