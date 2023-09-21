import 'package:flutter/material.dart';

class MessagePage extends StatelessWidget {
  const MessagePage({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: const [Icon(Icons.notifications), Icon(Icons.message)],
        bottom: PreferredSize(
          preferredSize: Size(size.width, 40),
          child: Container(
            padding: const EdgeInsetsDirectional.symmetric(horizontal: 10),
            width: size.width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
              const CircleAvatar(
                radius: 20,
              ),
              const SizedBox(width: 10,),
              Expanded(
                child: Container(
                  height: 35,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(left: 15),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: Colors.grey[200]),
                    child: const Row(
                      children: [
                        Icon(Icons.create,
                        size: 18,),
                        SizedBox(width: 5,),
                        Text('Tulis sesuatu'),
                      ],
                    ),
                ),
              )
            ]),
          ),
        ),
      ),
    );
  }
}
