import 'package:better_together_app/service/auth_service.dart';
import 'package:better_together_app/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginSignUpWidget extends StatefulWidget {
  @override
  _LoginSignUpState createState() => _LoginSignUpState();
}



enum AuthMode { Signup, Login }

class _LoginSignUpState extends State<LoginSignUpWidget> {

  AuthMode _authMode = AuthMode.Login;

  final _formKey = GlobalKey<FormState>();
  String _password;
  String _email;


  @override
  Widget build(BuildContext context) {
    final logo = Hero(
      tag: 'hero',
      child: CircleAvatar(
        backgroundColor: Colors.transparent,
        radius: 48.0,
        child: Image.asset('assets/images/icon-logo.png'),
      ),
    );

    final _passwordField = TextFormField(
        validator: (value) {
          if (value.isEmpty) return i18n(context, 'mandatory_field');
          return null;
        },
        onSaved: (value) => _password = value,
        obscureText: true,
        decoration: InputDecoration(
            labelText: "Password",
            errorStyle: TextStyle(color: Theme.of(context).errorColor)
        )
    );

    Widget _buildPasswordConfirmField() {
      return TextFormField(
        decoration: InputDecoration(
            labelText: i18n(context,'confirm_password'),
            filled: true,
            errorStyle: TextStyle(color: Theme.of(context).errorColor)
        ),
        obscureText: true,
        validator: (value) {
          if (value.isEmpty) return i18n(context, 'mandatory_field');
          if(value != _password) return "Password not match";
          return null;
        },
      );
    }

    final loginButton = SizedBox(
      width: MediaQuery.of(context).size.width - 150, // double.infinity,
      child:
        RaisedButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(  _authMode == AuthMode.Login
              ? i18n(context,"login")
              : i18n(context,"signup")
          ),
          onPressed: () async {

            // save the fields..
            final form = _formKey.currentState;
            form.save();

            if (form.validate()) {
              _loginOrSignup();
            }
          },
        )
    );

    final switchBetween = FlatButton(
      child: Text(
        _authMode == AuthMode.Login
            ? i18n(context, "signup_phrase")
            : i18n(context, "login_phrase"),
        style: TextStyle(color: Colors.white),
      ),
      onPressed: ()  {
        setState(() {
          _authMode = _authMode == AuthMode.Login ? AuthMode.Signup : AuthMode.Login;
        });
      },
    );

    final skipLogin = FlatButton(
      child: Text(
        i18n(context,   'sign_in_anonymously'),
        style: TextStyle(color: Colors.white),
      ),
      onPressed: () async {
        await Provider.of<AuthService>(context).signInAnonymously();
      },
    );


    return Scaffold(
        body: Container(
            padding: EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Form(
                  key: _formKey,
                  child: Column(children: <Widget>[
                    SizedBox(height: 20.0),
                    logo,
                    SizedBox(height: 60.0),
                    TextFormField(
                        validator: (value) {
                          if (value.isEmpty) return i18n(context, 'mandatory_field');
                          return null;
                        },
                        onSaved: (value) => _email = value,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                            labelText: "Email",
                            errorStyle: TextStyle(color: Theme.of(context).errorColor)
                        )
                    ),
                    _passwordField,
                    _authMode == AuthMode.Signup
                        ? _buildPasswordConfirmField()
                        : Container(),
                    SizedBox(height: 20.0),
                    loginButton,
                    switchBetween,
                    SizedBox(height: 120.0),
                    skipLogin
                  ])),
            )));
  }

  Future _buildErrorDialog(BuildContext context, _message) {
    return showDialog(
      builder: (context) {
        return AlertDialog(
          title: Text('Error Message'),
          content: Text(_message),
          actions: <Widget>[
            FlatButton(
                child: Text(i18n(context,'cancel')),
                onPressed: () {
                  Navigator.of(context).pop();
                })
          ],
        );
      },
      context: context,
    );
  }

  Future _loginOrSignup() async {
    try {
      if(_authMode == AuthMode.Login){
        await Provider.of<AuthService>(context).loginUser(email: _email, password: _password);
      }else {
        await Provider.of<AuthService>(context).signUp(email: _email, password: _password);
      }
    } on AuthException catch (error) {
      return _buildErrorDialog(context, error.message);
    } on Exception catch (error) {
      return _buildErrorDialog(context, error.toString());
    }
  }

}

