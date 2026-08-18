import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_fontstyle.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_color.dart';
import 'notification_controller.dart';
import 'notification_model.dart';
import 'page_hero_header.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final NotificationController nCtrl = Get.find<NotificationController>();

    return HeroScaffold(
      backgroundColor: const Color(0xffF5F6FC),
      hero: PageHeroHeader(
        theme: PageHeroTheme.notifications,
        title: 'Notifications',
        subtitle: 'Stay updated with your activities',
        onBack: () => Navigator.pop(context),
        actions: [
          Obx(() {
            final hasUnread = nCtrl.unreadCount > 0;
            return hasUnread
                ? Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: InkWell(
                onTap: () => nCtrl.markAllAsRead(),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Mark all read',
                    style: sansproRegular.copyWith(fontSize: 12, color: Colors.white),
                  ),
                ),
              ),
            )
                : const SizedBox();
          }),
        ],
      ),
      body: Obx(() {
        if (nCtrl.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: WireframeColor.appcolor));
        }

        if (nCtrl.hasError.value) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                nCtrl.errorMessage.value,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.redAccent, fontSize: 14),
              ),
            ),
          );
        }

        if (nCtrl.notifications.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.notifications_off_outlined,
                  size: 64,
                  color: WireframeColor.textgray.withValues(alpha: 0.4),
                ),
                const SizedBox(height: 16),
                Text(
                  'No notifications yet',
                  style: sansproRegular.copyWith(fontSize: 16, color: WireframeColor.textgray),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          color: WireframeColor.appcolor,
          onRefresh: () async {
            // মেথডের নাম সংশোধন করা হলো
            nCtrl.refresh();
          },
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: w / 26, vertical: 10),
            itemCount: nCtrl.notifications.length,
            itemBuilder: (context, index) {
              final notif = nCtrl.notifications[index];
              return _NotificationCard(
                notification: notif,
                onTap: () {
                  if (!notif.isRead) {
                    nCtrl.markAsRead(notif.id);
                  }
                },
              );
            },
          ),
        );
      }),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;

  const _NotificationCard({
    required this.notification,
    required this.onTap,
  });

  IconData get _icon {
    switch (notification.type.toLowerCase()) {
      case 'fee':
        return Icons.account_balance_wallet_outlined;
      case 'homework':
        return Icons.assignment_outlined;
      case 'exam':
        return Icons.school_outlined;
      case 'holiday':
        return Icons.celebration_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  Color get _color {
    switch (notification.type.toLowerCase()) {
      case 'fee':
        return const Color(0xffE2136E);
      case 'homework':
        return const Color(0xff1A56DB);
      case 'exam':
        return const Color(0xff7030A0);
      case 'holiday':
        return const Color(0xff2E7D32);
      default:
        return WireframeColor.appcolor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: h / 60),
        decoration: BoxDecoration(
          color: notification.isRead ? Colors.white : _color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: notification.isRead ? Colors.transparent : _color.withValues(alpha: 0.25),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: w / 26, vertical: h / 70),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(_icon, color: _color, size: 22),
              ),
              SizedBox(width: w / 36),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: (notification.isRead ? sansproRegular : sansproSemibold)
                                .copyWith(fontSize: 14.5, color: WireframeColor.black),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(color: _color, shape: BoxShape.circle),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.message,
                      style: sansproRegular.copyWith(fontSize: 13, color: WireframeColor.textgray),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      notification.time,
                      style: sansproRegular.copyWith(
                        fontSize: 11,
                        color: WireframeColor.textgray.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}