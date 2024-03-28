import 'package:cloud_firestore/cloud_firestore.dart';
import 'LoginPage.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'SignupPage_2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao;


class SignupPage extends StatefulWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isPrivacyPolicyChecked = false;
  String _name = "";
  String _email = "";
  String _password = "";

  void _togglePrivacyPolicy(bool? value) {
    setState(() {
      _isPrivacyPolicyChecked = value!;
    });
  }

  void _saveForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      if (_isPrivacyPolicyChecked) {
        try {
          final UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: _email,
            password: _password,
          );
          final User? user = userCredential.user;
          if (user != null) {
            print("사용자 등록 성공: ${user.uid}");
            final userInfo = {
              'name': _name,
              'email': _email,
              'uid': user.uid,
            };
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SignupPage_2(userInfo: userInfo)),
            );
          }
        } on FirebaseAuthException catch (e) {
          if (e.code == 'email-already-in-use') {
            print("이메일이 이미 사용 중입니다.");
            // 여기서 AlertDialog를 표시합니다.
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text("알림"),
                  content: Text("이메일이 이미 사용 중입니다. 다른 이메일을 사용해 주세요."),
                  actions: <Widget>[
                    TextButton(
                      child: Text("닫기"),
                      onPressed: () {
                        Navigator.of(context).pop(); // 대화 상자를 닫습니다.
                      },
                    ),
                  ],
                );
              },
            );
          } else {
            print("사용자 등록 실패: ${e.message}");
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text("회원가입 실패"),
                  content: Text("사용자 등록에 실패했습니다: ${e.message}"),
                  actions: <Widget>[
                    TextButton(
                      child: Text("닫기"),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );
          }
        } catch (e) {
          print("사용자 등록 실패: $e");
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("회원가입 실패"),
                content: Text("사용자 등록에 실패했습니다: $e"),
                actions: <Widget>[
                  TextButton(
                    child: Text("닫기"),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        }
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("알림"),
              content: Text("개인정보 처리방침에 동의해주세요."),
              actions: <Widget>[
                TextButton(
                  child: Text("닫기"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    }
  }




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
          LabelSection(formKey: _formKey),
          PrivacyPolicy(onChanged: _togglePrivacyPolicy, isChecked: _isPrivacyPolicyChecked),
          ButtonLogin(onPressed: _saveForm,),
          Or(),
          LoginSocialMedia(),
          hasAccount()



        ]),
      ),
    );
  }
}



class TitleSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 200,
          height: 130,
          child: Stack(
            children: [
              Positioned(
                left: 56,
                top: 52,
                child: Text(
                  '안녕하세요.',
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
                top: 81,
                child: Text(
                  '계정을 만들어보세요!',
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
  final GlobalKey<FormState> formKey;

  const LabelSection({
    Key? key,
    required this.formKey,
  }) : super(key: key);


  @override
  Widget build(BuildContext context) {
    final _SignupPageState parentState = context.findAncestorStateOfType<_SignupPageState>()!;
    return Form(
      key: formKey,
      child: Column(
        children: [
          SizedBox(height: 100),
          Container(
            width: 315,
            height: 190,
            child: Stack(
              children: [
                // Positioned(
                //   left: 88,
                //   top: 130,
                //   child: Text(
                //     '비밀번호를 까먹으셨나요?',
                //     style: TextStyle(
                //       color: Color(0xFFACA3A5),
                //       fontSize: 12,
                //       fontFamily: 'Poppins',
                //       fontWeight: FontWeight.w500,
                //       decoration: TextDecoration.underline,
                //       height: 0.12,
                //     ),
                //   ),
                // ),
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
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: '이름',
                        labelStyle: TextStyle(
                          color: Color(0xFFACA3A5),
                          fontSize: 16,
                          fontFamily: 'Poppins',
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: Icon(Icons.person, color: Color(0xFFACA3A5)),
                      ),
                      style: TextStyle(color: Colors.black),
                      onSaved: (value) {
                        parentState._name = value ?? '';
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '이름을 입력해주세요.';
                        }
                        return null;
                      },
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
                      decoration: InputDecoration(
                        labelText: '이메일',
                        labelStyle: TextStyle(
                          color: Color(0xFFACA3A5),
                          fontSize: 16,
                          fontFamily: 'Poppins',
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: Icon(Icons.email, color: Color(0xFFACA3A5)),
                      ),
                      style: TextStyle(color: Colors.black),
                      onSaved: (value) {
                        parentState._email = value ?? '';
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '이메일을 입력해주세요.';
                        } else if (!value.contains('@')) {
                          return '유효한 이메일 주소를 입력해주세요.';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  top: 126,
                  child: Container(
                    width: 315,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Color(0xFFF7F8F8),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Color(0xFFF7F8F8)),
                    ),
                    child: TextFormField(
                      obscureText: true,
                      onSaved: (value) {
                        parentState._password = value ?? '';
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '비밀번호를 입력해주세요.';
                        } else if (value.length < 7) {
                          return '비밀번호는 7자 이상이어야 합니다.';
                        }
                        return null;
                      },
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
      ),
    );
  }
}


class PrivacyPolicy extends StatelessWidget {
  final bool isChecked;
  final ValueChanged<bool?> onChanged;

  const PrivacyPolicy({Key? key, required this.isChecked, required this.onChanged}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 260,
        height: 20, // 컨테이너의 높이와 너비 설정
        child: Row( // Row 위젯을 사용하여 수평으로 정렬
          children: [
            Checkbox(
              value: isChecked,
              onChanged: onChanged,
              checkColor: Colors.white, // 체크 표시 색상을 흰색으로
              activeColor: Colors.green, // 체크박스 배경을 초록색으로
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            Expanded( // 텍스트를 확장하여 체크박스 오른쪽 전체 영역을 차지하도록 함
              child: Text(
                '개인정보 취급 방침과 이용 약관에 동의',
                style: TextStyle(
                  color: Color(0xFFACA3A5),
                  fontSize: 12,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ButtonLogin extends StatelessWidget {
  final VoidCallback onPressed;

  const ButtonLogin({Key? key, required this.onPressed}) : super(key: key);

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
            decoration: BoxDecoration(
              color: Color(0xFF129575), // 배경색
              borderRadius: BorderRadius.circular(99), // 모서리 둥글게
            ),
            child: Center(
              child: Text(
                '회원가입 진행',
                style: TextStyle(
                  color: Colors.white, // 텍스트 색상
                  fontSize: 16, // 텍스트 크기
                  fontFamily: 'Poppins', // 폰트
                  fontWeight: FontWeight.w700, // 폰트 두께
                ),
              ),
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
  // Google 로그인 메서드
  Future<void> _signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();

      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );

        try {
          final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
          final User? user = userCredential.user;

          if (user != null) {
            final userInfo = {
              'name': user.displayName ?? 'No Name',
              'email': user.email,
              'uid': user.uid,
            };

            final userSnapshot = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
            if (userSnapshot.exists) {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text("알림"),
                    content: Text("이미 등록된 이메일이 있습니다. 로그인 해주세요."),
                    actions: <Widget>[
                      TextButton(
                        child: Text("로그인"),
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => LoginPage()),
                          );
                        },
                      ),
                    ],
                  );
                },
              );
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => SignupPage_2(userInfo: userInfo)),
              );
            }
          }
        } catch (e) {
          print("Google Sign-In Error: $e");
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("알림"),
                content: Text("Google 로그인에 실패했습니다."),
                actions: <Widget>[
                  TextButton(
                    child: Text("확인"),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        }
      }
    } catch (e) {
      print("Google Sign-In Error: $e");
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("알림"),
            content: Text("Google 로그인에 실패했습니다."),
            actions: <Widget>[
              TextButton(
                child: Text("확인"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }


  // Kakao 로그인 성공 후 다음 단계로 이동하는 메서드
  void _proceedToNextStep(BuildContext context, kakao.User user) {
    // Kakao 로그인 성공 후에는 SignupPage_2로 이동
    // 이 때, 사용자 정보를 SignupPage_2로 전달할 수 있도록 userInfo 맵을 생성하여 전달할 수 있음
    final userInfo = {
      'name': user.kakaoAccount?.profile?.nickname ?? 'No Name',
      'email': user.kakaoAccount?.email,
      'uid': user.id.toString(), // 카카오 사용자 ID를 문자열로 변환하여 사용
    };

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => SignupPage_2(userInfo: userInfo)),
    );
  }

  Future<void> _signInWithKakao(BuildContext context) async {
    try {
      kakao.OAuthToken token;
      try {
        token = await kakao.UserApi.instance.loginWithKakaoTalk();
      } catch (error) {
        // 카카오톡으로 로그인 시도에 실패한 경우, 카카오 계정으로 로그인 시도
        print('카카오톡으로 로그인 시도 실패: $error');
        token = await kakao.UserApi.instance.loginWithKakaoAccount();
      }

      // Kakao 사용자 정보 요청
      kakao.User user = await kakao.UserApi.instance.me();
      print('카카오 로그인 성공: 사용자 정보 - $user');

      // 로그인 성공 후 처리
      _proceedToNextStep(context, user);
    } catch (e) {
      print("Kakao Sign-In Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('카카오 로그인에 실패했습니다.')));
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
                    _signInWithGoogle(context);
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
                          child: SvgPicture.asset(
                            'assets/google.svg',
                            width: 25,
                            height: 25,
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
                child: GestureDetector(
                  onTap: () {
                    _signInWithKakao(context); // 클릭 시 카카오 로그인 시도
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
                          child: SvgPicture.asset(
                            'assets/kakaotalk.svg',
                            width: 27,
                            height: 27,
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
      ],
    );
  }
}

class hasAccount extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 40,),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: '이미 계정을 가지고 계신가요? ',
                style: TextStyle(
                  color: Color(0xFF1D1517),
                  fontSize: 14,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w400,
                  height: 1.4,
                ),
              ),
              TextSpan(
                text: '로그인',
                style: TextStyle(
                  color: Color(0xFF2F5DEA),
                  fontSize: 14,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                  }
              ),
            ],
          ),
        ),
      ],
    );
  }
}