import 'package:vivido/local_storage/local_project_service.dart';
import 'package:vivido/screen/dashboard_screen.dart';
import 'package:vivido/utils/AppColors.dart';
import 'package:vivido/utils/AppConstant.dart';
import 'package:vivido/utils/AppFunctions.dart';
import 'package:vivido/utils/AppWidget.dart';
import 'package:vivido/widgetsProperty/comman_property_view.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../main.dart';

class WelcomeScreenComponent extends StatefulWidget {
  static String tag = '/WelcomeScreenComponent';
  final List<RecentProjectEntry> recentProjectList;
  final Future<void> Function() onUpdate;

  WelcomeScreenComponent({required this.recentProjectList, required this.onUpdate});

  @override
  WelcomeScreenComponentState createState() => WelcomeScreenComponentState();
}

class WelcomeScreenComponentState extends State<WelcomeScreenComponent> {
  Future<void> openProject(RecentProjectEntry entry) async {
    try {
      final project = await locator<LocalProjectService>().openFromPath(entry.path);
      appStore.loadProject(project);
      appStore.selectedMenu = WIDGETS_INDEX;
      DashboardScreen().launch(context, isNewTask: true);
    } catch (e) {
      getToast(e.toString());
      await locator<LocalProjectService>().removeRecent(entry.path);
      await widget.onUpdate();
    }
  }

  Future<void> forgetProject(RecentProjectEntry entry) async {
    await locator<LocalProjectService>().removeRecent(entry.path);
    await widget.onUpdate();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int mainAxisCount = 4;
        if (constraints.maxWidth <= 1300) {
          mainAxisCount = 3;
        }
        return GridView.builder(
          physics: ScrollPhysics(),
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemCount: widget.recentProjectList.length,
          itemBuilder: (context, index) {
            RecentProjectEntry entry = widget.recentProjectList[index];
            return HoverWidget(
              builder: (context, isHovering) {
                return AnimatedContainer(
                  duration: commonAnimationDuration,
                  child: Container(
                    decoration: boxDecorationWithRoundedCorners(
                        backgroundColor: (isHovering)
                            ? appStore.isDarkMode
                                ? darkModeSecondaryBackgroundDark
                                : menuMouseHoverColor
                            : appStore.isDarkMode
                                ? darkModePrimaryColorBackground
                                : Colors.white,
                        borderRadius: BorderRadius.circular(COMMON_CARD_BORDER_RADIUS),
                        boxShadow: [
                          (isHovering || appStore.isDarkMode) ? BoxShadow(color: Colors.grey.withValues(alpha: 0.2)) : commonCardBoxShadow(),
                        ],
                        border: Border.all(color: (isHovering && appStore.isDarkMode) ? btnBackgroundColor : Colors.transparent)),
                    child: Padding(
                      padding: EdgeInsets.only(left: 16, right: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Text(entry.name.validate(), style: primaryTextStyle(size: 18)).expand(),
                              8.width,
                              deleteIcon(context).onTap(() async {
                                deleteConfirmationDialog(
                                  context: context,
                                  messageText: language!.areYouSureWantToDeleteProject,
                                  onAccept: () async {
                                    finish(context);
                                    await forgetProject(entry);
                                  },
                                );
                              }),
                            ],
                          ),
                          8.height,
                          Text('${language!.lastEdited} : ${getLastLogin(updateTimeString: entry.lastOpenedAt.toString())}', style: secondaryTextStyle(size: 12)),
                        ],
                      ),
                    ),
                  ).onTap(() {
                    openProject(entry);
                  }),
                );
              },
            );
          },
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: mainAxisCount,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            childAspectRatio: 3.5,
          ),
        );
      },
    );
  }
}
