import 'dart:convert';
import 'package:evisitor_project/home_page.dart';
import 'package:evisitor_project/report.dart';
import 'package:evisitor_project/scan/report_visit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:evisitor_project/login_page.dart';
class Update extends StatefulWidget {
  Update({required this.id});
  String? id;
  @override
  State<Update> createState() => _UpdateState();
}

class _UpdateState extends State<Update> {
  final _formKey = GlobalKey<FormState>();
//inisialize field
  String username = "";
  var status_visit = TextEditingController();
  var status_done = TextEditingController();
  String? id_visitor,
      schedule_date,
      host,
      time_schedule,
      invitation_code,
      email,
      no_phone,
      full_name,
      company,
      address,
      status,
      visitor_code,
      security;
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

  _getDataSecurity() async {
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      var islogin = pref.getBool("is_login");
      setState(() {
        username = pref.getString("username")!;
      });
      print(username);
      final response = await http.get(Uri.parse(
//you have to take the ip address of your computer.
//because using localhost will cause an error
          "https://nscis.nsctechnology.com/index.php?r=t-visitor/view-security&id=" +
              username));
// if response successful
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
// entry data to variabel list _get
        setState(() {
          security = data['item_name'];
        });
      }
    } catch (e) {
      print(e);
    }
  }

//Http to get detail data
  _getData() async {
    try {
      final response = await http.get(Uri.parse(
//you have to take the ip address of your computer.
//because using localhost will cause an error
//get detail data with id
          "http://nscis.nsctechnology.com/index.php?r=t-visitor/view-api&id=${widget.id}"));
// if response successful
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
//code = TextEditingController(text: data['invitation_code']);
          host = data['host'];
//invitation_code = data['invitation_code'] !;
          schedule_date = data['schedule_date'];
          time_schedule = data['time_schedule'];
          status = data['status'];
          full_name = data['full_name'];
          email = data['email'];
          no_phone = data['no_phone'];
          full_name = data['full_name'];
          company = data['company'];
          address = data['address'];
          status_visit = TextEditingController(text: 'Validasi');
          status_done = TextEditingController(text: 'Finish');
          id_visitor = data['id_visitor'];
        });
      }
    } catch (e) {
      print(e);
    }
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
    _getDataSecurity();
  }

  Future _onUpdateSecurity(context) async {
    EasyLoading.show(status: 'Saving...');
    try {
      return await http.post(
        Uri.parse(
            "https://nscis.nsctechnology.com/index.php?r=t-visitor/update-api"),
        body: {
          "id_visitor": id_visitor,
          "status": "Validasi",
        },
      ).then((value) {
//print message after insert to database
//you can improve this message with alert dialog
        EasyLoading.showSuccess('data successfully saved');
        var data = jsonDecode(value.body);
        print(data["message"]);
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => HomePage()),
            (Route<dynamic> route) => false);
        EasyLoading.dismiss();
      });
    } catch (e) {
      print(e);
    }
  }

  Future _onUpdateHost(context) async {
    EasyLoading.show(status: 'Saving...');
    try {
      return await http.post(
        Uri.parse(
            "https://nscis.nsctechnology.com/index.php?r=t-visitor/update-api"),
        body: {
          "id_visitor": id_visitor,
          "status": "Finish",
        },
      ).then((value) {
//print message after insert to database
//you can improve this message with alert dialog
        EasyLoading.showSuccess('data successfully saved');
        var data = jsonDecode(value.body);
        print(data["message"]);
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => ReportVisit()),
            (Route<dynamic> route) => false);
        EasyLoading.dismiss();
      });
    } catch (e) {
      print(e);
    }
  }

  ReportVisit() => ReportVisit();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 177, 172, 172),
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
        child: Card(
          child: Container(
            height: 200,
            padding: EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Date: ${schedule_date}',
                  style: TextStyle(color: Colors.black),
                ),
                Text(
                  'Time: ${time_schedule}',
                  style: TextStyle(color: Colors.black),
                ),
                Text(
                  'Name: ${full_name}',
                  style: TextStyle(color: Colors.black),
                ),
                Text(
                  'Company: ${company}',
                  style: TextStyle(color: Colors.black),
                ),
                Text(
                  'Email: ${email}',
                  style: TextStyle(color: Colors.black),
                ),
                Text(
                  'Phone Number: ${no_phone}',
                  style: TextStyle(color: Colors.black),
                ),
                Text(
                  'Status: ${status}',
                  style: TextStyle(color: Colors.black),
                ),
                Text(
                  'Address: ${address}',
                  style: TextStyle(color: Colors.black),
                ),
                SizedBox(
                  height: 10,
                ),
                if (status == 'Created' && security == 'security')
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Text(
                        "Accept",
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () {
//validate
                        if (_formKey.currentState!.validate()) {
//send data to database with this method
                          _onUpdateSecurity(context);
                        }
                      },
                    ),
                  ),
                if (status == 'Validasi' && username == host)
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Text(
                        "Accept",
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () {
//validate
                        if (_formKey.currentState!.validate()) {
//send data to database with this method
                          _onUpdateHost(context);
                        }
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
