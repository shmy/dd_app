import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:toasty/toasty.dart';
import 'package:loading/loading.dart';
import 'package:dd_app/utils/db/user.dart';
import 'package:dd_app/utils/dio.dart';
import 'package:dio/dio.dart';

class SendData {
  String username = '';
  String password = '';
  String re_password = '';
}

class SignInPage extends StatefulWidget {
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  bool isLogin = true;
  SendData _sendData = SendData();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("登录"),
        elevation: 0.0,
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        color: Theme.of(context).primaryColor,
        // decoration: BoxDecoration(
        //   image: DecorationImage(
        //       image: AssetImage("images/login_bg.webp"), fit: BoxFit.cover),
        //   // color: Colors.red,
        // ),
        child: SingleChildScrollView(
          padding: EdgeInsets.only(left: 20.0, right: 20.0, top: 50.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: _buildLayout(),
          ),
        ),
      ),
    );
  }

  // 验证部分
  String _validateUserName(String value) {
    if (value.length < 4) {
      return "用户名至少需要4个字符";
    }

    return null;
  }

  String _validatePassword(String value) {
    if (value.length < 6) {
      return "密码至少需要6个字符";
    }

    return null;
  }

  String _validateRePassword(String value, String psw) {
    if (value.length < 6) {
      return "确认密码至少需要6个字符";
    }
    if (value != psw) {
      return "两次密码输入必须一致";
    }
    return null;
  }

  void _loginSubmit() async {
    String vUsername = _validateUserName(this._sendData.username);
    if (vUsername != null) {
      Toasty.warning(vUsername);
      return;
    }
    String vPassword = _validatePassword(this._sendData.password);
    if (vPassword != null) {
      Toasty.warning(vPassword);
      return;
    }
   
    Loading.show("登陆中...");
    dynamic payload = await Fetch.instance.post("/profile/sign_in", data: {
      "username": this._sendData.username,
      "password": this._sendData.password,
    });
    Loading.hide();
    if (payload == null) return;
    _getUserDetail(payload["token"]);
  }
  // 获取用户信息存储
  void _getUserDetail (String token) async {
    // _goBack(payload["username"]);
    dynamic payload = await Fetch.instance.get("/profile/detail", options: new Options(
      headers: { "Authorization": "Bearer " + token },
    ));
    if (payload == null) return;
    User userModel = await User.instance;
    await userModel.truncateTable(); // 先清空表
    await userModel.insert({
      "_id": payload["_id"],
      "username": payload["username"],
      "nickname": payload["nickname"],
      "avatar": payload["avatar"],
      "email": payload["email"],
      "level": payload["level"],
      "integral": payload["integral"],
      "token": token,
      "overdue": (DateTime.now().millisecondsSinceEpoch + 1000 * 60 * 60 * 24 * 7), // 过期时间
    });
    _goBack(payload["username"]);
  }
  void _registeredSubmit() async {
    String vUsername = _validateUserName(this._sendData.username);
    if (vUsername != null) {
      Toasty.warning(vUsername);
      return;
    }
    String vPassword = _validatePassword(this._sendData.password);
    if (vPassword != null) {
      Toasty.warning(vPassword);
      return;
    }
    String vRePassword = _validateRePassword(
        this._sendData.re_password, this._sendData.password);
    if (vRePassword != null) {
      Toasty.warning(vRePassword);
      return;
    }
    
    Loading.show("注册中...");
    FormData formData = new FormData.from({
      "username": this._sendData.username,
      "password": this._sendData.password,
      "re_password": this._sendData.re_password,
  });
    dynamic payload = await Fetch.instance.post("/profile/sign_up", data: formData);
    Loading.hide();
    if (payload == null) return;
    _getUserDetail(payload["token"]);
  }

  void _goBack (String username) {
    Toasty.success("欢迎你" + username + "");
    Navigator.pop(context, "SUCCESS");
  }
  // 构建组件
  Widget _buildLogo() {
    return Container(
      margin: EdgeInsets.only(bottom: 30.0),
      child: Image(
        height: 95.0,
        width: 100.0,
        image: AssetImage("images/logo.webp"),
        fit: BoxFit.fill,
      ),
    );
  }

  Widget _buildUserNameTextField() {
    return Container(
      margin: EdgeInsets.only(bottom: 10.0),
      child: TextField(
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.people),
          contentPadding: EdgeInsets.all(10.0),
          counterText: "4-16位英文数字下划线组合",
          counterStyle: TextStyle(color: Colors.white),
          prefixStyle: TextStyle(),
          hintText: "请输入用户名",
          filled: true,
          fillColor: Colors.grey[200],
          border: InputBorder.none,
        ),
        keyboardType: TextInputType.text,
        autofocus: true,
        onChanged: (String val) {
          this._sendData.username = val;
        },
      ),
    );
  }

  Widget _buildPasswordTextField() {
    return Container(
      margin: EdgeInsets.only(bottom: 10.0),
      child: TextField(
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.lock),
          contentPadding: EdgeInsets.all(10.0),
          hintText: "请输入密码",
          counterText: "6-16位英文数字下划线组合",
          counterStyle: TextStyle(color: Colors.white),
          filled: true,
          fillColor: Colors.grey[200],
          border: InputBorder.none,
        ),
        obscureText: true,
        onChanged: (String val) {
          this._sendData.password = val;
        },
      ),
    );
  }

  Widget _buildRePasswordTextField() {
    return Container(
      margin: EdgeInsets.only(bottom: 10.0),
      child: TextField(
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.lock),
          contentPadding: EdgeInsets.all(10.0),
          hintText: "请确认密码",
          counterText: "6-16位英文数字下划线组合",
          counterStyle: TextStyle(color: Colors.white),
          filled: true,
          fillColor: Colors.grey[200],
          border: InputBorder.none,
        ),
        obscureText: true,
        onChanged: (String val) {
          this._sendData.re_password = val;
        },
      ),
    );
  }

  List<Widget> _buildLayout() {
    if (this.isLogin) {
      return [
        _buildLogo(),
        _buildUserNameTextField(),
        _buildPasswordTextField(),
        Container(
          // margin: EdgeInsets.only(top: 10.0),
          child: MaterialButton(
            minWidth: MediaQuery.of(context).size.width - 40,
            height: 50.0,
            color: Colors.blue,
            onPressed: _loginSubmit,
            child: Text(
              "立即登录",
              style: TextStyle(color: Colors.white, fontSize: 16.0),
            ),
          ),
        ),
        Container(
          // padding: EdgeInsets.only(top: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              CupertinoButton(
                pressedOpacity: 0.5,
                onPressed: () {
                  this._sendData.re_password = "";
                  setState(() {
                    this.isLogin = false;
                  });
                },
                child: Text(
                  "没有账号？立即注册！",
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.orange,
                  ),
                ),
              ),
              // CupertinoButton(
              //   pressedOpacity: 0.5,
              //   onPressed: () {},
              //   child: Text(
              //     "找回密码",
              //     style: TextStyle(fontSize: 14.0,color: Colors.black,),
              //   ),
              // )
            ],
          ),
        )
      ];
    }
    return [
      _buildLogo(),
      _buildUserNameTextField(),
      _buildPasswordTextField(),
      _buildRePasswordTextField(),
      Container(
        // margin: EdgeInsets.only(top: 10.0),
        child: MaterialButton(
          minWidth: MediaQuery.of(context).size.width - 40,
          height: 50.0,
          color: Colors.blue,
          onPressed: _registeredSubmit,
          child: Text(
            "注册并登陆",
            style: TextStyle(color: Colors.white, fontSize: 16.0),
          ),
        ),
      ),
      Center(
        // padding: EdgeInsets.only(top: 20.0),
        child: CupertinoButton(
          pressedOpacity: 0.5,
          onPressed: () {
            this._sendData.re_password = "";
            setState(() {
              this.isLogin = true;
            });
          },
          child: Text(
            "已有账号？立即登录！",
            style: TextStyle(
              color: Colors.orange,
            ),
          ),
        ),
      ),
    ];
  }
}
