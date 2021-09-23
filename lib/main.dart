import 'package:flutter/material.dart';
import 'package:tailor_tools/models/contact.dart';
import 'package:tailor_tools/utils/db_helper.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/tap_bounce_container.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:firebase_core/firebase_core.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

// https://firebase.google.com/docs/libraries
// https://firebase.flutter.dev/docs/overview#initializing-flutterfire
// https://firebase.flutter.dev/docs/crashlytics/overview/

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

const titleOfApp = "Tailor Tools";
var primaryColor = Colors.green;

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: titleOfApp,
      theme: ThemeData(
        primarySwatch: primaryColor,
      ),
      home: const MyHomePage(title: titleOfApp),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Set default `_initialized` and `_error` state to false
  bool _initialized = false;
  bool _error = false;

  // Define an async function to initialize FlutterFire
  void initializeFlutterFire() async {
    try {
      // Wait for Firebase to initialize and set `_initialized` state to true
      await Firebase.initializeApp();
      setState(() {
        _initialized = true;
      });
    } catch (e) {
      // Set `_error` state to true if Firebase initialization fails
      setState(() {
        _error = true;
      });
    }
  }

  Contact contact = Contact();
  List<Contact> contacts = [];

  String searchVal = "";
  late DbHelper dbHelper;
  final ctrlSearch = TextEditingController();

  @override
  void initState() {
    initializeFlutterFire();
    super.initState();
    setState(() {
      dbHelper = DbHelper.instance;
    });
    _refreshContactList();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        // backgroundColor: Colors.white,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Center(
            child: Text(
          widget.title,
          // style: TextStyle(color: primaryColor),
        )),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        onPressed: () {
          openDetailScreen(0);
        },
        child: const Icon(Icons.add),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            _search(),
            _list(),
          ],
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  _search() => Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
        child: TextField(
          decoration: const InputDecoration(icon: Icon(Icons.search)),
          onChanged: (val) => _searchInList(val),
          controller: ctrlSearch,
        ),
      );
  _searchInList(String val) {
    searchVal = val;
    _refreshContactList();
  }

  _refreshContactList() async {
    List<Contact> contacts = await dbHelper.fetchContacts();
    var filteredContacts = contacts
        .where((contact) =>
            contact.name
                .toString()
                .toLowerCase()
                .contains(searchVal.toLowerCase()) ||
            contact.mobileNumber
                .toString()
                .toLowerCase()
                .contains(searchVal.toLowerCase()))
        .toList();
    setState(() {
      this.contacts = filteredContacts;
    });
  }

  _deleteContact(contact) async {
    await dbHelper.deleteContact(contact);
    _refreshContactList();
  }

  _list() => Expanded(
        child: Card(
            margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
            child: ListView.builder(
              padding: const EdgeInsets.all(2),
              itemBuilder: (context, index) {
                return Column(
                  children: <Widget>[
                    ListTile(
                      leading: Icon(
                        Icons.account_circle,
                        color: primaryColor,
                        size: 36,
                      ),
                      trailing: IconButton(
                        icon: Icon(
                          Icons.delete_sweep,
                          color: primaryColor,
                          size: 26,
                        ),
                        onPressed: () => _deleteContact(contacts[index]),
                      ),
                      title: Text(
                        contacts[index].name!.toUpperCase(),
                        style: TextStyle(
                            fontSize: 16,
                            color: primaryColor,
                            fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        contacts[index].mobileNumber.toString(),
                        maxLines: 1,
                        style: const TextStyle(
                          fontSize: 12,
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          contact = contacts[index];
                        });
                        openDetailScreen(contact.id!.toInt());
                      },
                    ),
                    const Divider(
                      height: 1,
                    ),
                  ],
                );
              },
              itemCount: contacts.length,
            )),
      );

  openDetailScreen(int id) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) {
        return DetailScreen(contactId: id);
      },
    )).then((value) => _refreshContactList());
  }
}

class DetailScreen extends StatefulWidget {
  const DetailScreen({Key? key, required this.contactId}) : super(key: key);
  final int contactId;

  @override
  State<DetailScreen> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailScreen> {
  late DbHelper dbHelper;
  late int contactId;
  final _formKey = GlobalKey<FormState>();
  final ctrlName = TextEditingController();
  final ctrlMobile = TextEditingController();

  final ctrlPGuthan = TextEditingController();
  final ctrlPJhang = TextEditingController();
  final ctrlPKammar = TextEditingController();
  final ctrlPLambai = TextEditingController();
  final ctrlPLangot = TextEditingController();
  final ctrlPMori = TextEditingController();
  final ctrlPSeat = TextEditingController();
  final ctrlPDFly = TextEditingController();

  final ctrlSBay = TextEditingController();
  final ctrlSBeg = TextEditingController();
  final ctrlSChest = TextEditingController();
  final ctrlSCollor = TextEditingController();
  final ctrlSKammar = TextEditingController();
  final ctrlSLambai = TextEditingController();
  final ctrlSShoulder = TextEditingController();

  FocusNode fn1 = FocusNode();
  Contact? contact = Contact();

  @override
  void initState() {
    super.initState();
    setState(() {
      dbHelper = DbHelper.instance;
    });
  }

  @override
  Widget build(BuildContext context) {
    contactId = widget.contactId;
    _fetchContact();
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        children: [
          _form(),
        ],
      ),
    );
  }

  _fetchContact() async {
    if (contactId == 0) {
      return;
    }
    contact = await dbHelper.getContactById(contactId);
    ctrlMobile.text = contact!.mobileNumber.toString();
    ctrlName.text = contact!.name.toString();

    ctrlPGuthan.text = contact!.pGuthan.toString();
    ctrlPJhang.text = contact!.pJhang.toString();
    ctrlPLambai.text = contact!.pLambai.toString();
    ctrlPLangot.text = contact!.pLangot.toString();
    ctrlPSeat.text = contact!.pSeat.toString();
    ctrlPDFly.text = contact!.pdFly.toString();
    ctrlPKammar.text = contact!.pKammar.toString();
    ctrlPMori.text = contact!.pMori.toString();

    ctrlSBay.text = contact!.sBay.toString();
    ctrlSBeg.text = contact!.sBeg.toString();
    ctrlSChest.text = contact!.sChest.toString();
    ctrlSCollor.text = contact!.sColler.toString();
    ctrlSKammar.text = contact!.sKammar.toString();
    ctrlSShoulder.text = contact!.sShoulder.toString();
    ctrlSLambai.text = contact!.sLambai.toString();
  }

// લંબાઈ
// કમર
// સીટ
// ફ્લાય
// લંગોટ
// ઝાંગ
// ગુથણ
// મોરી

// શોલ્ડર
// છાતી
// બાય
// કોલર
// બેગ

  // _getSingleInput(field,labelText,) {}

  _form() => Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              Row(
                children: [
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(6, 0, 6, 0),
                      child: TextFormField(
                        decoration: const InputDecoration(labelText: "નામ"),
                        onSaved: (val) => setState(() {
                          contact?.name = val;
                        }),
                        validator: (val) =>
                            (val!.isEmpty ? 'Please Enter Name' : null),
                        focusNode: fn1,
                        controller: ctrlName,
                      ),
                    ),
                  ),
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(6, 0, 6, 0),
                      child: TextFormField(
                        decoration:
                            const InputDecoration(labelText: "મોબાઈલ  નંબર"),
                        onSaved: (val) => setState(() {
                          contact?.mobileNumber = val;
                        }),
                        validator: (val) => (val!.length < 10
                            ? 'Valid Mobile Number Reqired'
                            : null),
                        controller: ctrlMobile,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(),
              const Text(
                "પેન્ટ",
                style: TextStyle(fontSize: 20),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(6, 0, 6, 0),
                      child: TextFormField(
                        keyboardType: const TextInputType.numberWithOptions(),
                        decoration: const InputDecoration(labelText: "લંબાઈ"),
                        onSaved: (val) => setState(() {
                          contact?.pLambai = val;
                        }),
                        controller: ctrlPLambai,
                      ),
                    ),
                  ),
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(6, 0, 6, 0),
                      child: TextFormField(
                        keyboardType: const TextInputType.numberWithOptions(),
                        decoration: const InputDecoration(labelText: "કમર"),
                        onSaved: (val) => setState(() {
                          contact?.pKammar = val;
                        }),
                        controller: ctrlPKammar,
                      ),
                    ),
                  ),
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(6, 0, 6, 0),
                      child: TextFormField(
                        keyboardType: const TextInputType.numberWithOptions(),
                        decoration: const InputDecoration(labelText: "સીટ"),
                        onSaved: (val) => setState(() {
                          contact?.pSeat = val;
                        }),
                        controller: ctrlPSeat,
                      ),
                    ),
                  ),
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(6, 0, 6, 0),
                      child: TextFormField(
                        keyboardType: const TextInputType.numberWithOptions(),
                        decoration: const InputDecoration(labelText: "ફ્લાય "),
                        onSaved: (val) => setState(() {
                          contact?.pdFly = val;
                        }),
                        controller: ctrlPDFly,
                      ),
                    ),
                  ),
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(6, 0, 6, 0),
                      child: TextFormField(
                        keyboardType: const TextInputType.numberWithOptions(),
                        decoration: const InputDecoration(labelText: "લંગોટ"),
                        onSaved: (val) => setState(() {
                          contact?.pLangot = val;
                        }),
                        controller: ctrlPLangot,
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(6, 0, 6, 0),
                      child: TextFormField(
                        keyboardType: const TextInputType.numberWithOptions(),
                        decoration: const InputDecoration(labelText: "ઝાંગ"),
                        onSaved: (val) => setState(() {
                          contact?.pJhang = val;
                        }),
                        controller: ctrlPJhang,
                      ),
                    ),
                  ),
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(6, 0, 6, 0),
                      child: TextFormField(
                        keyboardType: const TextInputType.numberWithOptions(),
                        decoration: const InputDecoration(labelText: "ગુથણ"),
                        onSaved: (val) => setState(() {
                          contact?.pGuthan = val;
                        }),
                        controller: ctrlPGuthan,
                      ),
                    ),
                  ),
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(6, 0, 6, 0),
                      child: TextFormField(
                        keyboardType: const TextInputType.numberWithOptions(),
                        decoration: const InputDecoration(labelText: "મોરી"),
                        onSaved: (val) => setState(() {
                          contact?.pMori = val;
                        }),
                        controller: ctrlPMori,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(),
              const Text(
                "શર્ટ",
                style: TextStyle(fontSize: 20),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(6, 0, 6, 0),
                      child: TextFormField(
                        keyboardType: const TextInputType.numberWithOptions(),
                        decoration: const InputDecoration(labelText: "લંબાઈ"),
                        onSaved: (val) => setState(() {
                          contact?.sLambai = val;
                        }),
                        controller: ctrlSLambai,
                      ),
                    ),
                  ),
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(6, 0, 6, 0),
                      child: TextFormField(
                        keyboardType: const TextInputType.numberWithOptions(),
                        decoration: const InputDecoration(labelText: "શોલ્ડર"),
                        onSaved: (val) => setState(() {
                          contact?.sShoulder = val;
                        }),
                        controller: ctrlSShoulder,
                      ),
                    ),
                  ),
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(6, 0, 6, 0),
                      child: TextFormField(
                        keyboardType: const TextInputType.numberWithOptions(),
                        decoration: const InputDecoration(labelText: "છાતી"),
                        onSaved: (val) => setState(() {
                          contact?.sChest = val;
                        }),
                        controller: ctrlSChest,
                      ),
                    ),
                  ),
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(6, 0, 6, 0),
                      child: TextFormField(
                        keyboardType: const TextInputType.numberWithOptions(),
                        decoration: const InputDecoration(labelText: "કમર"),
                        onSaved: (val) => setState(() {
                          contact?.sKammar = val;
                        }),
                        controller: ctrlSKammar,
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(6, 0, 6, 0),
                      child: TextFormField(
                        keyboardType: const TextInputType.numberWithOptions(),
                        decoration: const InputDecoration(labelText: "બાય"),
                        onSaved: (val) => setState(() {
                          contact?.sBay = val;
                        }),
                        controller: ctrlSBay,
                      ),
                    ),
                  ),
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(6, 0, 6, 0),
                      child: TextFormField(
                        keyboardType: const TextInputType.numberWithOptions(),
                        decoration: const InputDecoration(labelText: "કોલર"),
                        onSaved: (val) => setState(() {
                          contact?.sColler = val;
                        }),
                        controller: ctrlSCollor,
                      ),
                    ),
                  ),
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(6, 0, 6, 0),
                      child: TextFormField(
                        keyboardType: const TextInputType.numberWithOptions(),
                        decoration: const InputDecoration(labelText: "બેગ"),
                        onSaved: (val) => setState(() {
                          contact?.sBeg = val;
                        }),
                        controller: ctrlSBeg,
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                margin: const EdgeInsets.all(10.0),
                child: ElevatedButton(
                  onPressed: () => _onSubmit(),
                  child: const Text("Add"),
                ),
              )
            ],
          ),
        ),
      );

  _onSubmit() async {
    var form = _formKey.currentState;
    if (form!.validate()) {
      form.save();
      (!FocusScope.of(context).hasPrimaryFocus)
          ? FocusScope.of(context).unfocus()
          : '';
      if (contact != null) {
        if (contact?.id == null) {
          int id = await dbHelper.insertContact(contact!);
          contact?.id = id;
        } else {
          await dbHelper.updateContact(contact!);
        }
        // _fetchContact();
      }

      showTopSnackBar(
        context,
        const CustomSnackBar.success(
          message: "Measurement Saved.",
          textStyle: TextStyle(
            color: Colors.blue,
            fontSize: 30,
          ),
          backgroundColor: Colors.yellow,
          // iconRotationAngle: 0,
          // icon: Icon(
          //   Icons.check_circle,
          //   size: 42,
          // ),
        ),
      );
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(
      //     content: Text("Measurement Saved."),
      //     backgroundColor: Colors.green,
      //   ),
      // );
      // _resetForm();
      // fn1.requestFocus();
    }
  }

  _resetForm() {
    setState(() {
      _formKey.currentState?.reset();
      ctrlName.clear();
      ctrlMobile.clear();
      contact!.id = null;
    });
  }
}
