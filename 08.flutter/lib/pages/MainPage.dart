
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:seniorproject/pages/LoginPage.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'ProfilePage.dart';
import 'NutritionDetailPage.dart';
import 'lib/util/AddDietLogPage.dart';
import 'RecipeRecommendation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';



class MainPage extends StatefulWidget {
  final String uid;

  MainPage({required this.uid});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  // 선택된 인덱스에 따라 보여줄 위젯을 결정하는 함수
  List<Widget> get _widgetOptions => <Widget>[
    HomePage(uid: widget.uid),
    Text('Shop Page', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
    NutritionDetailPage(uid: widget.uid),
    RecipeSearchPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex), // 인덱스에 따라 위젯을 동적으로 반환
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home, size: 40),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart, size: 40),
            label: '쇼핑',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart, size: 40),
            label: '영양정보',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book, size: 40),
            label: '레시피',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Color(0xFF129575),
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}


// 홈화면
class HomePage extends StatelessWidget {
  final String uid;

  HomePage({Key? key, required this.uid}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(55), // AppBar의 높이를 15로 지정
        child: AppBar(
          leading: Padding(
            padding: const EdgeInsets.all(8.0), // 여백 설정
            child: Container(
              width: 32,
              height: 32,
              decoration: ShapeDecoration(
                color: Color(0xFFF7F8F8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Center(
                child: IconButton(
                  icon: Icon(Icons.arrow_back_ios, color: Colors.black),
                  iconSize: 16, // 왼쪽 화살표 아이콘
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage())
                    );
                  },
                ),
              ),
            ),
          ),
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: IconButton(
                icon: Icon(Icons.account_circle, color: Colors.grey),
                iconSize: 40,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProfilePage(uid: uid,)),
                  );
                },
              ),
            ),
          ],
          titleSpacing: 0, // 타이틀과 leading 사이의 여백을 제거합니다.
          title: GestureDetector(
            onTap: () {
              // 타이틀을 클릭하면 현재 페이지를 새로 고침
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomePage(uid: uid)),
              );
            },
            child: Text(
              '요레할래',
              style: TextStyle(
                color: Colors.black, // 타이틀 텍스트 색상
                fontSize: 24,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          centerTitle: true, // 타이틀을 가운데로 정렬
          backgroundColor: Colors.white, // AppBar 배경색
        ),
      ),
      backgroundColor: Colors.white,
      body: ListView(
        children: [
          SizedBox(height: 30),
          Search(),
          SizedBox(height: 20),
          Progress(uid: uid,),
          SizedBox(height: 20),
          InputBreakfast(uid: uid,),
          SizedBox(height: 20),
          InputLunch(uid: uid,),
          SizedBox(height: 20),
          InputDinner(uid: uid,),
          SizedBox(height: 30),
          Recipe(),
          SizedBox(height: 30),
          ChatBot(),
          SizedBox(height: 30),
        ],
      ),
      // 본문 내용 추가 가능
    );
  }
}


class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  final TextEditingController _searchController = TextEditingController();

  void _onSearch() {
    final String searchQuery = _searchController.text;
    print('검색어: $searchQuery');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 304,
          height: 40,
          decoration: ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              side: BorderSide(width: 1.30, color: Color(0xFFD9D9D9)),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Row(
            children: [
              IconButton(
                icon: Icon(Icons.search),
                onPressed: _onSearch, // 검색 아이콘 버튼이 눌렸을 때의 동작
              ),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: '통합 검색',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.only(left: 10.0),
                  ),
                  onSubmitted: (value) => _onSearch(), // 키보드에서 "엔터"를 눌렀을 때의 동작
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}




class Progress extends StatefulWidget {
  final String uid;

  Progress({required this.uid});

  @override
  _ProgressState createState() => _ProgressState();
}

class _ProgressState extends State<Progress> {
  late Future<Map<String, dynamic>> _nutritionFuture;
  late Future<Map<String, double>> _dietLogFuture;

  @override
  void initState() {
    super.initState();
    _nutritionFuture = fetchNutritionData();
    _dietLogFuture = fetchDietLogData();
  }

  Future<Map<String, dynamic>> fetchNutritionData() async {
    var doc = await FirebaseFirestore.instance.collection(
        'user_recom_nutrition').doc(widget.uid).get();
    return doc.data()!;
  }


  Future<Map<String, double>> fetchDietLogData() async {
    double totalCalories = 0;
    double totalCarbs = 0;
    double totalProtein = 0;
    double totalFats = 0;

    var today = DateTime.now().toString().split(' ')[0];
    var querySnapshot = await FirebaseFirestore.instance
        .collection('diet_log')
        .where('uid', isEqualTo: widget.uid)
        .where('date', isEqualTo: today)
        .get();

    for (var doc in querySnapshot.docs) {
      var data = doc.data();
      totalCalories += (data['calories'] as num? ?? 0).toDouble();
      totalCarbs += (data['carbs'] as num? ?? 0).toDouble();
      totalProtein += (data['protein'] as num? ?? 0).toDouble();
      totalFats += (data['fats'] as num? ?? 0).toDouble();
    }

    return {
      'calories': totalCalories,
      'carbs': totalCarbs,
      'protein': totalProtein,
      'fats': totalFats,
    };
  }


  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.wait([_nutritionFuture, _dietLogFuture]),
      builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text("Data is not available"));
        }

        var nutritionData = snapshot.data![0];
        var dietLogData = snapshot.data![1];

        // 전체 박스를 Container로 묶어서 설정
        return SingleChildScrollView( // 스크롤 가능하게 만듬
          child: Container(

            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SfRadialGauge(
                  axes: <RadialAxis>[
                    RadialAxis(
                      minimum: 0,
                      maximum: nutritionData['dailyCalorieIntake'],
                      ranges: [
                        GaugeRange(
                          startValue: 0,
                          endValue: nutritionData['dailyCalorieIntake'],
                          color: Colors.grey.withOpacity(0.5),
                        ),
                      ],
                      pointers: <GaugePointer>[
                        RangePointer(
                          value: dietLogData['calories'],
                          color: Colors.blue,
                          width: 10,
                        )
                      ],
                      annotations: <GaugeAnnotation>[
                        GaugeAnnotation(
                          widget: Text('${dietLogData['calories'].toInt()} / ${nutritionData['dailyCalorieIntake'].toInt()} kcal'),
                          angle: 90,
                          positionFactor: 0.5,
                        )
                      ],
                    ),
                  ],
                ),
                // 탄단지 정보를 담은 게이지들
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      width: 100,
                      child: buildNutritionGauge('탄수화물', dietLogData['carbs'], nutritionData['carbsGrams'], Colors.green),
                    ),
                    Container(
                      width: 100,
                      child: buildNutritionGauge('단백질', dietLogData['protein'], nutritionData['proteinGrams'], Colors.red),
                    ),
                    Container(
                      width: 100,
                      child: buildNutritionGauge('지방', dietLogData['fats'], nutritionData['fatGrams'], Colors.orange),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  Widget buildNutritionGauge(String label, double currentValue,
      double totalValue, Color color) {
    String displayValue = currentValue.toStringAsFixed(1);
    String displayTotal = totalValue.toStringAsFixed(1);

    return Column(
      mainAxisSize: MainAxisSize.min, // Column의 크기를 내용물에 맞춥니다.
      children: [
        SfRadialGauge(
          axes: <RadialAxis>[
            RadialAxis(
              minimum: 0,
              maximum: totalValue,
              ranges: [
                GaugeRange(
                  startValue: 0,
                  endValue: totalValue,
                  color: Colors.grey.withOpacity(0.5),
                ),
              ],
              pointers: <GaugePointer>[
                RangePointer(
                  value: currentValue,
                  color: color,
                  width: 10,
                )
              ],
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 4.0), // 간격을 조절합니다.
          child: Text(
            '$label: $displayValue / $displayTotal',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}

class ChartData {
  ChartData(this.label, this.actualValue, this.totalValue, this.color);

  final String label;
  final double actualValue;
  final double totalValue;
  final Color color;

}









class InputBreakfast extends StatefulWidget {
  final String uid;

  InputBreakfast({required this.uid});

  @override
  _InputBreakfastState createState() => _InputBreakfastState();
}

class _InputBreakfastState extends State<InputBreakfast> {
  int _calories = 0; // 초기 칼로리 값을 0으로 설정

  @override
  void initState() {
    super.initState();
    fetchBreakfastCalories();
  }

  fetchBreakfastCalories() async {
    String today = DateTime.now().toString().split(' ')[0];
    FirebaseFirestore.instance
        .collection('diet_log')
        .where('uid', isEqualTo: widget.uid)
        .where('date', isEqualTo: today)
        .where('time', isEqualTo: "아침")
        .get()
        .then((snapshot) {
      double totalCalories = 0;
      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        // calories 값을 num으로 받아서 toDouble로 안전하게 변환
        double calories = (data['calories'] as num?)?.toDouble() ?? 0.0;
        totalCalories += calories;
      }
      setState(() {
        _calories = totalCalories.toInt(); // double에서 int로 변환
      });
    }).catchError((error) {
      print("Error fetching breakfast calories: $error");
    });
  }


  @override
  Widget build(BuildContext context) {

    return Column(
      children: [
        Container(
          width: 357,
          height: 100,
          child: Stack(
            children: [
              Positioned(
                left: 6,
                top: 0,
                child: SizedBox(
                  width: 30,
                  height: 17.39,
                  child: Text(
                    '아침',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 13,
                      fontFamily: 'Quicksand',
                      fontWeight: FontWeight.w700,
                      height: 0.08,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                top: 26.09,
                child: Container(
                  width: 357,
                  height: 73.91,
                  child: Stack(
                    children: [
                      Positioned(
                        left: 0,
                        top: 0,
                        child: Container(
                          width: 357,
                          height: 73.91,
                          decoration: ShapeDecoration(
                            color: Color(0xFF129575),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 10,
                        top: 0,
                        child: SizedBox(
                          width: 200,
                          height: 73.91,
                          child: Align(
                            alignment: Alignment.center,
                            child: Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: '$_calories Kcal ',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 36,
                                      fontFamily: 'Quicksand',
                                      fontWeight: FontWeight.w700,
                                      height: 0.02,
                                    ),
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 291.29,
                        top: 20,
                        child: Container(
                          width: 46.94,
                          height: 73.91,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddDietLogPage(uid: widget.uid, time: "아침"), // uid 전달
                                ),
                              );
                            },
                          child: Stack(
                            children: [
                              Positioned(
                                left: 0,
                                top: 0,
                                child: Container(
                                  width: 46.94,
                                  height: 41.62,
                                  decoration: ShapeDecoration(
                                    color: Color(0xFF129575),
                                    shape: OvalBorder(),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 12.75,
                                top: 15.15,
                                child: Text(
                                  '+',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 40,
                                    fontFamily: 'Quicksand',
                                    fontWeight: FontWeight.w500,
                                    height: 0.01,
                                  ),
                                ),
                              ),
                            ],
                          ),
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

class InputLunch extends StatefulWidget {
  final String uid;

  InputLunch({required this.uid});

  @override
  _InputLunchState createState() => _InputLunchState();
}

class _InputLunchState extends State<InputLunch> {
  int _calories = 0; // 초기 칼로리 값을 0으로 설정

  @override
  void initState() {
    super.initState();
    fetchLunchCalories();
  }

  fetchLunchCalories() async {
    String today = DateTime.now().toString().split(' ')[0]; // "YYYY-MM-DD" 형식
    FirebaseFirestore.instance
        .collection('diet_log')
        .where('uid', isEqualTo: widget.uid)
        .where('date', isEqualTo: today)
        .where('time', isEqualTo: "점심")
        .get()
        .then((snapshot) {
      double totalCalories = 0;
      snapshot.docs.forEach((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        double calories = data['calories'] as double? ?? 0; // double 타입으로 취급
        totalCalories += calories; // double 타입의 값을 더함
      });
      setState(() {
        _calories = totalCalories.toInt(); // 최종 값을 int로 변환하여 상태 업데이트
      });
    });
  }


  @override
  Widget build(BuildContext context) {

    return Column(
      children: [
        Container(
          width: 357,
          height: 100,
          child: Stack(
            children: [
              Positioned(
                left: 6,
                top: 0,
                child: SizedBox(
                  width: 30,
                  height: 17.39,
                  child: Text(
                    '점심',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 13,
                      fontFamily: 'Quicksand',
                      fontWeight: FontWeight.w700,
                      height: 0.08,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                top: 26.09,
                child: Container(
                  width: 357,
                  height: 73.91,
                  child: Stack(
                    children: [
                      Positioned(
                        left: 0,
                        top: 0,
                        child: Container(
                          width: 357,
                          height: 73.91,
                          decoration: ShapeDecoration(
                            color: Color(0xFF129575),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 10,
                        top: 0,
                        child: SizedBox(
                          width: 200,
                          height: 73.91,
                          child: Align(
                            alignment: Alignment.center,
                            child: Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: '$_calories Kcal ',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 36,
                                      fontFamily: 'Quicksand',
                                      fontWeight: FontWeight.w700,
                                      height: 0.02,
                                    ),
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 291.29,
                        top: 20,
                        child: Container(
                          width: 46.94,
                          height: 73.91,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddDietLogPage(uid: widget.uid, time: "점심"), // uid 전달
                                ),
                              );
                            },
                            child: Stack(
                              children: [
                                Positioned(
                                  left: 0,
                                  top: 0,
                                  child: Container(
                                    width: 46.94,
                                    height: 41.62,
                                    decoration: ShapeDecoration(
                                      color: Color(0xFF129575),
                                      shape: OvalBorder(),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: 12.75,
                                  top: 15.15,
                                  child: Text(
                                    '+',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 40,
                                      fontFamily: 'Quicksand',
                                      fontWeight: FontWeight.w500,
                                      height: 0.01,
                                    ),
                                  ),
                                ),
                              ],
                            ),
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

class InputDinner extends StatefulWidget {
  final String uid;

  InputDinner({required this.uid});

  @override
  _InputDinner createState() => _InputDinner();
}

class _InputDinner extends State<InputDinner> {
  int _calories = 0; // 초기 칼로리 값을 0으로 설정

  @override
  void initState() {
    super.initState();
    fetchDinnerCalories();
  }

  fetchDinnerCalories() async {
    String today = DateTime.now().toString().split(' ')[0];
    FirebaseFirestore.instance
        .collection('diet_log')
        .where('uid', isEqualTo: widget.uid)
        .where('date', isEqualTo: today)
        .where('time', isEqualTo: "저녁")
        .get()
        .then((snapshot) {
      double totalCalories = 0;
      snapshot.docs.forEach((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        double calories = data['calories'] as double? ?? 0; // double 타입으로 취급
        totalCalories += calories; // double 타입의 값을 더함
      });
      setState(() {
        _calories = totalCalories.toInt(); // 최종 값을 int로 변환하여 상태 업데이트
      });
    });
  }

  @override
  Widget build(BuildContext context) {

    return Column(
      children: [
        Container(
          width: 357,
          height: 100,
          child: Stack(
            children: [
              Positioned(
                left: 6,
                top: 0,
                child: SizedBox(
                  width: 30,
                  height: 17.39,
                  child: Text(
                    '저녁',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 13,
                      fontFamily: 'Quicksand',
                      fontWeight: FontWeight.w700,
                      height: 0.08,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                top: 26.09,
                child: Container(
                  width: 357,
                  height: 73.91,
                  child: Stack(
                    children: [
                      Positioned(
                        left: 0,
                        top: 0,
                        child: Container(
                          width: 357,
                          height: 73.91,
                          decoration: ShapeDecoration(
                            color: Color(0xFF129575),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 10,
                        top: 0,
                        child: SizedBox(
                          width: 200,
                          height: 73.91,
                          child: Align(
                            alignment: Alignment.center,
                            child: Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: '$_calories Kcal ',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 36,
                                      fontFamily: 'Quicksand',
                                      fontWeight: FontWeight.w700,
                                      height: 0.02,
                                    ),
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 291.29,
                        top: 20,
                        child: Container(
                          width: 46.94,
                          height: 73.91,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddDietLogPage(uid: widget.uid, time: "저녁"), // uid 전달
                                ),
                              );
                            },
                            child: Stack(
                              children: [
                                Positioned(
                                  left: 0,
                                  top: 0,
                                  child: Container(
                                    width: 46.94,
                                    height: 41.62,
                                    decoration: ShapeDecoration(
                                      color: Color(0xFF129575),
                                      shape: OvalBorder(),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: 12.75,
                                  top: 15.15,
                                  child: Text(
                                    '+',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 40,
                                      fontFamily: 'Quicksand',
                                      fontWeight: FontWeight.w500,
                                      height: 0.01,
                                    ),
                                  ),
                                ),
                              ],
                            ),
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



// fastapi를 통해 레시피 데이터를 가져오는 함수
Future<List<dynamic>> fetchRecipesFromFastAPI() async {
  try {
    final response = await http.get(
      Uri.parse('http://54.167.68.237/recommendations/most_clicked'),
      headers: {"Content-Type": "application/json; charset=utf-8"},
    );

    if (response.statusCode == 200) {
      final String decodedBody = utf8.decode(response.bodyBytes);
      final data = json.decode(decodedBody);
      return data['recommendations'];
    } else {
      // 첫 번째 API 호출이 실패한 경우, 무작위 레시피를 가져오는 함수를 호출
      return await fetchRandomRecipes();
    }
  } catch (e) {
    // 네트워크 에러나 다른 예외 발생 시, 무작위 레시피를 가져오는 함수를 호출
    return await fetchRandomRecipes();
  }
}


// 무작위 레시피 데이터를 가져오는 함수
Future<List<dynamic>> fetchRandomRecipes() async {
  final response = await http.post(
    Uri.parse('http://54.167.68.237/random_recipes/'),
    headers: {"Content-Type": "application/json; charset=utf-8"},
  );

  if (response.statusCode == 200) {
    final String decodedBody = utf8.decode(response.bodyBytes);
    return json.decode(decodedBody);
  } else {
    throw Exception('Failed to load recipes');
  }
}

class Recipe extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: fetchRecipesFromFastAPI(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          // FastAPI로부터 레시피를 가져오는 데 실패한 경우
          // 무작위 레시피 데이터를 가져옴
          return Center(child: Text("${snapshot.error}"));
        } else {
          return buildRecipesList(snapshot.data, context);
        }
      },
    );
  }

  // 레시피 리스트를 빌드하는 위젯
  Widget buildRecipesList(List<dynamic>? recipes, BuildContext context) {
    if (recipes == null || recipes.isEmpty) {
      return Center(
        child: Text(
          '레시피를 불러올 수 없습니다.',
          style: TextStyle(fontSize: 16.0),
        ),
      );
    } else {
      return Column(
        children: [
          Container(
            width: 380,
            height: 230,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Positioned(
                  left: 3,
                  top: 0,
                  child: Text(
                    '개인 건강 목적 별 추천 레시피',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20.20,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w700,
                      height: 0,
                    ),
                  ),
                ),
                Positioned(
                  left: 3,
                  top: 31,
                  child: Text(
                    '이 레시피 어때요?',
                    style: TextStyle(
                      color: Color(0xFFACA3A5),
                      fontSize: 12,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w700,
                      height: 0,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: recipes.length,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      final recipe = recipes[index];
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  RecipeDetailPage(recipe: recipe),
                            ),
                          );
                        },
                        child: Container(
                          width: 150,
                          margin: EdgeInsets.only(right: 20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            image: DecorationImage(
                              image: NetworkImage(recipe['recipe_image_link']),
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: Stack(
                            children: [
                              Positioned(
                                bottom: 10,
                                left: 10,
                                child: Text(
                                  recipe['recipe_name'],
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }
  }
}


  class ChatBot extends StatelessWidget {

  void _launchURL(BuildContext context) async {
    const url = 'https://420f80063eda2c03cb.gradio.live/';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      // URL을 열 수 없을 경우, 에러 메시지를 표시
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch $url')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => _launchURL(context),
          child: Container(
            width: 346,
            height: 211,
            child: Stack(
              children: [
                Positioned(
                  left: 3,
                  top: 31,
                  child: Text(
                    '식건강 AI 도우미',
                    style: TextStyle(
                      color: Color(0xFFACA3A5),
                      fontSize: 12,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w700,
                      height: 0,
                    ),
                  ),
                ),
                Positioned(
                  left: 3,
                  top: 0,
                  child: Text(
                    '무엇이든지 물어보세요!',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20.20,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w700,
                      height: 0,
                    ),
                  ),
                ),
                Positioned(
                  left: 5,
                  top: 56,
                  child: Container(
                    width: 341,
                    height: 155,
                    decoration: ShapeDecoration(
                      color: Color(0xFF129575),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 20,
                  top: 61,
                  child: Container(
                    width: 150,
                    height: 150,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/Avatar_Thinking_4.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 30,
                  top: 90,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '영양관련\n건강상담',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w700,
                          height: 0,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}




// 샵 페이지


// 통계 페이지

// 레시피 페이지

