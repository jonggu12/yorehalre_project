import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  final String uid;

  ProfilePage({Key? key, required this.uid}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  String selectedHealthGoal = '다이어트'; // 초기값 설정
  String selectedActivityLevel = '비활동적'; // 초기값 설정
  final TextEditingController ageController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController weightController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    ageController.dispose();
    heightController.dispose();
    weightController.dispose();
    super.dispose();
  }

  void _updateProfile() async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(widget.uid).update({
        'name': nameController.text,
        'email': emailController.text,
        'age': int.tryParse(ageController.text),
        'height': int.tryParse(heightController.text),
        'weight': int.tryParse(weightController.text),
        'healthGoal': selectedHealthGoal,
        'activityLevel': selectedActivityLevel,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('프로필이 업데이트되었습니다.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('프로필 업데이트 중 오류가 발생했습니다.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('프로필'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(widget.uid).get(),
        builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("데이터를 불러오는 중 오류가 발생했습니다."));
          }
          if (!snapshot.hasData) {
            return Center(child: Text("사용자 정보가 없습니다."));
          }
          var userData = snapshot.data!.data() as Map<String, dynamic>;

          // 데이터가 있을 때만 컨트롤러를 초기화하고, 초기값 설정
          nameController.text = userData['name'];
          emailController.text = userData['email'];
          ageController.text = userData['age']?.toString() ?? '';
          heightController.text = userData['height']?.toString() ?? '';
          weightController.text = userData['weight']?.toString() ?? '';
          selectedHealthGoal = userData['healthGoal'] ?? '다이어트';
          selectedActivityLevel = userData['activityLevel'] ?? '비활동적';

          // 사용자 정보를 화면에 표시
          return ListView(
            padding: EdgeInsets.all(20),
            children: [
              Text(
                '이름: ${userData['name']}',
                style: TextStyle(fontSize: 18),
              ),
              Text(
                '이메일: ${userData['email']}',
                style: TextStyle(fontSize: 18),
              ),
              TextField(
                controller: ageController,
                decoration: InputDecoration(labelText: '나이'),
                keyboardType: TextInputType.number,
              ),
              DropdownButton<String>(
                value: selectedHealthGoal,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedHealthGoal = newValue ?? '';
                  });
                },
                items: <String>[
                  '다이어트', '위 건강', '장 건강', '스트레스 해소', '피로 회복', '혈액 순환',
                  '호흡기 건강', '혈당 조절', '노화 방지', '암 예방', '간 건강', '치매 예방',
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              DropdownButton<String>(
                value: selectedActivityLevel,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedActivityLevel = newValue ?? '';
                  });
                },
                items: <String>[
                  '비활동적', '저활동적', '활동적', '매우 활동적'
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              TextField(
                controller: heightController,
                decoration: InputDecoration(labelText: '키'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: weightController,
                decoration: InputDecoration(labelText: '체중'),
                keyboardType: TextInputType.number,
              ),
              // 프로필 업데이트 버튼
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateProfile,
                child: Text('프로필 업데이트'),
              ),
            ],
          );
        },
      ),
    );
  }
}
