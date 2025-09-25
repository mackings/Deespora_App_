import 'package:dspora/App/View/Utils/pinSheet.dart';
import 'package:dspora/App/View/Widgets/custombtn.dart';
import 'package:dspora/App/View/Widgets/customtext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';




class EmailSuccess extends ConsumerStatefulWidget {
  const EmailSuccess({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _EmailSuccessState();
}

class _EmailSuccessState extends ConsumerState<EmailSuccess> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 50,horizontal: 20),
            child: Column(
              children: [

                CustomText(text: "Check your Inbox",title: true,fontSize: 20,),
                SizedBox(height: 30,),
                Image.asset("assets/img/mail.png",),

                SizedBox(height: 30,),

                CustomText(text: "We’ve emailed you a secure link to reset your password.  It may take a few moments to arrive.",textAlign: TextAlign.center,),

                SizedBox(height: 20,),

                CustomText(text: "📌 Note: If you don’t see it soon, be sure to check your Spam or Junk folder.",textAlign: TextAlign.center,),

                SizedBox(height: 50,),

                CustomBtn(text: "Verify Code", onPressed: (){


                      showOtpModalSheet(
      context: context,
      onCompleted: (code) {
        print('Code entered: $code');
        Navigator.pop(context); 
      },
      onResend: () {
        print('Resend requested');
      },
    );

                })

              ],
            ),
          ),
        ),
      )),
    );
  }
}