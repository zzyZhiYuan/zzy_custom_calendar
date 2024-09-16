library custom_calendar;

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

typedef CustomCalendarTapDayCallBack = void Function(DateTime day);
typedef CustomCalendarChangePageCallBack = void Function(int year, int month);

class CustomCalendar extends StatefulWidget {
  final List<DateTime> succeedData;
  final Color succeedPointerColor;
  final List<DateTime> warningData;
  final Color warningPointerColor;
  final Color activeTextColor;
  final Color normalTextColor;
  final Color activeBgColor;
  final CustomCalendarTapDayCallBack? onTapDay;
  final CustomCalendarChangePageCallBack? onPreChangePage;
  final CustomCalendarChangePageCallBack? onNextChangePage;

  const CustomCalendar({
    super.key,
    required this.succeedData,
    required this.warningData,
    this.succeedPointerColor = Colors.blue,
    this.warningPointerColor = Colors.red,
    this.activeTextColor = Colors.white,
    this.normalTextColor = Colors.black45,
    this.activeBgColor = Colors.blue,
    this.onTapDay,
    this.onPreChangePage,
    this.onNextChangePage,
  });

  @override
  State<CustomCalendar> createState() => _CustomCalendarState();
}

class _CustomCalendarState extends State<CustomCalendar> {
  bool isExpand = true;
  DateTime selectedDay = DateTime.now();
  DateTime now = DateTime.now();

  List<String> calendarTitle = ["一", "二", "三", "四", "五", "六", "日"];
  List<DateTime?> dateList0 = [];
  List<DateTime?> dateList1 = [];
  List<DateTime?> dateList2 = [];

  //当前页面上显示的年月
  int currentYear = 0;
  int currentMonth = 0;

  List<DateTime?> getDate({required int year, required int month}) {
    DateTime firstDate = DateTime(year, month, 1);
    //计算一号是星期几
    int firstWeek = firstDate.weekday;
    //月头补充空白天
    List<DateTime?> dateList = List.generate(firstWeek - 1, (index) => null);
    //计算此月份天数
    int days = DateTime(year, month + 1, 0).day;
    dateList.addAll(List.generate(days, (index) => DateTime(year, month, index + 1)));
    //当月最后一天的时间对象
    DateTime lastDate = DateTime(year, month, days);
    //计算最后一天是星期几
    int lastWeek = lastDate.weekday;
    //计算月尾需要补几天
    int lastPushNum = 7 - lastWeek;
    dateList.addAll(List.generate(lastPushNum, (index) => null));
    return dateList;
  }

  List<DateTime?> preMonthGetDate() {
    int year = currentYear;
    int month = currentMonth;
    month--;
    if (month == 0) {
      month = 12;
      year--;
    }
    return getDate(year: year, month: month);
  }

  List<DateTime?> currentMonthGetDate() {
    return getDate(year: currentYear, month: currentMonth);
  }

  List<DateTime?> nextMonthGetDate() {
    int year = currentYear;
    int month = currentMonth;
    month++;
    if (month > 12) {
      month = 1;
      year++;
    }
    return getDate(year: year, month: month);
  }

  //计算每一页的高度
  int initialPage = 1;

  double getPageHeight(double maxWidth) {
    //计算数据有多少行
    int lines = 0;
    if (initialPage == 0) {
      lines = dateList0.length ~/ 7;
    }
    if (initialPage == 1) {
      lines = dateList1.length ~/ 7;
    }
    if (initialPage == 2) {
      lines = dateList2.length ~/ 7;
    }
    double lineHeight = maxWidth / 7;
    return lines * lineHeight;
  }

  initData() {
    currentYear = now.year;
    currentMonth = now.month;
    dateList0 = preMonthGetDate();
    dateList1 = currentMonthGetDate();
    dateList2 = nextMonthGetDate();
  }

  pageChangeCallback(int currentPage, CarouselPageChangedReason reason) {
    if (currentPage == (initialPage + 1) % 3) {
      debugPrint("月份增加");
      currentMonth++;
      if (currentMonth > 12) {
        currentMonth = 1;
        currentYear++;
      }

      if (currentPage == 2) {
        dateList0 = nextMonthGetDate();
      }

      if (currentPage == 0) {
        dateList1 = nextMonthGetDate();
      }

      if (currentPage == 1) {
        dateList2 = nextMonthGetDate();
      }
      //向外部传递事件
      widget.onNextChangePage?.call(currentYear, currentMonth);
    } else {
      debugPrint("月份减少");
      currentMonth--;
      if (currentMonth == 0) {
        currentMonth = 12;
        currentYear--;
      }

      if (currentPage == 0) {
        dateList2 = preMonthGetDate();
      }

      if (currentPage == 1) {
        dateList0 = preMonthGetDate();
      }

      if (currentPage == 2) {
        dateList1 = preMonthGetDate();
      }
      //向外部传递事件
      widget.onPreChangePage?.call(currentYear, currentMonth);
    }

    setState(() {
      initialPage = currentPage;
    });
  }

  //展开和收起
  onTogglePanel() {
    isExpand = !isExpand;
    if (isExpand) {
      print("复原数据");

      setState(() {
        if (initialPage == 0) {
          dateList0 = currentMonthGetDate();
        }
        if (initialPage == 1) {
          dateList1 = currentMonthGetDate();
        }
        if (initialPage == 2) {
          dateList2 = currentMonthGetDate();
        }
      });
    } else {
      print("减少数据");

      List<DateTime?> dateList = [];
      if (initialPage == 0) {
        dateList = dateList0;
      }
      if (initialPage == 1) {
        dateList = dateList1;
      }
      if (initialPage == 2) {
        dateList = dateList2;
      }

      if (selectedDay.year == currentYear && selectedDay.month == currentMonth) {
        //当前选中日期在当前page上
        int index = 0;
        for (int i = 0; i < dateList.length; i++) {
          if (selectedDay.day == dateList[i]?.day) {
            index = i;
            break;
          }
        }
        dateList = getRowElements(dateList, index);
      } else {
        dateList = dateList.sublist(0, 7);
      }
      setState(() {
        if (initialPage == 0) {
          dateList0 = dateList;
        }
        if (initialPage == 1) {
          dateList1 = dateList;
        }
        if (initialPage == 2) {
          dateList2 = dateList;
        }
      });
    }
  }

  List<DateTime?> getRowElements(List<DateTime?> dateList, int index) {
    // 计算索引所在行的起始位置
    final int rowStartIndex = (index ~/ 7) * 7;
    // 使用 sublist() 方法获取索引所在行的7个元素
    final List<DateTime?> rowElements = dateList.sublist(rowStartIndex, rowStartIndex + 7);
    return rowElements;
  }

  @override
  void initState() {
    initData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, cons) {
      return Column(
        children: [
          Container(
            height: 40,
            width: double.infinity,
            color: Colors.white,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 16, right: 16),
            child: Text(
              "$currentYear年$currentMonth月",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
          ),
          Container(
            height: 40,
            color: Colors.grey[100],
            child: Row(
              children: List.generate(calendarTitle.length, (index) {
                return Expanded(
                  child: Center(
                    child: Text(
                      calendarTitle[index],
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: getPageHeight(cons.maxWidth),
            color: Colors.white,
            child: CarouselSlider(
              items: [
                buildCalendarBody(dateList0, cons),
                buildCalendarBody(dateList1, cons),
                buildCalendarBody(dateList2, cons),
              ],
              options: CarouselOptions(
                height: getPageHeight(cons.maxWidth),
                initialPage: initialPage,
                viewportFraction: 1,
                onPageChanged: pageChangeCallback,
                scrollPhysics: isExpand ? null : const NeverScrollableScrollPhysics(),
              ),
            ),
          ),
          GestureDetector(
            onTap: onTogglePanel,
            child: Container(
              height: 30,
              alignment: Alignment.center,
              color: Colors.white,
              child: isExpand
                  ? Image.asset(
                      "packages/custom_calendar/assets/images/un_expand.png",
                      width: 30,
                      fit: BoxFit.fitWidth,
                    )
                  : Image.asset(
                      "packages/custom_calendar/assets/images/expand.png",
                      width: 30,
                      fit: BoxFit.fitWidth,
                    ),
            ),
          )
        ],
      );
    });
  }

  Widget buildCalendarBody(List<DateTime?> dateList, BoxConstraints cons) {
    return Container(
      color: Colors.white,
      child: GridView.count(
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 7,
        children: List.generate(dateList.length, (index) {
          if (dateList[index] == null) {
            return Container();
          } else {
            return Stack(
              alignment: Alignment.bottomCenter,
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedDay = dateList[index]!;
                    });
                    widget.onTapDay?.call(dateList[index]!);
                  },
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: bgColor(dateList[index]!),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    margin: const EdgeInsets.all(6),
                    child: Text(
                      "${dateList[index]!.day}",
                      style: TextStyle(
                        color: textColor(dateList[index]!),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 10,
                  child: Container(
                      height: 5,
                      width: 5,
                      decoration: BoxDecoration(
                        color: pointerColor(dateList[index]!),
                        borderRadius: BorderRadius.circular(5),
                      )),
                ),
              ],
            );
          }
        }),
      ),
    );
  }

  //判断指示点样色
  Color pointerColor(DateTime day) {
    //如果存在于警告数组中是 warningPointerColor
    bool res1 = widget.warningData.any((date) => isSameDate(date, day));
    if (res1) {
      return widget.warningPointerColor;
    }
    //如果存在于成功数组中是 succeedPointerColor
    bool res2 = widget.succeedData.any((date) => isSameDate(date, day));
    if (res2) {
      //如果是当前选中的就得变成白色
      if (isSameDate(day, selectedDay)) {
        return Colors.white;
      } else {
        return widget.succeedPointerColor;
      }
    }
    return Colors.transparent;
  }

  //判断日期文本颜色
  Color textColor(DateTime day) {
    //如果是当前选中的就得变成白色
    if (isSameDate(day, selectedDay)) {
      return widget.activeTextColor;
    } else {
      return widget.normalTextColor;
    }
  }

  //判断日期背景颜色
  Color bgColor(DateTime day) {
    if (isSameDate(day, selectedDay)) {
      return widget.activeBgColor;
    }

    if (isSameDate(day, now)) {
      return widget.activeBgColor.withOpacity(0.3);
    }

    return Colors.transparent;
  }

  bool isSameDate(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month && date1.day == date2.day;
  }
}
