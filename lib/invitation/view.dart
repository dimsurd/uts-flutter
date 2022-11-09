import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../login_page.dart';
class View extends StatefulWidget {
 View({required this.id});
 String id;
 @override
 State<View> createState() => _ViewState();
}
class _ViewState extends State<View> {
 final _formKey = GlobalKey<FormState>();
 //inisialize field
 String username = "";
 var code = TextEditingController();
 var address = TextEditingController();
 String? schedule_date, invitation_code, time_schedule, status, description;
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
 //Http to get detail data
 Future _getData() async {
 try {
 final response = await http.get(Uri.parse(
 //you have to take the ip address of your computer.
 //because using localhost will cause an error
 //get detail data with id
 "https://nscis.nsctechnology.com/index.php?r=t-invitation/view-api&id='${widget.id}'"));
 // if response successful
 if (response.statusCode == 200) {
 final data = jsonDecode(response.body);
 setState(() {
 //code = TextEditingController(text: data['invitation_code']);
 invitation_code = data['invitation_code'] !;
 schedule_date = data['schedule_date'];
 time_schedule = data['time_schedule'];
 status = data['status'];
 description = data['description'];
 });
 }
 } catch (e) {
 print(e);
 }
 }
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
 'Invitation Code: ${invitation_code}',
 style: TextStyle(color: Colors.black),
 ),
 Text(
 'Date: ${schedule_date}',
 style: TextStyle(color: Colors.black),
 ),
 Text(
 'Time: ${time_schedule}',
 style: TextStyle(color: Colors.black),
 ),
 Text(
 'Status: ${status}',
 style: TextStyle(color: Colors.black),
 ),
 Text(
 'Description: ${description}',
 style: TextStyle(color: Colors.black),
 ),
 SizedBox(
 height: 10,
 ),
 if (status == 'Created')
 Center( 
 child: ElevatedButton.icon(
 style: ElevatedButton.styleFrom(
 primary: Colors.blue,
 shape: RoundedRectangleBorder(
 borderRadius: BorderRadius.circular(10.0),
 side: const BorderSide(color: Colors.white),
 ),
 elevation: 10,
 minimumSize: const Size(150, 40)),
 onPressed: () async {
 final visit =
 'Detail information, please visit the site';
 final url =
 'https://nscis.nsctechnology.com/index.php?r=site%2Fvisit';
 final info =
 'Select the "Visit" menu and insert these codes:';
 await Share.share(
 '${visit} ${url} ${info} ${invitation_code}');
 },
 icon: const Icon(Icons.share),
 label: const Text(
 "Share",
 style: TextStyle(
 fontSize: 18, fontWeight: FontWeight.bold),
 )),
 ),
 ],
 ),
 ),
 ),
 ),
 );
 }
}