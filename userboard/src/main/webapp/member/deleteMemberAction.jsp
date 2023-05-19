<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import = "java.sql.*" %>
<%@ page import = "java.net.*" %>
<%@ page import = "vo.*" %>
<%
	// 인코딩 처리
	request.setCharacterEncoding("UTF-8");
	
	// ANSI CODE	
	final String RESET = "\u001B[0m"; 
	final String BG_YELLOW = "\u001B[43m";
	final String BG_BLUE = "\u001B[44m";
	final String BG_PURPLE = "\u001B[45m";
	final String BG_CYAN = "\u001B[46m";
	final String CYAN = "\u001B[36m";
	
/* ------------------------------ 1. 컨트롤러 계층 ------------------------------ */
	
	// 요청분석 : 로그인 되어있을때만, 회원 탈퇴 가능
	
	// 에러메시지 담을 때 사용할 변수
	String msg = null;

	/* 세션 유효성 검사 */ 
	if(session.getAttribute("loginMemberId") == null){
		msg = URLEncoder.encode("로그인 후 이용해 주세요.", "utf-8");
		response.sendRedirect(request.getContextPath() + "/home.jsp");
		return;
	}
	// 유효성 검사 통과하면 변수에 저장
	String memberId = (String)session.getAttribute("loginMemberId");
	// 디버깅
	System.out.println(memberId + " <-- deleteMemberAction 변수 memberId");
	
	/* 요청값 유효성 검사 */
	// 요청값이 null이거나 공백이면 → 회원탈퇴 페이지 재요청 및 오류메세지 출력
	if (request.getParameter("memberPw") == null
		|| request.getParameter("memberPw").equals("")){
		msg = URLEncoder.encode("비밀번호를 입력해 주세요", "utf-8");
		response.sendRedirect(request.getContextPath() + "/member/deleteMemberForm.jsp?msg=" + msg);
		return;
	}
	// 유효성 검사 통과하면 변수에 저장
	String memberPw = request.getParameter("memberPw");
	// 디버깅
	System.out.println(memberPw + " <-- deleteMemberAction 변수 memberPw");
	
	/*------------------------------ 2. 모델 계층 -----------------------------*/

	// DB 연결
	String driver = "org.mariadb.jdbc.Driver";
	String dbUrl = "jdbc:mariadb://127.0.0.1:3306/userboard";
	String dbUser = "root";
	String dbPw = "java1234";
	Class.forName(driver);
	Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPw);
	
	// 쿼리 실행	
	String deleteMemberSql = "";
	PreparedStatement deleteMemberStmt = null;
	ResultSet deleteMemberRs = null;
	/*
		DELETE FROM member 
		WHERE member_id = ? 
		and member_pw = password(?)
	*/
	
	deleteMemberSql = "DELETE FROM member WHERE member_id = ? and member_pw = PASSWORD(?)";
	deleteMemberStmt = conn.prepareStatement(deleteMemberSql);
	// ? 2개
	deleteMemberStmt.setString(1, memberId);
	deleteMemberStmt.setString(2, memberPw);
	// 쿼리 디버깅
	System.out.println(deleteMemberStmt + " <-- deleteMemberAction deleteMemberStmt");
	
	// 영향받은 행의 개수
	int deleteMemberRow = 0;
	deleteMemberRow = deleteMemberStmt.executeUpdate();
	// 회원 탈퇴 성공 시 : 홈페이지 요청
	if(deleteMemberRow == 1){
		session.invalidate(); // 기존 세션을 지우고 갱신
		System.out.println(deleteMemberRow + " <-- deleteMemberAction deleteMemberRow : 탈퇴성공");
		msg = URLEncoder.encode("회원 탈퇴가 완료되었습니다", "utf-8");
		response.sendRedirect(request.getContextPath() + "/home.jsp?msg=" + msg);
		return;
	// 회원 탈퇴 실패 시 : 탈퇴 페이지 재요청 및 오류메세지 출력
	} else { // 위의 유효성검사에서도 안 걸렸는데 실패했다면, 비밀번호를 잘못 입력했기 때문일 것
		System.out.println(deleteMemberRow + " <-- updateAction updatePwRow : 탈퇴실패");
		msg = URLEncoder.encode("비밀번호를 정확하게 입력해 주세요", "utf-8");
		response.sendRedirect(request.getContextPath() + "/member/deleteMemberForm.jsp?msg=" + msg);
		return;
	}
	
%>