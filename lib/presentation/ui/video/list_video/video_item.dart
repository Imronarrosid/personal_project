import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:personal_project/constant/color.dart';
import 'package:personal_project/constant/dimens.dart';
import 'package:personal_project/presentation/assets/images.dart';

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
                CircleAvatar(),
                const SizedBox(
                  height: Dimens.DIMENS_36,
                ),
                Icon(
                  Icons.favorite,
                  color: COLOR_white_fff5f5f5,
                  size: Dimens.DIMENS_36,
                ),
                Text(
                  '10',
                  style: TextStyle(color: COLOR_white_fff5f5f5),
                ),
                const SizedBox(
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
                const SizedBox(
                  height: Dimens.DIMENS_12,
                ),
                Icon(
                  Icons.reply,
                  color: COLOR_white_fff5f5f5,
                  size: Dimens.DIMENS_36,
                ),
                Text(
                  '10',
                  style: TextStyle(color: COLOR_white_fff5f5f5),
                ),
                const SizedBox(
                  height: Dimens.DIMENS_36,
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
