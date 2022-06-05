import 'dart:ui';

import 'dart:io';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

import './../screens/edit.dart';
import './../screens/view.dart';
import './../database/db.dart';
import './../database/memo.dart';

import 'package:firebase_auth/firebase_auth.dart' as fauth;


//적은 메모 보여주는 페이지

String deleteId = ''; //전역 변수 설정 -> 삭제할 때 memo.id를 못 불러온다.

class MemoEvent extends StatefulWidget {
  @override
  State<MemoEvent> createState() => _MemoEventState();
}

class _MemoEventState extends State<MemoEvent> {
  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController();

    return Scaffold(
      body: InkWell(
        onDoubleTap: () {
          setState(() {});
        },
        child: Column(
          children: <Widget>[
            Padding(
                padding: EdgeInsets.only(left: 5, top: 10, bottom: 20),
                child: Container(
                    /*
                  child: Text('메모',
                      style: TextStyle(fontSize: 36, color: Colors.blue)),
                  alignment: Alignment.centerLeft,
                   */
                    )),
            Expanded(child: memoBuilder(context)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
              context, CupertinoPageRoute(builder: (context) => EditPage()));
        },
        tooltip: '메모 추가를 위해 클릭하시오.',
        label: Text('메모 추가', style: TextStyle(fontFamily: 'Gamja_Flower'),),
        icon: Icon(Icons.add),
        backgroundColor: Colors.orangeAccent,
      ),
    );
  }

  //파이어베이스 유저 이름
  Future createUser({required String name}) async {
    //일단 스킵 -> 클릭하면 갱신되는 걸로
  }

  //메모 불러오기
  Future<List<Memo>> loadMemo() async {
    DBHelper sd = DBHelper();
    return await sd.memos();
  }

  //메모 삭제
  Future<void> deleteMemo(String id) async {
    DBHelper sd = DBHelper();
    return await sd.deleteMemo(id);
  }

  void showAlertDialog(BuildContext context) async {
    String result = await showDialog(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('삭제 경고'),
          titleTextStyle: TextStyle(fontFamily: 'Gamja_Flower', color: Colors.blueAccent),
          content: Text("정말 삭제하시겠습니까?\n삭제된 메모는 복구되지 않습니다."
              "\n\n이미 업로드한 일기를 삭제하려면\n'업로드한 일기'의 삭제 버튼을 누르시오."),
          contentTextStyle: TextStyle(fontFamily: 'Gamja_Flower', color: Colors.black),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: TextStyle(fontFamily: 'Gamja_Flower', color: Colors.blueAccent),
              ),
              child: Text('삭제'),
              onPressed: () {
                Navigator.pop(context, "삭제");
                setState(() {
                  deleteMemo(deleteId);
                });
                deleteId = '';
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                textStyle: TextStyle(fontFamily: 'Gamja_Flower', color: Colors.blueAccent),
              ),
              child: Text('취소'),
              onPressed: () {
                deleteId = '';
                Navigator.pop(context, "취소");
              },
            ),
          ],
        );
      },
    );
  }

  //이미지 추가
  File? image;

  Future pickImage() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) return;

      final imageTemporary = File(image.path);
      setState(() => this.image = imageTemporary);
      //final imagePermanent = await saveImagePermanently(image.path);
      //setState(() => this.image = imagePermanent);
    } on PlatformException catch (e) {
      print('이미지 로드 실패\n$e');
    }
  }

  /*
  Future<File> saveImagePermanently(String imagePath) async {
    final directory = await getApplicationDocumentsDirectory();
    final name = basename(imagePath);
    final image = File('${directory.path}/$name');

    return File(imagePath).copy(image.path);
  }
   */

  Widget memoBuilder(BuildContext parentContext) {
    return FutureBuilder(
      builder: (context, Snap) {
        return ListView.builder(
          physics: BouncingScrollPhysics(),
          itemCount: (Snap.data as List).length,
          itemBuilder: (context, index) {
            Memo memo = (Snap.data as List)[index];

            //메모 연동
            Future createUser({required String name}) async {
              final docUser = FirebaseFirestore.instance
                  .collection('${fauth.FirebaseAuth.instance.currentUser?.uid}memomemo')
                  .doc(memo.id);

              final json = {
                'memo_id': memo.id,
                'memo_title': memo.title,
                'memo_text': memo.text,
                'memo_createTime': memo.createTime,
                'memo_editTime': memo.editTime,
              };

              await docUser.set(json);
            }

            //갱신 알림
            Future showAlertRefresh(BuildContext context) async {
              String result = await showDialog(
                context: context,
                barrierDismissible: false, // user must tap button!
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('일기 갱신'),
                    titleTextStyle: TextStyle(fontFamily: 'Gamja_Flower', color: Colors.blueAccent),
                    content: Text("일기를 업로드 하시겠습니까?"),
                    contentTextStyle: TextStyle(fontFamily: 'Gamja_Flower', color: Colors.black),
                    actions: <Widget>[
                      TextButton(
                        style: TextButton.styleFrom(
                          textStyle: TextStyle(fontFamily: 'Gamja_Flower', color: Colors.blueAccent),
                        ),
                        child: Text('갱신'),
                        onPressed: () {
                          Navigator.pop(context, "갱신");
                          setState(() {
                            createUser(name: '${fauth.FirebaseAuth.instance.currentUser?.uid}memomemo');
                          });
                        },
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                          textStyle: TextStyle(fontFamily: 'Gamja_Flower', color: Colors.blueAccent),
                        ),
                        child: Text('취소'),
                        onPressed: () {
                          deleteId = '';
                          Navigator.pop(context, "취소");
                        },
                      ),
                    ],
                  );
                },
              );
            }

            return InkWell(
              onDoubleTap: () {
                showAlertRefresh(parentContext);
              },
              onLongPress: () {
                setState(() {
                  deleteId = memo.id;
                  showAlertDialog(parentContext);
                });
              }, //길게 누르면 삭제
              child: Container(
                height: 600,
                alignment: Alignment.center,
                padding: EdgeInsets.all(15),
                margin: EdgeInsets.all(5),
                decoration: BoxDecoration(
                  /*
                  image: const DecorationImage(
                    image: NetworkImage(
                        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ1qpG7o-AZtARdfRmiYS29FR-NFWrGtKOcNQ&usqp=CAU'),
                    fit: BoxFit.cover,
                  ),
                   */
                  color: Colors.lightBlueAccent,
                  border: Border.all(
                    color: Colors.white,
                    width: 3,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: <Widget>[
                    /*
                      Scaffold(
                        body: Image.network('https://picsum.photos/250?image=9'),
                      ),
                       */
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(
                          height: 50,
                          child: Text(
                            memo.title,
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontFamily: 'Gamja_Flower',
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(
                          height: 30,
                          child: Text(
                            memo.text,
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              fontFamily: 'Gamja_Flower',
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          image != null
                              ? Image.file(
                                  image!,
                                  height: 320,
                                  fit: BoxFit.cover,
                                )
                              : Image.asset('image/speaking.png'),
                          ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                primary: Colors.orangeAccent,
                              ),
                              onPressed: () => pickImage(),
                              icon: Icon(Icons.camera_alt),
                              label: Text('')),
                          Text(
                            "최종 수정 : " + memo.editTime.split('.')[0],
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.white,
                              fontFamily: 'Gamja_Flower',
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ]),
                  ],
                ),
              ),
            );
          },
        );
      },
      future: loadMemo(),
    );
  }
}
