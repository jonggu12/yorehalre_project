import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NutritionDetailPage extends StatefulWidget {
  final String uid;

  NutritionDetailPage({Key? key, required this.uid}) : super(key: key);

  @override
  _NutritionDetailPageState createState() => _NutritionDetailPageState();
}

class _NutritionDetailPageState extends State<NutritionDetailPage> {
  Future<Map<String, dynamic>?> fetchUserInfo() async {
    var userDoc = await FirebaseFirestore.instance.collection('users').doc(widget.uid).get();
    return userDoc.data();
  }

  String determineAgeGroup(int age) {
    if (age >= 75) return '75+';
    if (age >= 65) return '65-74';
    if (age >= 50) return '50-64';
    if (age >= 30) return '30-49';
    if (age >= 19) return '19-29';
    return '정보 없음';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('영양성분 섭취기준'),
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: fetchUserInfo(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('데이터를 불러오는데 오류가 발생했습니다.'));
          } else if (snapshot.data == null) {
            return Center(child: Text('사용자 정보가 없습니다.'));
          }

          var userInfo = snapshot.data!;
          var age = int.parse(userInfo['age'].toString());
          var gender = userInfo['gender'];
          var ageGroup = determineAgeGroup(age);

          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('nutrition_limit')
                .doc('$gender $ageGroup')
                .get(),
            builder: (context, nutritionSnapshot) {
              if (nutritionSnapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (nutritionSnapshot.hasError) {
                return Center(child: Text('영양 정보를 불러오는데 오류가 발생했습니다.'));
              } else if (!nutritionSnapshot.hasData) {
                return Center(child: Text('영양 정보가 없습니다.'));
              }

              var nutritionData = nutritionSnapshot.data!.data() as Map<String, dynamic>;
              return ListView(
                children: nutritionData.entries.map((entry) {
                  return ListTile(
                    title: Text(entry.key),
                    subtitle: Text('${entry.value}'),
                  );
                }).toList(),
              );
            },
          );
        },
      ),
    );
  }
}
