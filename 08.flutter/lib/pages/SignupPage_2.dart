import 'package:firebase_auth/firebase_auth.dart';
import 'LoginPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';




class SignupPage_2 extends StatefulWidget {
  final Map<String, dynamic> userInfo;
  const SignupPage_2({Key? key, required this.userInfo}) : super(key: key);

  @override
  _SignupPage_2State createState() => _SignupPage_2State();
}

class _SignupPage_2State extends State<SignupPage_2> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  DateTime _selectedDate = DateTime.now();
  String? _weight;
  String? _height;
  String _selectedGender = '남성';
  String _selectedActivityLevel = '비활동적';
  String _selectedHealthGoal = '다이어트';


  List<String> activityLevels = [
    '비활동적', '저활동적', '활동적', '매우 활동적'
  ];

  List<String> healthGoals = [
    '다이어트', '위 건강', '장 건강', '스트레스 해소', '피로 회복', '혈액 순환',
    '호흡기 건강', '혈당 조절', '노화 방지', '암 예방', '간 건강',
    '치매 예방',
  ];


  // 체중 및 키 입력에 대한 유효성 검사 함수
  String? _validateNumberInput(String? value, {bool allowDecimal = false}) {
    if (value == null || value.isEmpty) {
      return '이 필드는 필수입니다.';
    } else if (allowDecimal ? !RegExp(r'^\d*\.?\d*$').hasMatch(value) : !RegExp(r'^\d+$').hasMatch(value)) {
      return '유효한 숫자를 입력해주세요.';
    }
    return null;
  }

  // 활동 계수를 반환하는 함수
  double getActivityFactor(String activityLevel, String gender) {
    Map<String, double> activityFactorMale = {
      '비활동적': 1.0,
      '저활동적': 1.11,
      '활동적': 1.25,
      '매우 활동적': 1.48,
    };
    Map<String, double> activityFactorFemale = {
      '비활동적': 1.0,
      '저활동적': 1.12,
      '활동적': 1.27,
      '매우 활동적': 1.45,
    };

    return gender == '남성'
        ? activityFactorMale[activityLevel] ?? 1.0
        : activityFactorFemale[activityLevel] ?? 1.0;
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // 여기에 save() 호출을 추가합니다.
      _formKey.currentState!.save();

      // 나이 계산
      int age = DateTime.now().year - _selectedDate.year;
      if (DateTime.now().month < _selectedDate.month ||
          (DateTime.now().month == _selectedDate.month && DateTime.now().day < _selectedDate.day)) {
        age--;
      }

      // BMR 계산
      double weight = double.parse(_weight!);
      double height = double.parse(_height!);
      double bmr = _selectedGender == '남성'
          ? 66.47 + (13.75 * weight) + (5 * height) - (6.76 * age)
          : 655.1 + (9.56 * weight) + (1.85 * height) - (4.68 * age);

      // 활동 계수 계산
      double activityFactor = getActivityFactor(_selectedActivityLevel, _selectedGender);

      // 일일 칼로리 섭취량 계산
      double dailyCalorieIntake = bmr * activityFactor;

      // 사용자 정보에 BMR과 일일 칼로리 섭취량 추가
      final completeUserInfo = {
        ...widget.userInfo,
        'birthDate': _selectedDate,
        'age': age, // 계산된 나이
        'gender': _selectedGender,
        'activityLevel': _selectedActivityLevel,
        'healthGoal': _selectedHealthGoal,
        'weight': weight,
        'height': height,
        'bmr': bmr, // 계산된 BMR
        'dailyCalorieIntake': dailyCalorieIntake, // 계산된 일일 칼로리 섭취량
      };


      double carbRatio, proteinRatio, fatRatio;
      if (_selectedHealthGoal == '다이어트') {
        carbRatio = 0.4; // 탄수화물 비율
        proteinRatio = 0.4; // 단백질 비율
        fatRatio = 0.2; // 지방 비율
      } else {
        carbRatio = 0.5;
        proteinRatio = 0.3;
        fatRatio = 0.2;
      }

      // 일일 칼로리 섭취량을 기반으로 한 탄단지 그램수 계산
      double carbsGrams = (dailyCalorieIntake * carbRatio) / 4;
      double proteinGrams = (dailyCalorieIntake * proteinRatio) / 4;
      double fatGrams = (dailyCalorieIntake * fatRatio) / 9;
      // 두 번째 소수점 자리에서 반올림
      carbsGrams = double.parse(carbsGrams.toStringAsFixed(1));
      proteinGrams = double.parse(proteinGrams.toStringAsFixed(1));
      fatGrams = double.parse(fatGrams.toStringAsFixed(1));

      User? user = FirebaseAuth.instance.currentUser; // 현재 로그인된 사용자의 정보를 가져옵니다.

      if (user != null) {
        try {
          // Firestore에 'user_recom_nutrition' 컬렉션을 생성하고 사용자 정보를 저장합니다.
          await FirebaseFirestore.instance.collection('user_recom_nutrition').doc(user.uid).set({
            'uid': user.uid, // 사용자의 UID
            'bmr': bmr, // BMR 값
            'dailyCalorieIntake': dailyCalorieIntake,
            'carbsGrams': carbsGrams, // 탄수화물 권장 그램수
            'proteinGrams': proteinGrams, // 단백질 권장 그램수
            'fatGrams': fatGrams, // 지방 권장 그램수// 일일 칼로리 섭취량
          },SetOptions(merge: true));

          // user 컬렉션에 사용자 정보 저장 (BMR과 일일 칼로리 섭취량 제외)
          await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
            'uid': user.uid,
            'name' : widget.userInfo['name'],
            'birthDate': _selectedDate,
            'age': age,
            'gender': _selectedGender,
            'activityLevel': _selectedActivityLevel,
            'healthGoal': _selectedHealthGoal,
            'weight': weight,
            'height': height,
          }, SetOptions(merge: true)); // SetOptions(merge: true)를 사용하여 기존 문서에 정보를 병합합니다.


          // 회원가입 완료 다이얼로그를 표시합니다.
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                backgroundColor: Color(0xFFF7F8F8),
                title: Center(
                  child: Text(
                    "회원가입 완료",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                content: Text(
                  "회원가입이 성공적으로 완료되었습니다.",
                  style: TextStyle(color: Colors.black),
                ),
                actions: <Widget>[
                  TextButton(
                    child: Text(
                      "확인",
                      style: TextStyle(color: Colors.black),
                    ),
                    onPressed: () {
                      // 대화상자를 닫고
                      Navigator.of(context).pop();
                      // 로그인 페이지로 이동합니다.
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
                    },
                  ),
                ],
              );
            },
          );
        } catch (e) {
          // 에러 발생 시 처리
          print("Error adding user: $e");
          // 에러 메시지를 표시하거나 다른 작업을 수행할 수 있습니다.
        }
      }
    }
  }





  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData().copyWith(
        scaffoldBackgroundColor: const Color.fromARGB(255, 255, 255, 255),
      ),
      home: Scaffold(

        body: Form(
          key: _formKey,
          child: ListView(
              padding: EdgeInsets.all(20),
              children: [
                Group(),
                BirthdatePicker(
                  selectedDate: _selectedDate,
                  onDateChanged: (newDate) {
                    setState(() {
                      _selectedDate = newDate;
                    });
                  },
                ),
                SizedBox(height: 20), // 간격 추가
                GenderDropdown(
                  selectedGender: _selectedGender,
                  onChanged: (value) => setState(() => _selectedGender = value!),
                ),
                SizedBox(height: 20), // 간격 추가
                ActivityLevelDropdown(
                  selectedActivityLevel: _selectedActivityLevel,
                  onChanged: (newValue) {
                    setState(() {
                      _selectedActivityLevel = newValue!;
                    });
                  },
                ),
                SizedBox(height: 20), // 간격 추가
                HealthDropdown(
                  selectedHealth: _selectedHealthGoal,
                  onChanged: (value) => setState(() => _selectedHealthGoal = value!),
                ),
                SizedBox(height: 20),
                Weight(
                validateNumberInput: _validateNumberInput, // 함수 전달
                  onSaved: (value) => _weight = value,), // onSaved 콜백 전달),
                SizedBox(height: 20), // 간격 추가
                PersonHeight(
                validateNumberInput: _validateNumberInput, // 함수 전달
                onSaved: (value) => _height = value,), // onSaved 콜백 전달),
                SizedBox(height: 30), // 간격 추가
                ButtonLogin(onSubmit: _submitForm),
          ]
                ),
        ),
    )
    );
  }
}



class Group extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Transform.translate(
          offset: Offset(0, -66), // y축으로 -66만큼 이동
          child: Container(
            width: 300,
            height: 300,
            child: Image.asset(
              'assets/images/Group.png', // 이미지 경로
              width: 329,
              height: 367,
              fit: BoxFit.fill, // 이미지를 부모 위젯 크기에 맞게 채우도록 설정
            ),
          ),
        ),
      ],
    );
  }
}

class BirthdatePicker extends StatelessWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateChanged;

  const BirthdatePicker({
    Key? key,
    required this.selectedDate,
    required this.onDateChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showDatePicker(context),
      child: Padding( // 여백 추가
        padding: const EdgeInsets.fromLTRB(27.0,0,27.0,0),
        child: Container(
          // width 속성을 제거하거나 조정합니다.
          height: 60,
          padding: EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Color(0xFFF7F8F8),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(Icons.calendar_today, color: Color(0xFFACA3A5)),
              Text(
                "생년월일: ${selectedDate.toLocal().toString().split(' ')[0]}",
                style: TextStyle(fontSize: 16, color: Color(0xFFACA3A5)),
              ),
              Icon(Icons.arrow_drop_down, color: Color(0xFFACA3A5)),
            ],
          ),
        ),
      ),
    );
  }


  void _showDatePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext builder) {
        return Container(
          height: MediaQuery.of(context).copyWith().size.height / 3,
          child: CupertinoDatePicker(
            initialDateTime: selectedDate,
            onDateTimeChanged: onDateChanged,
            maximumDate: DateTime.now(),
            minimumYear: 1900,
            maximumYear: DateTime.now().year,
            mode: CupertinoDatePickerMode.date,
          ),
        );
      },
    );
  }
}


class GenderDropdown extends StatefulWidget {
  final String selectedGender;
  final Function(String?) onChanged;
  final bool showError;
  const GenderDropdown({
    Key? key,
    required this.selectedGender,
    required this.onChanged,
    this.showError = false,
  }) : super(key: key);

  @override
  _GenderDropdownState createState() => _GenderDropdownState();
}
class _GenderDropdownState extends State<GenderDropdown> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 315,
        height: 70,
        child: DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: '성별',

            labelStyle: TextStyle(color: Color(0xFFACA3A5), fontSize: 16),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
            fillColor: Color(0xFFF7F8F8),
            filled: true,
            prefixIcon: Icon(Icons.person, color: Color(0xFFACA3A5)),
          ),
          value: widget.selectedGender,
          items: ['남성', '여성'].map((gender) => DropdownMenuItem(child: Text(gender, style: TextStyle(
            fontSize: 16, color: Color(0xFFACA3A5)
          ),), value: gender)).toList(),
          onChanged: widget.onChanged,
        ),

      ),

    );
  }
}

class ActivityLevelDropdown extends StatefulWidget {
  final String selectedActivityLevel;
  final Function(String?) onChanged;

  const ActivityLevelDropdown({
    Key? key,
    required this.selectedActivityLevel,
    required this.onChanged,
  }) : super(key: key);

  @override
  _ActivityLevelDropdownState createState() => _ActivityLevelDropdownState();
}
class _ActivityLevelDropdownState extends State<ActivityLevelDropdown> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 315,
        height: 60,
        child: DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: '활동량',
            labelStyle: TextStyle(color: Color(0xFFACA3A5), fontSize: 16),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
            fillColor: Color(0xFFF7F8F8),
            filled: true,
            prefixIcon: Icon(Icons.directions_run, color: Color(0xFFACA3A5)),
          ),
          value: widget.selectedActivityLevel,
          items: ['비활동적', '저활동적', '활동적', '매우 활동적'].map((level) => DropdownMenuItem(child: Text(level
            ,style: TextStyle(
                fontSize: 16, color: Color(0xFFACA3A5)
            ),), value: level)).toList(),
          onChanged: widget.onChanged,
        ),
      ),
    );
  }
}


class HealthDropdown extends StatefulWidget {
  final String selectedHealth;
  final Function(String?) onChanged;
  const HealthDropdown
      ({Key? key, required this.selectedHealth, required this.onChanged}) : super(key: key);
  @override
  _HealthDropdownState createState() => _HealthDropdownState();
}
class _HealthDropdownState extends State<HealthDropdown> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 315,
        height: 60,
        child: DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: '건강 목적', // 항상 보이는 라벨
            labelStyle: TextStyle(
              color: Color(0xFFACA3A5),
              fontSize: 16// 라벨 색상
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            fillColor: Color(0xFFF7F8F8), // 배경색
            filled: true,
              prefixIcon: Icon(Icons.favorite,color: Color(0xFFACA3A5),)
          ),
          value: widget.selectedHealth,
          items: ['다이어트', '위 건강', '장 건강', '스트레스 해소', '피로 회복', '혈액 순환',
            '호흡기 건강', '혈당 조절', '노화 방지', '암 예방', '간 건강',
            '치매 예방',]
              .map((gender) => DropdownMenuItem(child: Text(gender, style: TextStyle(
              fontSize: 16
              , color: Color(0xFFACA3A5)
          ),), value: gender)).toList(),
          onChanged: widget.onChanged,
          // hint를 제거하고 labelText만 사용
        ),
      ),
    );
  }
}

// class HealingDropdown extends StatefulWidget {
//   final String selectedHealing;
//   final Function(String?) onChanged;
//
//   const HealingDropdown({Key? key, required this.selectedHealing, required this.onChanged}) : super(key: key);
//
//   @override
//   _HealingDropdownState createState() => _HealingDropdownState();
// }
//
// class _HealingDropdownState extends State<HealingDropdown> {
//   @override
//   Widget build(BuildContext context) {
//     // _selectedHealing 변수를 제거하고, widget.selectedHealing을 직접 사용합니다.
//     return Center(
//       child: SizedBox(
//         width: 315,
//         height: 60,
//         child: DropdownButtonFormField<String>(
//           decoration: InputDecoration(
//             labelText: '보유 질병', // 항상 보이는 라벨
//             labelStyle: TextStyle(
//               color: Color(0xFFACA3A5),
//               fontSize: 12, // 라벨 색상
//             ),
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(14),
//               borderSide: BorderSide.none,
//             ),
//             fillColor: Color(0xFFF7F8F8), // 배경색
//             filled: true,
//             prefixIcon: Icon(Icons.healing, color: Color(0xFFACA3A5)),
//           ),
//           value: widget.selectedHealing, // 상태 변수 대신 위젯 프로퍼티 사용
//           items: ['당뇨병', '고혈압', '심장 질환', '관절염', '기타']
//               .map((disease) => DropdownMenuItem(
//             child: Text(
//               disease,
//               style: TextStyle(fontSize: 12, color: Color(0xFFACA3A5)),
//             ),
//             value: disease,
//           ))
//               .toList(),
//           onChanged: (value) => widget.onChanged(value), // 변경 사항을 부모 위젯으로 전달
//         ),
//       ),
//     );
//   }
// }


class Weight extends StatelessWidget {

  final String? Function(String? value, {bool allowDecimal}) validateNumberInput;
  final Function(String?) onSaved;

  const Weight({Key? key, required this.validateNumberInput, required this.onSaved}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 315,
          height: 48,
          child: Stack(
            children: [
              Positioned(
                left: 0,
                top: 0,
                child: Container(
                  width: 252,
                  height: 48,
                  decoration: ShapeDecoration(
                    color: Color(0xFFF7F8F8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 15,
                top: 15,
                child: Container(
                  width: 18,
                  height: 18,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(),
                  child: SvgPicture.asset(
                    'assets/weight.svg', // SVG 이미지 로드
                    color : Color(0xFFACA3A5),
                  ),
                ),
              ),
              // TextFormField을 사용하여 체중 입력
              Positioned(
                left: 50,
                top: 0,
                child: Container(
                  width: 200, // 폭 조정
                  child: TextFormField(
                    decoration: InputDecoration(
                      border: InputBorder.none, // 테두리 없앰
                      hintText: '체중', // 힌트 텍스트
                      hintStyle: TextStyle(
                        color: Color(0xFFACA3A5),
                        fontSize: 16,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    validator: (value) => validateNumberInput(value, allowDecimal: true),
                    onSaved: onSaved,
                  ),
                ),
              ),
              Positioned(
                left: 267,
                top: 0,
                child: Container(
                  width: 48,
                  height: 48,
                  child: Stack(
                    children: [
                      Positioned(
                        left: 0,
                        top: 0,
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: ShapeDecoration(
                            color: Color(0xFF129575),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 16,
                        top: 15,
                        child: Text(
                          'kg',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class PersonHeight extends StatelessWidget {

  final String? Function(String? value, {bool allowDecimal}) validateNumberInput;
  final Function(String?) onSaved;

  const PersonHeight({Key? key, required this.validateNumberInput, required this.onSaved}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 315,
          height: 48,
          child: Stack(
            children: [
              Positioned(
                left: 0,
                top: 0,
                child: Container(
                  width: 252,
                  height: 48,
                  decoration: ShapeDecoration(
                    color: Color(0xFFF7F8F8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 15,
                top: 15,
                child: Container(
                  width: 18,
                  height: 18,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(),
                  child: SvgPicture.asset(
                    'assets/ruler.svg', // SVG 이미지 로드
                    color: Color(0xFFACA3A5),
                  ),
                ),
              ),
              // TextFormField를 사용하여 키 입력
              Positioned(
                left: 50,
                top: 0, // 위치 조정
                child: Container(
                  width: 200, // 폭 조정
                  child: TextFormField(
                    decoration: InputDecoration(
                      border: InputBorder.none, // 테두리 없앰
                      hintText: '키', // 힌트 텍스트
                      hintStyle: TextStyle(
                        color: Color(0xFFACA3A5),
                        fontSize: 16,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) => validateNumberInput(value),
                    onSaved: onSaved,
                  ),
                ),
              ),
              Positioned(
                left: 267,
                top: 0,
                child: Container(
                  width: 48,
                  height: 48,
                  child: Stack(
                    children: [
                      Positioned(
                        left: 0,
                        top: 0,
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: ShapeDecoration(
                            color: Color(0xFF129575),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 16,
                        top: 15,
                        child: Text(
                          'cm',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ButtonLogin extends StatelessWidget {
  final Function() onSubmit;

  const ButtonLogin({Key? key, required this.onSubmit}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 315,
      height: 60,
      child: ElevatedButton(
        onPressed: onSubmit, // 부모 위젯에서 전달받은 함수를 버튼 클릭 시 호출
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF129575), // 버튼 배경색 설정
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(99), // 버튼 모서리 둥글게
          ),
          padding: EdgeInsets.all(0), // ElevatedButton 내부 패딩을 0으로 설정
          // Container의 padding을 사용하여 버튼 크기를 조정합니다.
        ),
        child: Ink(
          decoration: BoxDecoration(
            color: Color(0xFF129575), // Ink의 배경색 설정
            borderRadius: BorderRadius.circular(99),
          ),
          child: Container(
            alignment: Alignment.center,
            child: Text(
              '회원가입 완료!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

