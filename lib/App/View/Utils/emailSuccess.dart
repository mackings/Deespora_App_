import 'package:dspora/App/View/Widgets/customtext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';



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
            padding: const EdgeInsets.symmetric(vertical: 20,horizontal: 20),
            child: Column(
              children: [
                CustomText(text: "Check your Inbox",title: true,fontSize: 20,),

                SvgPicture.asset("assets/img/mail.png",color: Colors.amber,)
              ],
            ),
          ),
        ),
      )),
    );
  }
}