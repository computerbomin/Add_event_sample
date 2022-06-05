import 'dart:convert';

import 'package:calendar_view/calendar_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:example/model/event.dart';
import 'package:firebase_auth/firebase_auth.dart' as fauth;
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';

import '../app_colors.dart';
import '../extension.dart';
import '../pages/load_my_data.dart';
import 'user.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:calendar_view/calendar_view.dart';

class UserPage extends StatefulWidget {
  const UserPage({Key? key}) : super(key: key);

  @override
  State<UserPage> createState() => _UserPageState();

  // static List<CalendarEventData<Event>> getAllEvents() {}
  static List<CalendarEventData<Event>> getAllEvents(List<User> users) {
    List<CalendarEventData<Event>> tmp = [];
    for (var i in users) {
      CalendarEventData<Event>? value = parseEvent(i);
      tmp.add(value);
    }
    return tmp;
  }

  // ############## 백업으로 가져온 데이터 파씽 #############
  static CalendarEventData<Event> parseEvent(User user) {
    final event = CalendarEventData<Event>(
      title: user.title,
      description: user.description,
      // event : user.event.toIso8601String();

      // ############ 파이어베이스에 Color 속성 값 만들어주면 수정 필요 #########
      color: Colors.green,
      startTime: user.startTime,
      endDate: user.endDate,
      endTime: user.endTime,
      date: user.startDate,
      event: Event(
        title: user.title,
      ),
    );

    return event;
  }
}

class _UserPageState extends State<UserPage> {
  // late final users;
  // final void Function(CalendarEventData<Event>)? onEventAdd;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          leading: IconButton(
              icon: Icon(Icons.arrow_back, color: AppColors.white),
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => LoadMyData()));
                //############################MonthViewPageDemo 클래스 이름 수정 필요##################################################
              }),
          centerTitle: true,
          backgroundColor: Colors.orangeAccent,
          title: Text(
            '유저',
            style: TextStyle(
              color: AppColors.white,
              fontFamily: 'Gamja_Flower',
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          elevation: 0.0,
        ),
        extendBodyBehindAppBar: true,
        body: StreamBuilder<List<User>>(
            stream: readUsers(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                //Firebase에서 데이터를 로드할 때 잘못되는 경우 에러 표시
                return Text('Something went worng! ${snapshot.error}');
              } else if (snapshot.hasData) {
                final users = snapshot.data!;

                return ListView(children: users.map(buildUser).toList());
              } else {
                return Center(child: CircularProgressIndicator());
              }
            }),
      );

  CalendarEventData<Event> parseEvent(User user) {
    final event = CalendarEventData<Event>(
      title: user.title,
      description: user.description,
      // event : user.event.toIso8601String();
      color: Colors.green,
      startTime: user.startTime,
      endTime: user.endTime,
      date: user.startDate,
      event: Event(
        title: user.title,
      ),
    );

    return event;
  }

  Widget buildUser(User user) => Container(
        margin: const EdgeInsets.all(2),
        padding: const EdgeInsets.only(left: 22),
        decoration: BoxDecoration(
          color: Colors.blueAccent,
          border: Border.all(
            color: Colors.white,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(7),
        ),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 10,
                ),
                SizedBox(
                  height: 30,
                  child: Text(
                    "id : ${user.id}",
                    style: TextStyle(
                      fontFamily: 'Gamja_Flower',
                      color: AppColors.white,
                      fontSize: 15.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(
                  height: 30,
                  child: Text(
                    "일정 제목 : ${user.title}",
                    style: TextStyle(
                      fontFamily: 'Gamja_Flower',
                      color: AppColors.white,
                      fontSize: 15.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(
                  height: 30,
                  child: Text(
                    "시작 날짜 : ${user.startDate.toIso8601String()}",
                    style: TextStyle(
                      fontFamily: 'Gamja_Flower',
                      color: AppColors.white,
                      fontSize: 15.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(
                  height: 30,
                  child: Text(
                    "종료 날짜 ${user.endDate.toIso8601String()}",
                    style: TextStyle(
                      fontFamily: 'Gamja_Flower',
                      color: AppColors.white,
                      fontSize: 15.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(
                  height: 30,
                  child: Text(
                    "시작 시간 : ${user.startTime.toIso8601String()}",
                    style: TextStyle(
                      fontFamily: 'Gamja_Flower',
                      color: AppColors.white,
                      fontSize: 15.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(
                  height: 30,
                  child: Text(
                    "종료 시간 : ${user.endTime.toIso8601String()}",
                    style: TextStyle(
                      fontFamily: 'Gamja_Flower',
                      color: AppColors.white,
                      fontSize: 15.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(
                  height: 30,
                  child: Text(
                    "세부사항 : ${user.description}",
                    style: TextStyle(
                      fontFamily: 'Gamja_Flower',
                      color: AppColors.white,
                      fontSize: 15.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: IconButton(
                icon: Icon(Icons.delete),
                color: Colors.orangeAccent,
                onPressed: () async {
                  final docUser = FirebaseFirestore.instance
                      .collection(
                          '${fauth.FirebaseAuth.instance.currentUser?.uid}_scheduled')
                      .doc(user.id);
                  if (user.title.contains(user.title)) docUser.delete();
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoadMyData()),
                  );
                },
              ),
            )
          ],
        ),
      );

  Stream<List<User>> readUsers() => FirebaseFirestore.instance
      .collection('${fauth.FirebaseAuth.instance.currentUser?.uid}_scheduled')
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map((doc) => User.fromJson(doc.data())).toList());
}
