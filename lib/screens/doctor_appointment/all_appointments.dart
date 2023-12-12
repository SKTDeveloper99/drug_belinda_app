import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:medical_app_belinda_full/main.dart';

class AllAppointments extends StatefulWidget {
  const AllAppointments({super.key});

  @override
  State<AllAppointments> createState() => _AllAppointmentsState();
}

class _AllAppointmentsState extends State<AllAppointments> {

  late User user;

  @override
  void initState(){
    user = auth.currentUser!;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text("Your Appointments"),
        // actions: <Widget>[
        //   IconButton(
        //     icon: const Icon(Icons.add_alert),
        //     tooltip: 'Show Snackbar',
        //     onPressed: () {
        //       ScaffoldMessenger.of(context).showSnackBar(
        //           const SnackBar(content: Text('This is a snackbar')));
        //     },
        //   ),
        // ],
      ),
      body: StreamBuilder(
          stream: FirebaseFirestore.instance.collection("BeHealthyAppUsers")
              .doc(user.uid)
              .collection("doctorAppointments").orderBy("time",descending: true).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text(snapshot.error.toString()),
              );
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final data = snapshot.requireData.docs.toList();
            // print(data);
            return GridView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                return Card(
                  child: Column(
                    children: [
                      // Expanded(
                      //   flex: 3,
                      //   child: CachedNetworkImage(
                      //     imageUrl: data[index].data().picURL ?? "https:firebasestorage.googleapis.com/v0/b/khoatrancodingminds.appspot.com/o/WechatIMG83.jpg?alt=media&token=90fc2853-7f45-441f-b0de-e83529a86ae0",
                      //     placeholder: (context, url) => const Center(child:  CircularProgressIndicator()),
                      //     errorWidget: (context, url, error) => const Icon(Icons.error),
                      //     imageBuilder: (context, imageProvider) => Container(
                      //       width: double.infinity,
                      //       decoration: BoxDecoration(
                      //         // borderRadius: BorderRadius.circular(16),
                      //         image: DecorationImage(
                      //           image: imageProvider,
                      //           fit: BoxFit.cover,
                      //         ),
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          '${data[index].data()["time"]}',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                    ],
                  ),
                );
              },
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
              ),
            );
          }
      ),
    );
  }
}
