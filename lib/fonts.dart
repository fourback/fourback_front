import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppFonts {
  // 제목 스타일 (예: 게시글 제목)
  static TextStyle title = GoogleFonts.roboto(
    fontSize: 16.0,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );

  // 부제목 스타일 (예: 작성자 이름)
  static TextStyle subtitle = GoogleFonts.inter(
    fontSize: 14.0,
    fontWeight: FontWeight.w600,
    color: Colors.black,
  );

  // 작은 텍스트 스타일 (예: 학교 정보)
  static TextStyle smallText = GoogleFonts.inter(
    fontSize: 12.0,
    fontWeight: FontWeight.w500,
    color: Colors.black,
  );

  // 회색 텍스트 (예: 날짜 표시)
  static TextStyle greyText = GoogleFonts.inter(
    fontSize: 14.0,
    fontWeight: FontWeight.w600,
    color: Colors.grey,
  );

  // 버튼 텍스트 스타일 (예: 필터 버튼)
  static TextStyle buttonText = GoogleFonts.roboto(
    fontSize: 14.0,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  // AppBar 제목 스타일
  static TextStyle appBarTitle = GoogleFonts.inter(
    fontSize: 20.0,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );

  // 필터 버튼 스타일
  static TextStyle filterButton = GoogleFonts.roboto(
    fontSize: 14.0,
    fontWeight: FontWeight.w500,
    color: Colors.white,
  );
}