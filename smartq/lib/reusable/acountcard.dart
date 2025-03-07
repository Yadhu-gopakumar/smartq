import 'package:flutter/material.dart';

class AccountCards extends StatelessWidget {
  final IconData aicon;
  final String atext;
  const AccountCards({super.key, required this.aicon, required this.atext});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: Container(
          decoration: const BoxDecoration(
              border: Border(
                  bottom: BorderSide(
                color: Colors.grey,
                width: 0.5,
              ))),
          height: 60,
          width: MediaQuery.of(context).size.width,
          child: Row(
            
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
            const SizedBox(width: 15,),
              Icon(aicon,size: 30,color: Colors.grey[600],),
            const SizedBox(width: 10,),

              Text(atext,style: TextStyle(color: Colors.grey[800],fontSize: 18,letterSpacing: 0.2),),
            ],
          ),
        ),
      ),
    );
  }
}
