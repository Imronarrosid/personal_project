import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:personal_project/constant/color.dart';
import 'package:personal_project/constant/dimens.dart';
import 'package:personal_project/presentation/assets/images.dart';
import 'package:personal_project/presentation/router/route_utils.dart';


class VideoItem extends StatelessWidget {
  const VideoItem({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      padding: EdgeInsets.only(bottom: 10),
      width: size.width,
      height: size.height,
      child: Stack(children: [
        Positioned(
            right: Dimens.DIMENS_12,
            bottom: 0,
            child: Column(
              children: [
                GestureDetector(
                  onTap: (){
            GoRouter.of(context).push(Uri(path: APP_PAGE.upload.toPath).toString());
                    
                  },
                  child: CircleAvatar()),
                 SizedBox(
                  height: Dimens.DIMENS_38,
                ),
                Icon(
                  Icons.favorite,
                  color: COLOR_white_fff5f5f5,
                  size: Dimens.DIMENS_38,
                ),
                Text(
                  '10',
                  style: TextStyle(color: COLOR_white_fff5f5f5),
                ),
                 SizedBox(
                  height: Dimens.DIMENS_12,
                ),
                Icon(
                  Icons.message,
                  color: COLOR_white_fff5f5f5,
                  size: Dimens.DIMENS_34,
                ),
                Text(
                  '10',
                  style: TextStyle(color: COLOR_white_fff5f5f5),
                ),
                 SizedBox(
                  height: Dimens.DIMENS_12,
                ),
                Icon(
                  Icons.reply,
                  color: COLOR_white_fff5f5f5,
                  size: Dimens.DIMENS_38,
                ),
                Text(
                  '10',
                  style: TextStyle(color: COLOR_white_fff5f5f5),
                ),
                 SizedBox(
                  height: Dimens.DIMENS_38,
                ),
                CircleAvatar()
              ],
            )),
        Positioned(
          bottom: 0,
          left: Dimens.DIMENS_12,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '@name',
                style: TextStyle(
                    color: COLOR_white_fff5f5f5, fontSize: Dimens.DIMENS_16),
              ),
              Text(
                "Lorem ipsum dolor sit amet",
                style: TextStyle(
                    color: COLOR_white_fff5f5f5, fontWeight: FontWeight.w300),
              ),
              SvgPicture.asset(Images.IC_MUSIC)
            ],
          ),
        )
      ]),
    );
  }
}



