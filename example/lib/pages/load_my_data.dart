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
    //############ 이벤트 데이터 리스트 선언 ############
    late List<CalendarEventData<Event>> _events;

    return StreamBuilder<List<User>>(
      stream: readUsers(),
      builder: (context, snapshot) {
        if(snapshot.hasError){}
        else if (snapshot.hasData){
          final users = snapshot.data!;

          //############ 이벤트 데이터 리스트 초기화 ############
          _events = UserPage.getAllEvents(users);

          return CalendarControllerProvider(
              controller: EventController<Event>()
                ..addAll(_events),
              child: Scaffold(
                // title: 'Flutter Calendar Page Demo',
                // appBar: AppBar(title: Text('Flutter Calendar Page Demo')),
                body: MonthViewPageDemo(),
              )
          );
        }
        return Text("error");
      }
    );
  }

  Stream<List<User>> readUsers() => FirebaseFirestore.instance
      .collection('${fauth.FirebaseAuth.instance.currentUser?.uid}_scheduled')
      .snapshots()
      .map((snapshot) =>
      snapshot.docs.map((doc) => User.fromJson(doc.data())).toList());
}





