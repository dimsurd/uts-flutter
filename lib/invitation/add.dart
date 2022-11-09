import 'dart:convert';
import 'package:evisitor_project/home_page.dart';
import 'package:evisitor_project/invitation/invitation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../login_page.dart';

class Add extends StatefulWidget {
  const Add({Key? key}) : super(key: key);
  @override
  State<Add> createState() => _AddState();
}

class _AddState extends State<Add> {
  final _formKey = GlobalKey<FormState>();
  String id = "";
  String username = "";
  //inisialize field
  var desc = TextEditingController();
  var IDUser = TextEditingController();
  final _dateC = TextEditingController();
  final _timeC = TextEditingController();

  ///Date
  DateTime selected = DateTime.now();
  DateTime initial = DateTime(2000);
  DateTime last = DateTime(2025);

  ///Time
  TimeOfDay timeOfDay = TimeOfDay.now();
  getPref() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var islogin = pref.getBool("is_login");
    if (islogin != null && islogin == true) {
      setState(() {
        username = pref.getString("username")!;
      });
    } else {
      Navigator.of(context, rootNavigator: true).pop();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => const PageLogin(),
        ),
        (route) => false,
      );
    }
  }

  logOut() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      preferences.remove("is_login");
      preferences.remove("username");
    });
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => const PageLogin(),
      ),
      (route) => false,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text(
        "Berhasil logout",
        style: TextStyle(fontSize: 16),
      )),
    );
  }

  @override
  dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    //in first time, this method will be executed
    getPref();
    _getData();
  }

  Future _getData() async {
    print(username);
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      var islogin = pref.getBool("is_login");
      setState(() {
        username = pref.getString("username")!;
      });
      final response = await http.get(Uri.parse(
          //you have to take the ip address of your computer.
          //because using localhost will cause an error
          //get detail data with id
          "https://nscis.nsctechnology.com/index.php?r=user/view-api&id=" +
              username));
      // if response successful
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          id = data["id"];
          // print(id);
          //IDUser = TextEditingController(text: id );
        });
        // print(id);
      }
    } catch (e) {
      print(e);
    }
  }

  Future _onSubmit() async {
    try {
      EasyLoading.show(status: 'Saving...');
      return await http.post(
        Uri.parse(
            "https://nscis.nsctechnology.com/index.php?r=t-invitation/create-api"),
        body: {
          "user_id": id,
          "schedule_date": _dateC.text,
          "time_schedule": _timeC.text,
          "description": desc.text,
        },
      ).then((value) {
        //print message after insert to database
        //you can improve this message with alert dialog

        EasyLoading.showSuccess('data successfully saved');
        var data = jsonDecode(value.body);
        print(data["message"]);
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => MainInvite()),
            (Route<dynamic> route) => false);

        EasyLoading.dismiss();
      });
    } catch (e) {
      print(e);
    }
  }

  MainInvite() => MainInvite();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.grey[600],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        //leading: Icon(Icons.menu),
        title: Text("BIU"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              logOut();
            },
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Container(
          color: Colors.white,
          padding: EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _dateC,
                decoration: const InputDecoration(
                  labelText: 'Schedule Date',
                  border: OutlineInputBorder(),
                  // fillColor: Colors.white,
                  // filled: true
                ),
              ),
              ElevatedButton(
                  onPressed: () => displayDatePicker(context),
                  child: const Text("Pick Date")),
              const SizedBox(height: 10),
              TextFormField(
                controller: _timeC,
                decoration: const InputDecoration(
                  labelText: 'Time',
                  border: OutlineInputBorder(),
                  // fillColor: Colors.white,
                  // filled: true
                ),
              ),
              ElevatedButton(
                  onPressed: () => displayTimePicker(context),
                  child: const Text("Pick Time")),
              SizedBox(height: 10),
              TextFormField(
                controller: desc,
                keyboardType: TextInputType.multiline,
                minLines: 5,
                maxLines: null,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                  //hintText: ' Entry your Address',
                  // border: OutlineInputBorder(
                  // borderRadius: BorderRadius.circular(15.0),
                  // ),
                  // fillColor: Colors.white,
                  // filled: true
                ),
                // style: const TextStyle(
                // fontWeight: FontWeight.bold,
                // fontSize: 16,
                // ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Note Address is Required!';
                  }
                  return null;
                },
              ),
              SizedBox(height: 15),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                    side: const BorderSide(color: Colors.white),
                  ),
                  elevation: 10,
                  minimumSize: const Size(200, 45),
                ),
                child: Text(
                  "Submit",
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  //validate
                  if (_formKey.currentState!.validate()) {
                    //send data to database with this method
                    _onSubmit();
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  Future displayDatePicker(BuildContext context) async {
    var date = await showDatePicker(
      context: context,
      initialDate: selected,
      firstDate: initial,
      lastDate: last,
    );
    if (date != null) {
      setState(() {
        _dateC.text = date.toLocal().toString().split(" ")[0];
      });
    }
  }

  Future displayTimePicker(BuildContext context) async {
    var time = await showTimePicker(context: context, initialTime: timeOfDay);
    if (time != null) {
      setState(() {
        _timeC.text = "${time.hour}:${time.minute}";
      });
    }
  }
}
