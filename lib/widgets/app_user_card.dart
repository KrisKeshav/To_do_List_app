import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:to_do_list_app/helper/global.dart';
import 'package:to_do_list_app/models/app_user.dart';

class AppUserCard extends StatefulWidget {
  final AppUser user;
  const AppUserCard({super.key, required this.user});

  @override
  State<AppUserCard> createState() => _AppUserCardState();
}

class _AppUserCardState extends State<AppUserCard> {
  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;

    return Card(
      margin: EdgeInsets.symmetric(horizontal: mq.width * 0.04, vertical: 4),
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () {},
        child: ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(mq.height * 0.3),
            child: Image.network(
              widget.user.image,
              width: mq.height * 0.055,
              height: mq.height * 0.055,
              errorBuilder: (context, error, stackTrace) =>
              const CircleAvatar(child: Icon(CupertinoIcons.person)),
            ),
          ),
          title: Text(widget.user.name),
          subtitle: Text(
            widget.user.about,
            maxLines: 1,
          ),
          trailing: Container(
            width: 15,
            height: 15,
            decoration: BoxDecoration(color: Colors.tealAccent.shade200, borderRadius: BorderRadius.circular(10)),
          ),
          // trailing: const Text(
          //   '12:00 PM',
          //   style: TextStyle(color: Colors.black54),
          // ),
        ),
      ),
    );
  }
}
