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

  static CalendarEventData<Event> parseEvent(User user) {
    final event = CalendarEventData<Event>(
      title : user.title,
      description : user.description,
      // event : user.event.toIso8601String();
      color : Colors.green,
      startTime : user.startTime,
      endTime : user.endTime,
      date : user.startDate,
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
      icon: Icon(Icons.arrow_back, color: AppColors.black),
      onPressed: () => Navigator.of(context).pop(),
    ), 
      centerTitle: true,
      backgroundColor: Colors.transparent,
      title: Text('유저', 
      style: TextStyle(
        color: AppColors.black,
        fontFamily: 'Noto_Serif_KR',
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
        if(snapshot.hasError){
          //Firebase에서 데이터를 로드할 때 잘못되는 경우 에러 표시
          return Text('Something went worng! ${snapshot.error}');
        } else if (snapshot.hasData){
          final users = snapshot.data!;

          return ListView(
            children: users.map(buildUser).toList()
          );
        } else {
          return Center(child: CircularProgressIndicator());
        }
      }
    ),
   );

  CalendarEventData<Event> parseEvent(User user) {
    final event = CalendarEventData<Event>(
      title : user.title,
      description : user.description,
      // event : user.event.toIso8601String();
      color : Colors.green,
      startTime : user.startTime,
      endTime : user.endTime,
      date : user.startDate,
      event: Event(
        title: user.title,
      ),
    );

    return event;
  }


  Widget buildUser(User user) => Container(
    margin: const EdgeInsets.all(2),
    padding: const EdgeInsets.all(2),
    decoration: BoxDecoration(
      border: Border.all(
        color: Color(0xffb3b9ed),
        width: 2,
        ),
      borderRadius: BorderRadius.circular(7),
      
    ),
    child: Column(
      children: [
      Text("일정 제목 : ${user.title}",
      style: TextStyle(
        fontFamily: 'Noto_Serif_KR',
        color: AppColors.black,
        fontSize: 15.0,
        fontWeight: FontWeight.bold,
      ),
      ),
      Text("시작 날짜 : ${user.startDate.toIso8601String()}",
      style: TextStyle(
        fontFamily: 'Noto_Serif_KR',
        color: AppColors.black,
        fontSize: 15.0,
        fontWeight: FontWeight.bold,
      ),
      ),
      Text("종료 날짜 ${user.endDate.toIso8601String()}",
      style: TextStyle(
        fontFamily: 'Noto_Serif_KR',
        color: AppColors.black,
        fontSize: 15.0,
        fontWeight: FontWeight.bold,
      ),
      ),
      Text("시작 시간 : ${user.startTime.toIso8601String()}",
      style: TextStyle(
        fontFamily: 'Noto_Serif_KR',
        color: AppColors.black,
        fontSize: 15.0,
        fontWeight: FontWeight.bold,
      ),
      ),
      Text("종료 시간 : ${user.endTime.toIso8601String()}",
      style: TextStyle(
        fontFamily: 'Noto_Serif_KR',
        color: AppColors.black,
        fontSize: 15.0,
        fontWeight: FontWeight.bold,
      ),
      ),
      Text("세부사항 : ${user.description}",
      style: TextStyle(
        fontFamily: 'Noto_Serif_KR',
        color: AppColors.black,
        fontSize: 15.0,
        fontWeight: FontWeight.bold,
      ),
      ),
      SizedBox(height: 10,)
      ],
    ),
  );

  Stream<List<User>> readUsers() => FirebaseFirestore.instance
     .collection('${fauth.FirebaseAuth.instance.currentUser?.uid}')
     .snapshots()
     .map((snapshot) => 
         snapshot.docs.map((doc) => User.fromJson(doc.data())).toList());

  void f_addEvent(List<User> user) {
    final event = f_createEvent(user[0]);
    if (event == null){
      return showTast('f_addEvent No data');
    }
    // ################# 리스트에 반영 되는 부분 ############
    CalendarControllerProvider
        .of<Event>(context)
        .controller
        .add(event);
    // setState((){});
  }

  // Future<void> addDataToList(User user) async {
  //   // final event = await getEvent(
  //   //     users._startDate,
  //   //     users._endTime,
  //   //     users._startTime,
  //   //     users._description,
  //   //     users._endDate,
  //   //     users._title
  //   // );
  //   final event = await context.pushRoute<CalendarEventData<Event>>(
  //     f_createEvent(user)
  //   );
  //   if (event == null){
  //     return ;
  //   }
  //   // ################# 리스트에 반영 되는 부분 ############
  //   CalendarControllerProvider
  //       .of<Event>(context)
  //       .controller
  //       .add(event);
  // }

  CalendarEventData<Event> getEvent(DateTime _startDate, DateTime _endTime,
      DateTime _startTime, String _description, DateTime _endDate, String _title) {
    final event = CalendarEventData<Event>(
      date: _startDate,
      color: Colors.green,
      endTime: _endTime,
      startTime: _startTime,
      description: _description,
      endDate: _endDate,
      title: _title,
      event: Event(
        title: _title,
      ),
    );
  // CalendarEventData<Event> getEvent() {
  //   final event = CalendarEventData<Event>(
  //     date: users._startDate,
  //     color: Colors.blue,
  //     endTime: users._endTime,
  //     startTime: users._startTime,
  //     description: users._description,
  //     endDate: users._endDate,
  //     title: users._title,
  //     event: Event(
  //       title: users._title,
  //     ),
  //   );

    return event;
  }

  CalendarEventData<Event> f_createEvent(User users) {
    //############# 입력한 값들로 이벤트 객체 생성 ###########
    final event = CalendarEventData<Event>(
      date: users.startDate,
      color: Colors.green,
      endTime: users.endDate,
      startTime: users.startTime,
      description: users.description,
      endDate: users.endDate,
      title: users.title,
      event: Event(
        title: users.title,
      ),
    );

    return event;
  }

  void showTast(String message) {
    Fluttertoast.showToast(msg : message,
    backgroundColor : Colors.white,
    toastLength : Toast.LENGTH_SHORT,
    gravity : ToastGravity.BOTTOM);
  }
}

