import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'SignupPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'MainPage.dart';


class LoginPage extends StatelessWidget {
  late final TextEditingController emailController = TextEditingController();
  late final TextEditingController passwordController = TextEditingController();


  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color.fromARGB(255, 255, 255, 255),
      ),
      home: Scaffold(
        body: ListView(children: [
          TitleSection(),
          LabelSection(emailController: emailController, passwordController: passwordController),
          ButtonLogin(onPressed: () {
            _signInWithEmailAndPassword(context, emailController.text, passwordController.text);
          }),
          Or(),
          LoginSocialMedia(),
          forgetLogin(),
        ]),
      ),
    );
  }
}

Future<void> _signInWithEmailAndPassword(BuildContext context, String email, String password) async {
  try {

    final UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final User? user = userCredential.user;
    if (user != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainPage(uid: user.uid)),
      );
    }

  } on FirebaseAuthException catch (e) {
    String errorMessage;
    if (e.code == 'user-not-found') {
      errorMessage = '해당 이메일로 등록된 사용자가 없습니다.';
    } else if (e.code == 'wrong-password') {
      errorMessage = '비밀번호가 잘못되었습니다.';
    } else {
      errorMessage = '로그인에 실패했습니다. 다시 시도해주세요.';
    }
    // AlertDialog를 표시합니다.
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('로그인 실패'),
          content: Text(errorMessage),
          actions: <Widget>[
            TextButton(
              child: Text('확인'),
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그를 닫습니다.
              },
            ),
          ],
        );
      },
    );
  } catch (e) {
    // 기타 예외 처리
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('오류'),
          content: Text('알 수 없는 오류가 발생했습니다. 다시 시도해주세요.'),
          actions: <Widget>[
            TextButton(
              child: Text('확인'),
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그를 닫습니다.
              },
            ),
          ],
        );
      },
    );
  }
}

class TitleSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return Column(
      children: [
        Container(
          width: 100,
          height: 130, // 조정된 높이
          child: Stack(
            children: [
              Positioned(
                left: 14,
                top: 52, // 이전에 52로 설정되어 있었음
                child: Text(
                  '로그인',
                  style: TextStyle(
                    color: Color(0xFF1D1517),
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                    height: 0.09,
                  ),
                ),
              ),
              Positioned(
                left: 0,
                top: 81, // 이전에 81로 설정되어 있었음
                child: Text(
                  '요레할래',
                  style: TextStyle(
                    color: Color(0xFF1D1517),
                    fontSize: 20,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700,
                    height: 0.07,
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



class LabelSection extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;

  const LabelSection({
    required this.emailController,
    required this.passwordController,
  });



  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 100),
        Container(
          width: 315,
          height: 139,
          child: Stack(
            children: [
              Positioned(
                left: 88,
                top: 130,
                child: Text(
                  '비밀번호를 까먹으셨나요?',
                  style: TextStyle(
                    color: Color(0xFFACA3A5),
                    fontSize: 14,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.underline,
                    height: 0.12,
                  ),
                ),
              ),
              Positioned(
                left: 0,
                top: 0,
                child: Container(
                  width: 315,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Color(0xFFF7F8F8),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Color(0xFFF7F8F8)),
                  ),
                  child: TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: '이메일' ,
                      labelStyle: TextStyle(
                        color: Color(0xFFACA3A5),
                        fontSize: 16,
                        fontFamily: 'Poppins',

                      ),

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      // 아이콘 추가
                      prefixIcon:

                      Icon(Icons.email, color: Color(0xFFACA3A5)),
                    ),
                    style: TextStyle(
                      color: Colors.black, // 검정색 텍스트
                    ),
                  ),

                ),
              ),
              Positioned(
                left: 0,
                top: 63,
                child: Container(
                  width: 315,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Color(0xFFF7F8F8),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Color(0xFFF7F8F8)),
                  ),
                  child: TextFormField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: Icon(Icons.lock, color: Color(0xFFACA3A5)),
                      hintText: '패스워드',
                      hintStyle: TextStyle(
                        color: Color(0xFFACA3A5),
                        fontSize: 16,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ),

              ),
            ],
          ),
        ),
      ],
    );

  }
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
  }
}



class ButtonLogin extends StatelessWidget {
  final VoidCallback onPressed;

  ButtonLogin({required this.onPressed});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 150,),
        GestureDetector(
          onTap: onPressed,
          child: Container(
            width: 315,
            height: 60,
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  top: 0,
                  child: Container(
                    width: 315,
                    height: 60,
                    decoration: ShapeDecoration(
                      color: Color(0xFF129575),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 135,
                  top: 28,
                  child: Text(
                    '로그인',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w700,
                      height: 0.09,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}


class Or extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 40,),
        Container(
          width: 315,
          height: 18,
          child: Stack(
            children: [
              Positioned(
                left: 151,
                top: 0,
                child: Text(
                  'Or',
                  style: TextStyle(
                    color: Color(0xFF1D1517),
                    fontSize: 12,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    height: 0.12,
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

class LoginSocialMedia extends StatelessWidget {
  Future<void> _signInWithGoogle(BuildContext context) async {
    try {
      // 구글 로그인을 시도하고 사용자 정보를 가져옵니다.
      final GoogleSignInAccount? googleSignInAccount = await GoogleSignIn().signIn();
      if (googleSignInAccount != null) {
        // 구글 로그인이 성공하면 구글 인증 정보를 가져와서 Firebase에 인증합니다.
        final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );
        // Firebase에 인증 정보를 사용하여 로그인합니다.
        final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
        final User? user = userCredential.user;

        // 로그인이 성공했으므로 다음 화면으로 이동하거나 작업을 수행할 수 있습니다.
        if (user != null) {




          // 예시: 로그인이 성공하면 MainPage로 이동합니다.
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MainPage(uid: user.uid)),
          );
        }
      }
    } catch (e) {
      // 에러 처리
      print("Google Sign-In Error: $e");
      // 예시: 에러 메시지를 보여줍니다.
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Google 로그인에 실패했습니다.'))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 20,),
        Container(
          width: 130,
          height: 50,
          child: Stack(
            children: [
              Positioned(
                left: 0,
                top: 0,
                child: GestureDetector(
                  onTap: () {
                    _signInWithGoogle(context); // 클릭 시 구글 로그인 시도
                  },
                  child: Container(
                    width: 50,
                    height: 50,
                    child: Stack(
                      children: [
                        Positioned(
                          left: 0,
                          top: 0,
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: ShapeDecoration(
                              shape: RoundedRectangleBorder(
                                side: BorderSide(width: 0.80, color: Color(0xFFDDD9DA)),
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                        Center(
                          child: Positioned(
                            left: 15,
                            top: 15,
                            child: SvgPicture.asset(
                              'assets/google.svg',
                              width: 25,
                              height: 25,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 80,
                top: 0,
                child: Container(
                  width: 50,
                  height: 50,
                  child: Stack(
                    children: [
                      Positioned(
                        left: 0,
                        top: 0,
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: ShapeDecoration(
                            shape: RoundedRectangleBorder(
                              side: BorderSide(width: 0.80, color: Color(0xFFDDD9DA)),
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: Positioned(
                          left: 15,
                          top: 15,
                          child: SvgPicture.asset(
                            'assets/kakaotalk.svg',
                            width: 27,
                            height: 27,
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

class forgetLogin extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 40),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: '계정이 없으신가요? ',
                style: TextStyle(
                  color: Color(0xFF1D1517),
                  fontSize: 14,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w400,
                  height: 1.4, // height 수정: 0.11에서 1.4로 변경
                ),
              ),
              TextSpan(
                text: '회원가입',
                style: TextStyle(
                  color: Color(0xFFC58BF2),
                  fontSize: 14,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                  height: 1.4, // height 수정: 0.11에서 1.4로 변경
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SignupPage()), // SignupPage 페이지로 이동
                    );
                  },
              ),
            ],
          ),
        ),
      ],
    );
  }
}