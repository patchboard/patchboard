var UnparseableEntityException = function UnparseableEntityException () {
  this.statusCode = 400;
  this.message = "Could not parse entity body";
};

exports.json = {
  "encode" : function (obj) {
    JSON.stringify(obj);
  },
  "decode" : function (str) {
    try {
      return JSON.parse(str);
    } catch (e) {
      throw new UnparseableEntityException();
    }
  }
}

exports.form = {
  "encode" : function (obj) {
    throw "unimplemented";
    //JSON.stringify(obj);
  },
  "decode" : function (str) {
    try {
      var parts = str.split("&");
      var obj = {};
      parts.forEach(function (s) {
        var a = s.split("=");
        if (a[0] && a[1]) {
          obj[a[0]] = a[1];
        } else {
          throw new UnparseableEntityException();
        }
      });
      return obj;
    } catch (e) {
      throw new UnparseableEntityException();
    }
  }
}
