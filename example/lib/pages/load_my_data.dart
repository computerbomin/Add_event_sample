import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fauth;
import 'package:example/model/event.dart';
import 'package:flutter/material.dart';
import 'package:calendar_view/calendar_view.dart';
import 'month_view_page.dart';
import '../widgets/user_page.dart';
import '../widgets/user.dart';

class LoadMyData extends StatelessWidget {
  const LoadMyData({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<User>>(
      stream: readUsers(),
      builder: (context, snapshot) {
        if(snapshot.hasError){}
        else if (snapshot.hasData){
          final users = snapshot.data!;
          return CalendarControllerProvider(
              controller: EventController<Event>()
                ..addAll(UserPage.getAllEvents(users)),
              child: Scaffold(
                // title: 'Flutter Calendar Page Demo',
                appBar: AppBar(title: Text('Flutter Calendar Page Demo')),
                body: MonthViewPageDemo(),
              )
          );
        }
        return Text("error");
      }
    );
    // StreamBuilder<List<User>>(
    //     stream: readUsers(),
    //     builder: (context, snapshot) {
    //       if(snapshot.hasError){
    //         //Firebase에서 데이터를 로드할 때 잘못되는 경우 에러 표시
    //         return Text('Something went worng! ${snapshot.error}');
    //       } else if (snapshot.hasData){
    //         final users = snapshot.data!;
    //
    //         return ListView(
    //             children: users.map(buildUser).toList()
    //         );
    //       } else {
    //         return Center(child: CircularProgressIndicator());
    //       }
    //     }
    // ),
  }

  Stream<List<User>> readUsers() => FirebaseFirestore.instance
      .collection('${fauth.FirebaseAuth.instance.currentUser?.uid}')
      .snapshots()
      .map((snapshot) =>
      snapshot.docs.map((doc) => User.fromJson(doc.data())).toList());
}





