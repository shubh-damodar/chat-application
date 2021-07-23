import 'package:flutter/material.dart';
import 'package:mesbro_chat_flutter_app/bloc_patterns/idm_bloc_patterns/verify_mobile_number_bloc.dart';
import 'package:mesbro_chat_flutter_app/utils/navigation_actions.dart';
import 'package:mesbro_chat_flutter_app/utils/widgets_collection.dart';

import 'change_password_page.dart';

class VerifyMobileNumberPage extends StatefulWidget {
  final String otpToken, mobile, previousScreen;

  VerifyMobileNumberPage({this.otpToken, this.mobile, this.previousScreen});

  _VerifyMobileNumberPageState createState() => _VerifyMobileNumberPageState();
}

class _VerifyMobileNumberPageState extends State<VerifyMobileNumberPage> {
  VerifyMobileNumberBloc _verifyMobileNumberBloc;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _mobileTextEditingController = TextEditingController(),
      _otpTextEditingController = TextEditingController();
  NavigationActions _navigationActions;
  WidgetsCollection _widgetsCollection;

  void initState() {
    super.initState();
    _verifyMobileNumberBloc = VerifyMobileNumberBloc(context);
    _mobileTextEditingController.text = widget.mobile;
    _navigationActions = NavigationActions(context);
    _widgetsCollection = WidgetsCollection(context);
  }

  void dispose() {
    super.dispose();
    _verifyMobileNumberBloc.dispose();
    _mobileTextEditingController.dispose();
    _otpTextEditingController.dispose();
  }

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.deepOrange,
          title: Text(
            'Verify mobile number',
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(10.0),
          child: Form(
            key: _formKey,
            child: Center(
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(50.0),
                  ),
                  ListTile(
                    title: new Center(
                      child: new Text(
                        "Verify Mobile Number",
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 20.0,
                            color: Colors.black),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(30.0),
                  ),
                  TextFormField(
                    controller: _mobileTextEditingController,
                    maxLength: 10,
                    validator: (String value) {
                      String _mobileNoPattern = '^[0-9]{10}\$';
                      RegExp _regExp = RegExp(_mobileNoPattern);
                      if (!_regExp.hasMatch(value)) {
                        return 'Mobile No should contain exactly 10 digits';
                      }
                    },
                    enabled: false,
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  TextFormField(
                    controller: _otpTextEditingController,
                    maxLength: 6,
                    validator: (String value) {
                      String _otpPattern = '^[0-9]{6}\$';
                      RegExp _regExp = RegExp(_otpPattern);
                      if (!_regExp.hasMatch(value)) {
                        return 'OTP should contain exactly 6 digits';
                      }
                    },
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                        hintText: 'Your one time password',
                        labelText: 'Enter OTP',
                        labelStyle: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 16.0,
                        )),
                  ),
                  RaisedButton(
                      color: Colors.deepOrange,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0)),
                      child: Text(
                        'Verify Mobile number',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      onPressed: () {
                        if (_formKey.currentState.validate()) {
                          _widgetsCollection.showMessageDialog();
                          _verifyMobileNumberBloc.verifyMobileNumber(
                              widget.otpToken, _otpTextEditingController.text);
                        }
                      }),
                  // GestureDetector(
                  //     child: Text(
                  //       'Resend OTP',
                  //       textAlign: TextAlign.center,
                  //     ),
                  //     onTap: () {
                  //       _verifyMobileNumberBloc.resendOTP(widget.otpToken);
                  //     }),
                  GestureDetector(
                    child: Container(
                        margin: EdgeInsets.only(top: 20.0),
                        child: Text('Resend OTP?',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 13.0,
                                color: Colors.black38))),
                    onTap: () {
                      _verifyMobileNumberBloc.resendOTP(widget.otpToken);
                    },
                  ),
                  StreamBuilder(
                      stream: _verifyMobileNumberBloc.verifyStream,
                      builder: (BuildContext context,
                          AsyncSnapshot<Map<String, dynamic>> asyncSnapshot) {
                        return asyncSnapshot.data == null
                            ? Container()
                            : _verifyFinished(asyncSnapshot.data);
                      }),
                ],
              ),
            ),
          ),
        ));
  }

  Widget _verifyFinished(Map<String, dynamic> mapResponse) {
    Future.delayed(Duration.zero, () {
      _navigationActions.closeDialogRoot();
      _verifyMobileNumberBloc.verifyStreamSink.add(null);

      if (mapResponse['code'] == 200) {
        //print('~~~ widget.previousScreen: ${widget.previousScreen}');
        _navigationActions.navigateToScreenWidget(ChangePasswordPage(
            resetToken: widget.otpToken,
            previousScreen: widget.previousScreen));
      } else if (mapResponse['code'] == 400) {
        _widgetsCollection.showToastMessage(mapResponse['content']['message']);
      } else {
        _widgetsCollection.showToastMessage(mapResponse['content']['message']);
      }
    });
    return Container();
  }
}
