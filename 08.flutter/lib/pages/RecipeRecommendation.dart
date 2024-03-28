import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';


String? userId = FirebaseAuth.instance.currentUser?.uid;
final databaseRef = FirebaseDatabase.instance.ref();

class RecipeSearchPage extends StatefulWidget {
  @override
  _RecipeSearchPageState createState() => _RecipeSearchPageState();
}

class _RecipeSearchPageState extends State<RecipeSearchPage> {
  final TextEditingController healthGoalController = TextEditingController();
  final TextEditingController ingredientsController = TextEditingController();
  List<dynamic> _recipes = [];
  String _errorMessage = '';

  FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  Future<void> _searchRecipe() async {
    final String healthGoal = healthGoalController.text;
    final List<String> ingredients = ingredientsController.text.split(',').map((s) => s.trim()).toList();

    final response = await http.post(
      Uri.parse('http://54.167.68.237/recipes/'),
      headers: {"Content-Type": "application/json; charset=utf-8"},
      body: jsonEncode({
        "health_goal": healthGoal,
        "ingredients": ingredients,
      }),
    );

    if (response.statusCode == 200) {
      final decodedBody = utf8.decode(response.bodyBytes);
      final data = json.decode(decodedBody);
      if (data['data'] != null && data['data']['Get'] != null && data['data']['Get']['Recipe'] != null) {
        setState(() {
          _recipes = List.from(data['data']['Get']['Recipe']);
          _errorMessage = '';
        });
      } else {
        setState(() {
          _recipes = [];
          _errorMessage = '올바른 데이터를 받지 못했습니다.';
        });
      }
    } else {
      setState(() {
        _recipes = [];
        _errorMessage = '레시피를 찾을 수 없습니다.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('레시피 검색'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: healthGoalController,
                decoration: InputDecoration(
                  labelText: '건강 목적',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: ingredientsController,
                decoration: InputDecoration(
                  labelText: '재료 (쉼표로 구분)',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: _searchRecipe,
              child: Text(
                '검색',
                style: TextStyle(
                  color: Colors.white, // 글씨 색상을 하얀색으로 설정
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF129575), // 버튼의 배경색을 초록색으로 설정
              ),
            ),
            _errorMessage.isNotEmpty
                ? Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _errorMessage,
                style: TextStyle(color: Colors.red),
              ),
            )
                : Container(),
            _buildGridView(),
          ],
        ),
      ),
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
      ),
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: _recipes.length,
      itemBuilder: (context, index) {
        final recipe = _recipes[index];
        return InkWell(
          onTap: () async {

            // 현재 사용자 ID 가져오기
            String? userId = FirebaseAuth.instance.currentUser?.uid;
            // 현재 시간을 타임스탬프로 변환
            int timestamp = DateTime.now().millisecondsSinceEpoch;

            // Analytics에 이벤트 저장
            await analytics.logEvent(
              name: 'recipe_box_clicked',
              parameters: {
                'user_id': userId,
                'recipe_name': recipe['recipe_name'], // 레시피 이름 로깅
              },
            );

            // Realtime Database에 이벤트 기록
            databaseRef.child('user_clicks').push().set({
              'user_id': userId,
              'recipe_name': recipe['recipe_name'],
              'timestamp': timestamp,
            }).then((_) {
              print("Event recorded in Realtime Database");
            }).catchError((error) {
              print("Failed to record event: $error");
            });

            print("Event logged: recipe_box_clicked, Recipe Name: ${recipe['recipe_name']}");

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RecipeDetailPage(recipe: recipe),
              ),
            );
          },
          child: Card(
            child: Column(
              children: [
                Expanded(
                  child: Image.network(
                    recipe['image_link'],
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    recipe['recipe_name'],
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class RecipeDetailPage extends StatelessWidget {
  final Map<String, dynamic> recipe;

  RecipeDetailPage({Key? key, required this.recipe}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    final String imageUrl = recipe['image_link'] ?? recipe['recipe_image_link'];

    return Scaffold(
      appBar: AppBar(
        title: Text(recipe['recipe_name']),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Image.network(
              imageUrl,
              fit: BoxFit.cover,
              height: 250.0,
              width: double.infinity,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("카테고리: ${recipe['category']}", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("요약: ${recipe['summary']}", style: TextStyle(fontSize: 16)),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("재료:\n${recipe['ingredient_name']}", style: TextStyle(fontSize: 16)),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("요리 순서:\n${recipe['full_step']}", style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
