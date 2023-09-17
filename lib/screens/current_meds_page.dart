import 'dart:async';
import 'dart:developer';
import 'package:medical_app_belinda_full/main.dart';
import 'package:medical_app_belinda_full/screens/add_medicine.dart';
import 'package:medical_app_belinda_full/screens/drug_details_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class CurrentMedsScreen extends StatefulWidget {
  const CurrentMedsScreen({Key? key}) : super(key: key);

  @override
  _CurrentMedsScreenState createState() => _CurrentMedsScreenState();
}

class _CurrentMedsScreenState extends State<CurrentMedsScreen> {
  late User user;
  late DatabaseReference _superSearchTermsRef;
  late DatabaseReference _messagesRef;
  late StreamSubscription<DatabaseEvent> _superSearchTermsSubscription;
  late StreamSubscription<DatabaseEvent> _messagesSubscription;
  bool _anchorToBottom = false;
  List<String>superSearchTerms = [];
  FirebaseException? _error;
  bool initialized = false;

  @override
  void initState() {
    user = auth.currentUser!;
    auth.userChanges().listen((event) {
      if (event != null && mounted) {
        setState(() {
          user = event;
        });
      }
    });
    init();
    super.initState();
  }

  Future<void> init() async {
    final database = FirebaseDatabase.instance;
    _superSearchTermsRef = database.ref('users/${user.uid}/Drugs');
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
  
  Future<void> _deleteMessage(DataSnapshot snapshot) async {
    final messageRef = _messagesRef.child(snapshot.key!);
    await messageRef.remove();
  }

  void _setAnchorToBottom(bool? value) {
    if (value == null) {
      return;
    }

    setState(() {
      _anchorToBottom = value;
    });
  }


  @override
  Widget build(BuildContext context) {
    if (!initialized) {
      return Scaffold(
      body: Column(
        children: [
          Image.network("https://firebasestorage.googleapis.com/v0/b/important-reminders.appspot.com/o/NewTrimedPicOfNoMed.png?alt=media&token=3e1cadd0-2dcf-4ef6-bc1b-a24d61e40364"),
        ],
      ),
    );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Current Meds'),
        actions: [
          IconButton(
            onPressed: () {
              //method to show the search bar
              showSearch(
                  context: context,
                  // delegate to customize the search bar
                  delegate: CustomSearchDelegate()
              );
            },
            icon: const Icon(Icons.search),
          )
        ],
      ),
      body: Column(
        children: [
          ListTile(
            leading: Checkbox(
              onChanged: _setAnchorToBottom,
              value: _anchorToBottom,
            ),
            title: const Text('Anchor to bottom'),
          ),
          Flexible(
            child: FirebaseAnimatedList(
              key: ValueKey<bool>(_anchorToBottom),
              query: _messagesRef,
              reverse: _anchorToBottom,
              itemBuilder: (context, snapshot, animation, index) {
                final medsList = snapshot.value! as Map;
                return GestureDetector(
                  onTap: () async {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => DrugDetailScreen(info: medsList)),
                        );
                  },
                  child: SizeTransition(
                    sizeFactor: animation,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(50.0),
                        topRight: Radius.circular(50.0),
                      ),
                      child: Card(
                        child: ListTile(
                          trailing: IconButton(
                            onPressed: () => _deleteMessage(snapshot),
                            icon: const Icon(Icons.delete),
                          ),
                          title: Text(medsList["title"]),
                          subtitle: Text(medsList["description"]),
                          leading: Image.network(
                              medsList["medPicURL"] ?? "",
                              width: 50,
                              height: 50,
                           ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const AddMedPage()),
          );
        },
        label: const Text('Add Your Prescriptions'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}

class CustomSearchDelegate extends SearchDelegate {
// Demo list to show querying
  List<String> searchTerms = [
    "Aspirin",
    "Benzonatate",
    "Methadone",
    "Epclusa",
    "Plan B",
    "Prednisone",
    "Zetia",
    "Tylernol"
  ];

// first overwrite to
// clear the search text
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: Icon(Icons.clear),
      ),
    ];
  }

// second overwrite to pop out of search menu
  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, null);
      },
      icon: Icon(Icons.arrow_back),
    );
  }

// third overwrite to show query result
  @override
  Widget buildResults(BuildContext context) {
    List<String> matchQuery = [];
    for (var fruit in searchTerms) {
      if (fruit.toLowerCase().contains(query.toLowerCase())) {
        matchQuery.add(fruit);
      }
    }
    return ListView.builder(
      itemCount: matchQuery.length,
      itemBuilder: (context, index) {
        var result = matchQuery[index];
        return ListTile(
          title: Text(result),
        );
      },
    );
  }

// last overwrite to show the
// querying process at the runtime
  @override
  Widget buildSuggestions(BuildContext context) {
    List<String> matchQuery = [];
    for (var fruit in searchTerms) {
      if (fruit.toLowerCase().contains(query.toLowerCase())) {
        matchQuery.add(fruit);
      }
    }
    return ListView.builder(
      itemCount: matchQuery.length,
      itemBuilder: (context, index) {
        var result = matchQuery[index];
        return GestureDetector(
          onTap: () {
            launchUrl(Uri.parse("https://www.drugs.com/$result.html"));
          },
          child: ListTile(
            title: Text(result),
          ),
        );
      },
    );
  }
}

