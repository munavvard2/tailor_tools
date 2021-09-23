class Contact {
  static const tblContact = "contacts";
  static const colId = "id";
  static const colName = "name";
  static const colMobileNumber = "mobile_number";

  static const colpLambai = "p_lambai";
  static const colpKammar = "p_kammar";
  static const colpSeat = "p_seat";
  static const colpdFly = "p_Fly";
  static const colpLangot = "p_langot";
  static const colpJhang = "p_jhang";
  static const colpGuthan = "p_guthan";
  static const colpMori = "p_mori";

  static const colsLambai = "s_lambai";
  static const colsShoulder = "s_shoulder";
  static const colsChest = "s_chest";
  static const colsKammar = "s_kammar";
  static const colsBay = "s_bay";
  static const colsColler = "s_coller";
  static const colsBeg = "s_beg";

  Contact({
    this.id,
    this.name,
    this.mobileNumber,
    this.pLambai,
    this.pGuthan,
    this.pJhang,
    this.pKammar,
    this.pLangot,
    this.pMori,
    this.pSeat,
    this.pdFly,
    this.sBay,
    this.sBeg,
    this.sChest,
    this.sColler,
    this.sKammar,
    this.sLambai,
    this.sShoulder,
  });

  Contact.fromMap(Map<dynamic, dynamic> map) {
    id = map[colId];
    name = map[colName];
    mobileNumber = map[colMobileNumber];
    pGuthan = map[colpGuthan];
    pJhang = map[colpJhang];
    pKammar = map[colpKammar];
    pLambai = map[colpLambai];
    pLangot = map[colpLangot];
    pMori = map[colpMori];
    pSeat = map[colpSeat];
    pdFly = map[colpdFly];
    sBay = map[colsBay];
    sBeg = map[colsBeg];
    sChest = map[colsChest];
    sColler = map[colsColler];
    sKammar = map[colsKammar];
    sLambai = map[colsLambai];
    sShoulder = map[colsShoulder];
  }

  int? id;
  String? name;
  String? mobileNumber;
  String? pLambai;
  String? pKammar;
  String? pSeat;
  String? pdFly;
  String? pLangot;
  String? pJhang;
  String? pGuthan;
  String? pMori;
  String? sLambai;
  String? sShoulder;
  String? sChest;
  String? sKammar;
  String? sBay;
  String? sColler;
  String? sBeg;

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      colName: name,
      colMobileNumber: mobileNumber,
      colpGuthan: pGuthan,
      colpJhang: pJhang,
      colpKammar: pKammar,
      colpLambai: pLambai,
      colpLangot: pLangot,
      colpMori: pMori,
      colpSeat: pSeat,
      colpdFly: pdFly,
      colsBay: sBay,
      colsBeg: sBeg,
      colsChest: sChest,
      colsColler: sColler,
      colsKammar: sKammar,
      colsLambai: sLambai,
      colsShoulder: sShoulder,
    };
    if (id != null) {
      map[colId] = id;
    }
    return map;
  }
}
