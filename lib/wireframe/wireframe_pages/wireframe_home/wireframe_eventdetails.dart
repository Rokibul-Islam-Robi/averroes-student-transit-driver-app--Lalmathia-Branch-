import 'package:flutter/material.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_fontstyle.dart';
// আপনার নতুন প্রজেক্টের নাম অনুযায়ী ইম্পোর্ট পাথ চেঞ্জ করা হয়েছে
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_icons.dart';
import '../../wireframe_gloabelclass/wireframe_color.dart';
import 'page_background.dart'; // প্রথম কোডের কাস্টম ব্যাকগ্রাউন্ড ও অ্যাপবার অক্ষুণ্ণ রাখা হয়েছে

class WireframeEventDetails extends StatefulWidget {
  const WireframeEventDetails({super.key});

  @override
  State<WireframeEventDetails> createState() => _WireframeEventDetailsState();
}

class _WireframeEventDetailsState extends State<WireframeEventDetails> {
  late double height;
  late double width;

  @override
  Widget build(BuildContext context) {
    // MediaQuery এর সাইজ নেওয়া (কোড ১ এর স্ট্যান্ডার্ড অনুযায়ী)
    final size = MediaQuery.of(context).size;
    height = size.height;
    width = size.width;

    // অ্যাপবার এবং স্ট্যাটাস বারের টোটাল হাইট হিসাব করা
    final topPadding = MediaQuery.of(context).padding.top;
    final totalAppBarHeight = kToolbarHeight + topPadding;

    return Scaffold(
      extendBodyBehindAppBar: true,
      // আপনার কাস্টম অ্যাপবার যা ব্যাক বাটন অটোমেটিক হ্যান্ডেল করে
      appBar: const PageAppBar(
        title: 'Event Details',
      ),
      body: PageBackground(
        category: PageCategory.holiday,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // অ্যাপবারের নিচে কন্টেন্ট পুশ করার জন্য স্পেসার
              SizedBox(height: totalAppBarHeight + 16),

              // ইভেন্ট ইমেজ বা ব্যানার এরিয়া (কোড ১ এর সুন্দর রাউন্ডেড কর্নারসহ)
              Container(
                height: height / 2.2,
                width: width,
                decoration: BoxDecoration(
                  color: WireframeColor.textgray,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),

              // ডিটেইলস কন্টেন্ট এরিয়া
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: width / 36,
                  vertical: height / 60,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // সময় এবং তারিখ
                    Row(
                      children: [
                        Image.asset(
                          WireframePngimage.ictime,
                          height: height / 46,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          " 12 Jan 21, 09:00 AM",
                          style: sansproSemibold.copyWith(
                            fontSize: 13,
                            color: WireframeColor.appcolor,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: height / 80),

                    // ইভেন্ট টাইটেল
                    Text(
                      "Rhyme Time: A Night of Poetry",
                      style: sansproSemibold.copyWith(fontSize: 16),
                    ),
                    SizedBox(height: height / 80),

                    // ইভেন্ট ডেসক্রিপশন (স্ক্রোলিং সুবিধাসহ)
                    Text(
                      "April is also National Poetry Month. Now there is a great theme for a fun family night Combine poetry readings by students and adults. Invite guest readers and poets. Sell a book of student poems as a fund-raiser. Display portfolios of students best poetry. Present your oldest students in a poetry slam competitions, like teacher Brenda Dyck staged with her students(see the Education World article, A Poetry Slam Cures Midwinter Blahs). For more ideas for great poetry writing activities, don't miss Education World's special Poetry Month archive.",
                      style: sansproRegular.copyWith(
                        fontSize: 13,
                        color: WireframeColor.textgray,
                        height: 1.4,
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