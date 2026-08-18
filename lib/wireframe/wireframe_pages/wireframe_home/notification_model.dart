class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String type; // 'fee' | 'homework' | 'exam' | 'holiday' | 'general'
  final String time;
  bool isRead;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.time,
    this.isRead = false,
  });

  // API থেকে JSON আসলে এখানে পার্স (Parse) হবে (সব ধরণের সেফটি সহ)
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      type: json['type'] ?? 'general',
      time: json['time'] ?? '',
      isRead: json['is_read'] == true || json['is_read'] == 1 || json['is_read'] == '1',
    );
  }

  // মডেল ডেটাকে JSON-এ রূপান্তর করার জন্য
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type,
      'time': time,
      'is_read': isRead,
    };
  }

  // স্টেট ম্যানেজমেন্টের সুবিধার্থে অবজেক্ট কপি করার জন্য
  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    String? type,
    String? time,
    bool? isRead,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      time: time ?? this.time,
      isRead: isRead ?? this.isRead,
    );
  }
}