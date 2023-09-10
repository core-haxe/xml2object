package xml2object.util;

class StringUtil {
    public static function stringToDate(s:String):Date {
        var datePart = s;
        var timePart = null;
        var n = datePart.indexOf("T");
        if (n != -1) {
            datePart = s.substring(0, n);
            timePart = s.substring(n + 1);
        }
        var dt:Date = null;
        if (timePart != null) {
            var dateParts = datePart.split("-");
            var timeParts = timePart.split(":");
            dt = new Date(Std.parseInt(dateParts[0]), Std.parseInt(dateParts[1]) - 1, Std.parseInt(dateParts[2]),
                          Std.parseInt(timeParts[0]), Std.parseInt(timeParts[1])    , Std.parseInt(timeParts[2]));
        } else {
            dt = Date.fromString(datePart);
        }
        return dt;
    }
    
    public static function uncapitalizeFirstLetter(s:String):String {
        s = s.substr(0, 1).toLowerCase() + s.substr(1, s.length);
        return s;
    }

    public static function capitalizeFirstLetter(s:String):String {
        s = s.substr(0, 1).toUpperCase() + s.substr(1, s.length);
        return s;
    }

    public static function capitalizeHyphens(s:String):String {
        return capitalizeDelim(s, "-");
    }

    public static function capitalizeDelim(s:String, d:String):String {
        var r:String = s;
        var n:Int = r.indexOf(d);
        while (n != -1) {
            var before:String = r.substr(0, n);
            var after:String = r.substr(n + 1, r.length);
            r = before + capitalizeFirstLetter(after);
            n = r.indexOf(d, n + 1);
        }
        return r;
    }
}