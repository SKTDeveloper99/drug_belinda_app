import 'dart:async';
import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medical_app_belinda_full/main.dart';
import 'package:medical_app_belinda_full/screens/drug_details_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DrugToday extends StatefulWidget {
  const DrugToday({Key? key}) : super(key: key);

  @override
  _DrugTodayState createState() => _DrugTodayState();
}

class _DrugTodayState extends State<DrugToday> {
  late User user;
  late DatabaseReference _superSearchTermsRef;
  late DatabaseReference _messagesRef;
  late StreamSubscription<DatabaseEvent> _superSearchTermsSubscription;
  late StreamSubscription<DatabaseEvent> _messagesSubscription;
  bool _anchorToBottom = false;
  List<String>superSearchTerms = [];
  FirebaseException? _error;
  bool initialized = false;
  List<String> allDrugs = [];

  @override
  void initState() {
    user = auth.currentUser!;

    init();
    super.initState();
  }

  Future<void> init() async {
    final database = FirebaseDatabase.instance;
    _messagesRef = database.ref('users/${user.uid}/medLogs');
    database.setLoggingEnabled(false);

    if (!kIsWeb) {
      database.setPersistenceEnabled(true);
      database.setPersistenceCacheSizeBytes(10000000);
    }

    setState(() {
      initialized = true;
    });

    final messagesQuery = _messagesRef.limitToLast(20);
    final superSearchTermsQuery = _superSearchTermsRef.limitToLast(20);

    _messagesSubscription = messagesQuery.onChildAdded.listen(
          (DatabaseEvent event) {

      },
      onError: (Object o) {
        final error = o as FirebaseException;
        print('Error: ${error.code} ${error.message}');
      },
    );

    _superSearchTermsSubscription = superSearchTermsQuery.onChildAdded.listen(
          (DatabaseEvent event) {
        final myDrugs = event.snapshot!.value as Map;
        final myDrugs1 = Map<String,dynamic>.from(myDrugs);
        superSearchTerms.addAll(myDrugs1.keys);
      },
      onError: (Object o) {
        final error = o as FirebaseException;
        print('Error: ${error.code} ${error.message}');
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    _messagesSubscription.cancel();
    _superSearchTermsSubscription.cancel();
  }

  // Future<void> _deleteMessage(DataSnapshot snapshot) async {
  //   final messageRef = _messagesRef.child(snapshot.key!);
  //   Map love = snapshot.value! as Map;
  //   String drug = love["title"];
  //   await messageRef.remove();
  //   await FirebaseFirestore.instance
  //       .collection("BeHealthyAppUsers")
  //       .doc(user.uid)
  //       .update({
  //     "drugsUsing": FieldValue.arrayRemove([drug]),
  //   }
  //   );
  // }

  // void _setAnchorToBottom(bool? value) {
  //   if (value == null) {
  //     return;
  //   }
  //
  //   setState(() {
  //     _anchorToBottom = value;
  //   });
  // }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Today's Medicines"),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const Expanded(
            flex: 1,
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Morning - In the AMs"),
                  // TextButton(onPressed: () {
                  //   _saveDrugsOnTime(state: "morning");
                  // },
                  //     child: const Text("Edit"))
                ],
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                color: Colors.green,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0,8,0,8),
                  child: Column(
                    children: [
                      Flexible(
                        child: FirebaseAnimatedList(
                          key: ValueKey<bool>(_anchorToBottom),
                          query: _messagesRef.orderByChild("morning").equalTo("true"),
                          reverse: _anchorToBottom,
                          itemBuilder: (context, snapshot, animation, index) {
                            final medsList = snapshot.value! as Map;
                            final medsListKey = snapshot.key;
                            return GestureDetector(
                              onTap: () async {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => DrugDetailScreen(info: medsList,medListKey: medsListKey,morning: medsList["morning"],afternoon: medsList["afternoon"], evening: medsList["evening"])),
                                );
                              },
                              child: SizeTransition(
                                sizeFactor: animation,
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(10.0),
                                    topRight: Radius.circular(10.0),
                                    bottomLeft: Radius.circular(10.0),
                                    bottomRight: Radius.circular(10.0),
                                  ),
                                  child: Card(
                                    child: ListTile(
                                      // trailing: IconButton(
                                      //   onPressed: () => _deleteMessage(snapshot),
                                      //   icon: const Icon(Icons.delete),
                                      // ),
                                      title: Text(medsList["title"]),
                                      subtitle: Text(medsList["description"]),
                                      leading: Container(
                                        width: 50,
                                        height: 50,
                                        child: CachedNetworkImage(
                                          imageUrl: medsList["medPicURL"] ?? "https:firebasestorage.googleapis.com/v0/b/khoatrancodingminds.appspot.com/o/WechatIMG83.jpg?alt=media&token=90fc2853-7f45-441f-b0de-e83529a86ae0",
                                          placeholder: (context, url) => const Center(child:  CircularProgressIndicator()),
                                          errorWidget: (context, url, error) => const Icon(Icons.error),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          ),
          const Expanded(
            flex: 1,
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Afternoon - In the PMs"),
                  // TextButton(onPressed: () {
                  //   _saveDrugsOnTime(state: "Afternoon");
                  // },
                  //     child: const Text("Edit"))
                ],
              ),
            ),
          ),
          Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  color: Colors.grey,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0,8,0,8),
                    child: Column(
                      children: [
                        Flexible(
                          child: FirebaseAnimatedList(
                            key: ValueKey<bool>(_anchorToBottom),
                            query: _messagesRef.orderByChild("afternoon").equalTo("true"),
                            reverse: _anchorToBottom,
                            itemBuilder: (context, snapshot, animation, index) {
                              final medsList = snapshot.value! as Map;
                              final medsListKey = snapshot.key;
                              return GestureDetector(
                                onTap: () async {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => DrugDetailScreen(info: medsList,medListKey: medsListKey,morning: medsList["morning"],afternoon: medsList["afternoon"], evening: medsList["evening"])),
                                  );
                                },
                                child: SizeTransition(
                                  sizeFactor: animation,
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(10.0),
                                      topRight: Radius.circular(10.0),
                                      bottomLeft: Radius.circular(10.0),
                                      bottomRight: Radius.circular(10.0),
                                    ),
                                    child: Card(
                                      child: ListTile(
                                        // trailing: IconButton(
                                        //   onPressed: () => _deleteMessage(snapshot),
                                        //   icon: const Icon(Icons.delete),
                                        // ),
                                        title: Text(medsList["title"]),
                                        subtitle: Text(medsList["description"]),
                                        leading: Container(
                                          width: 50,
                                          height: 50,
                                          child: CachedNetworkImage(
                                            imageUrl: medsList["medPicURL"] ?? "https:firebasestorage.googleapis.com/v0/b/khoatrancodingminds.appspot.com/o/WechatIMG83.jpg?alt=media&token=90fc2853-7f45-441f-b0de-e83529a86ae0",
                                            placeholder: (context, url) => const Center(child:  CircularProgressIndicator()),
                                            errorWidget: (context, url, error) => const Icon(Icons.error),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ),
          const Expanded(
            flex: 1,
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Evening - In the PMs"),
                  // TextButton(onPressed: () {
                  //   _saveDrugsOnTime(state: "Evening");
                  // },
                  //     child: const Text("Edit"))
                ],
              ),
            ),
          ),
          Expanded(
              flex: 4,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                color: Colors.pinkAccent,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0,8,0,8),
                  child: Column(
                    children: [
                      Flexible(
                        child: FirebaseAnimatedList(
                          key: ValueKey<bool>(_anchorToBottom),
                          query:_messagesRef.orderByChild("evening").equalTo("true"),
                          reverse: _anchorToBottom,
                          itemBuilder: (context, snapshot, animation, index) {
                            final medsList = snapshot.value! as Map;
                            final medsListKey = snapshot.key;
                            return GestureDetector(
                              onTap: () async {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => DrugDetailScreen(info: medsList,medListKey: medsListKey,morning: medsList["morning"],afternoon: medsList["afternoon"], evening: medsList["evening"])),
                                );
                              },
                              child: SizeTransition(
                                sizeFactor: animation,
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(10.0),
                                    topRight: Radius.circular(10.0),
                                    bottomLeft: Radius.circular(10.0),
                                    bottomRight: Radius.circular(10.0),
                                  ),
                                  child: Card(
                                    child: ListTile(
                                      // trailing: IconButton(
                                      //   onPressed: () => _deleteMessage(snapshot),
                                      //   icon: const Icon(Icons.delete),
                                      // ),
                                      title: Text(medsList["title"]),
                                      subtitle: Text(medsList["description"]),
                                      leading: Container(
                                        width: 50,
                                        height: 50,
                                        child: CachedNetworkImage(
                                          imageUrl: medsList["medPicURL"] ?? "https:firebasestorage.googleapis.com/v0/b/khoatrancodingminds.appspot.com/o/WechatIMG83.jpg?alt=media&token=90fc2853-7f45-441f-b0de-e83529a86ae0",
                                          placeholder: (context, url) => const Center(child:  CircularProgressIndicator()),
                                          errorWidget: (context, url, error) => const Icon(Icons.error),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _saveDrugsOnTime({required String state}) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("$state Drugs"),
          );
        });
  }
}


