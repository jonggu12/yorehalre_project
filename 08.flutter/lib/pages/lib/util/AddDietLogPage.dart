// AddDietLogPage.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter_vision/flutter_vision.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddDietLogPage extends StatefulWidget {
  final String uid;
  final String time;


  AddDietLogPage({required this.uid, required this.time});

  @override
  _AddDietLogPageState createState() => _AddDietLogPageState();
}

class _AddDietLogPageState extends State<AddDietLogPage> {
  File? _image;
  final picker = ImagePicker();
  final vision = FlutterVision();
  final _foodNameController = TextEditingController();
  String? _detectedClass;
  Map<String, dynamic>? _foodNutrition;
  List<Map<String, dynamic>> _detectionResults = [];

  @override
  void dispose() {
    vision.closeYoloModel();
    _foodNameController.dispose();
    super.dispose();
  }

  Future getImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _detectionResults.clear();
      });
      detectImage(_image!); // 이미지 선택 후, detectImage 호출
    } else {
      print('No image selected.');
    }
  }

  Future<void> detectImage(File image) async {
    // Load YOLO model and labels
    final bytes = await image.readAsBytes();
    await vision.loadYoloModel(
      labels: 'assets/model/label.txt',
      modelPath: 'assets/model/best.tflite',
      modelVersion: "yolov8",
      quantization: false,
      numThreads: 1,
      useGpu: false,
    );


    final result = await vision.yoloOnImage(
      bytesList: bytes,
      imageHeight: 480,
      // Example size, adjust to your image
      imageWidth: 480,
      // Example size, adjust to your image
      iouThreshold: 0.5,
      confThreshold: 0.5,
      classThreshold: 0.5,
    );

    if (result.isNotEmpty) {
      setState(() {
        _detectedClass = result.first['tag'];
        _detectionResults = List<Map<String, dynamic>>.from(result);
      });
      fetchNutritionInfo(_detectedClass!);
    } else {
      // 결과가 비어 있을 때 사용자에게 알림을 보냅니다.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('음식 사진을 찾을 수 없습니다. 다시 시도해주세요.'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> fetchNutritionInfo(String foodName) async {
    print('Searching for nutrition data of: $foodName'); // 검색하려는 식품명 로그 출력
    try {
      final nutritionData = await FirebaseFirestore.instance
          .collection('food_nutrition')
          .where('식품명', isEqualTo: foodName)
          .limit(1)
          .get();

      if (nutritionData.docs.isNotEmpty) {
        setState(() {
          _foodNutrition = nutritionData.docs.first.data();
          print('Found nutrition data: $_foodNutrition');
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('잘못된 이름입니다.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      print('Error fetching nutrition info: $e');
    }
  }






  Future<void> saveDietLog() async {
    if (_foodNutrition != null) {
      await FirebaseFirestore.instance.collection('diet_log').add({
        'uid': widget.uid,
        'date': DateTime.now().toString().split(' ')[0],
        'time':  widget.time,
        'calories': _foodNutrition!['에너지(㎉)'] ?? 0,
        'carbs': _foodNutrition!['탄수화물(g)'] ?? 0,
        'protein': _foodNutrition!['단백질(g)'] ?? 0,
        'fats': _foodNutrition!['지방(g)'] ?? 0,
      });
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('식단 사진 추가'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: _image == null ? Text('이미지를 선택하거나 카메라로 찍어주세요.') : Container(
                  child: CustomPaint(
                    foregroundPainter: BoxPainter(results: _detectionResults, scaleFactor: 0.6),
                    child: Image.file(_image!, fit: BoxFit.cover),
                  ),
                ),
              ),
              SizedBox(height: 20),
              _detectedClass == null
                  ? Text('식품을 인식하는 중...')
                  : Text('인식된 식품: $_detectedClass'),
              SizedBox(height: 20),
              _foodNutrition == null
                  ? Text('영양 정보를 불러오는 중...')
                  : Column(
                children: <Widget>[
                  Text('칼로리: ${_foodNutrition!['에너지(㎉)']} kcal'),
                  Text('탄수화물: ${_foodNutrition!['탄수화물(g)']} g'),
                  Text('단백질: ${_foodNutrition!['단백질(g)']} g'),
                  Text('지방: ${_foodNutrition!['지방(g)']} g'),
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => getImage(ImageSource.gallery),
                child: SizedBox(
                  width: 300, // 원하는 너비로 조정
                  height: 50,
                  child: Center(
                    child: Text('갤러리에서 선택하기',style: TextStyle(
                      color: Colors.white
                    ),),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF129575),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => getImage(ImageSource.camera),
                child: SizedBox(
                  width: 300, // 원하는 너비로 조정
                  height: 50,
                  child: Center(
                    child: Text('카메라로 촬영하기', style: TextStyle(
                      color: Colors.white
                    ),),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF129575),
                ),
              ),
              SizedBox(height: 20),

              ElevatedButton(
                onPressed: saveDietLog,
                child: SizedBox(
                  width: 300, // 원하는 너비로 조정
                  height: 50,
                  child: Center(
                    child: Text('식사 정보 저장', style: TextStyle(
                      color: Colors.white
                    ),),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF129575),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class BoxPainter extends CustomPainter {
  final List<dynamic> results; // YOLO 감지 결과
  final double scaleFactor; // 이미지 확대/축소 비율

  BoxPainter({required this.results, required this.scaleFactor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    for (var result in results) {
      final box = result['box'];
      final tag = result['tag'];

      // 바운딩 박스 좌표 계산
      final left = box[0] * scaleFactor;
      final top = box[1] * scaleFactor;
      final right = box[2] * scaleFactor;
      final bottom = box[3] * scaleFactor;

      // 바운딩 박스 그리기
      canvas.drawRect(Rect.fromLTRB(left, top, right, bottom), paint);

      // 클래스 이름 텍스트 그리기
      final textSpan = TextSpan(
        text: tag,
        style: TextStyle(color: Colors.red, fontSize: 14),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(left, top )); // 클래스 이름 위치 조정
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
