import 'package:intl/intl.dart';

class Val{
  // Validations
  static String validateTitle(String value){
    return (value != null && value != "") ? null: "O titulo deve ser atribuido";
  }

  static String getExpiryStr(String expires){
    var expDate = DateUtil.convertToDate(expires);
    var todayDate = new DateTime.now();

    Duration diferenca = expDate.difference(todayDate);
    int dd = diferenca.inDays + 1;
    return (dd > 0) ? dd.toString(): "0";
  }

  static bool strToBool(String string){
    return (int.parse(string) > 0) ? true: false;
  }

  static bool intToBool(int value){
    return (value > 0) ? true: false;
  }

  static int boolToInt(bool value){
    return (value == true) ? 1: 0;
  }
}

class DateUtil{
  static DateTime convertToDate(String strDate){
    try{
      var data = new DateFormat("yyyy-MM-dd").parseStrict(strDate);
      return data;
    } catch(erro){
      return null;
    }
  }

  static String convertToDateFull(String strDate){
    try{
      var data = new DateFormat("yyyy-MM-dd").parseStrict(strDate);
      var formatador = new DateFormat("dd MMM yyyy");
      return formatador.format(data);
    } catch(erro){
      return null;
    }
  }

  static bool isDate(String data){
    try{
      DateFormat("yyyy-MM-dd").parseStrict(data);
      return true;
    } catch(erro){
      return false;
    }
  }

  static bool isValiDate(String data){
    if (data.isEmpty || !data.contains("-") || data.length < 10) return false;

    List<String> itemsData = data.split("-");
    var date = DateTime(
        int.parse(itemsData[0]),
        int.parse(itemsData[1]),
        int.parse(itemsData[2])
    );

    return date != null && isDate(data) && date.isAfter(new DateTime.now());
  }

  static String daysAheadAsStr(int daysAhead){
    var now = new DateTime.now();
    DateTime formatDate = now.add(new Duration(days: daysAhead));
    return formatDateAsStr(formatDate);
  }

  static String formatDateAsStr(DateTime formated){
    return formated.year.toString() + "-" +
           formated.month.toString().padLeft(2, "0") + "-" +
           formated.day.toString().padLeft(2, "0");
  }

  static String trimDate(String data) {
    if (data.contains(" ")) {
      List<String> p = data.split(" ");
      return p[0];
    } else
      return data;
  }
}
