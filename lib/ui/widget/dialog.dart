import 'package:flutter/material.dart';

 showMyDialog(BuildContext context,String msg) {
  showDialog<String>(
    context: context,
    builder: (BuildContext context) =>
        AlertDialog(
          title: const Text('AlertDialog'),
          content: Text(msg,style: const TextStyle(fontSize: 16,color:Colors.black)),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, 'OK'),
              child: const Text('OK',style: TextStyle(fontSize: 15,color:Colors.black,fontFamily: 'OpenSans',
                fontWeight: FontWeight.bold,),),
            ),
          ],
        ),
  );

}




