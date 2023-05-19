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
	
	// 요청분석 : 로그인 안 했을 때만, 가입 가능
	 
	// 에러메시지 담을 때 사용할 변수
	String msg = null;

	/* 세션 유효성 검사 */
	if(session.getAttribute("loginMemberId") != null){
		msg = URLEncoder.encode("이미 로그인 되었습니다", "utf-8");
		response.sendRedirect(request.getContextPath() + "/home.jsp");
		return;
	}
	
	/* 요청값 유효성검사 */
	if(request.getParameter("memberId") == null 
			|| request.getParameter("memberId").equals("")) {
			msg = URLEncoder.encode("아이디를 입력해 주세요", "utf-8");
	} else if(request.getParameter("memberPw") == null 
			|| request.getParameter("memberPw").equals("")) {
			msg = URLEncoder.encode("비밀번호를 입력해 주세요", "utf-8");
	} else if(request.getParameter("memberPw2") == null 
			|| request.getParameter("memberPw2").equals("")) {
			msg = URLEncoder.encode("비밀번호를 다시 한번 입력해 주세요", "utf-8");
	}
	if(msg != null) { // 위 ifelse문에 하나라도 해당된다
		response.sendRedirect(request.getContextPath()+"/member/insertMemberForm.jsp?msg="+msg);
		return;
	}
	
	// 유효성 검사 통과하면 요청값을 변수에 저장
	String memberId = request.getParameter("memberId");
	String memberPw = request.getParameter("memberPw");
	String memberPw2 = request.getParameter("memberPw2");
	// 디버깅
	System.out.println(memberId + " <--insertMemberAction memberId");
	System.out.println(memberPw + " <--insertMemberAction memberPw");
	System.out.println(memberPw2 + " <--insertMemberAction memberPw2");
	
	// 비밀번호 일치하는 지 검사
	if(!memberPw.equals(memberPw2)) {
		msg = URLEncoder.encode("비밀번호가 일치하지 않습니다", "utf-8");
		response.sendRedirect(request.getContextPath() + "/member/insertMemberForm.jsp?msg="+ msg);
		return;
	}
	
	// DB 연결
	String driver = "org.mariadb.jdbc.Driver";
	String dburl = "jdbc:mariadb://127.0.0.1:3306/userboard";
	String dbuser = "root";
	String dbpw = "java1234";
	Class.forName(driver);
	Connection conn = null;
	PreparedStatement stmt1 = null;
	PreparedStatement stmt2 = null;
	ResultSet rs = null;
	conn = DriverManager.getConnection(dburl, dbuser, dbpw);
	
	// 쿼리1 생성 → id 중복검사 
	String sql1 = "SELECT COUNT(*) FROM member WHERE member_id = ?";
	stmt1 = conn.prepareStatement(sql1);
	// ? 1개
	stmt1.setString(1, memberId);
	// 디버깅
	System.out.println(stmt1 + " <-- insertMemberAction stmt1");
	rs = stmt1.executeQuery();
	
	// DB 테이블에 중복된 id가 있는지 개수 확인
	int dbid = 0;
	if(rs.next()) {
		// 해당 id의 개수를 변수에 저장 → 0일 경우 중복 없음 
		dbid = rs.getInt("count(*)");
	}
	
	// 0보다 클 경우 : 같은 id가 이미 존재한다는 뜻 → 회원가입 페이지 재요청
	if(dbid > 0) {
		System.out.println(dbid + " <- insertMemberAction 중복된 아이디의 개수");
		msg = URLEncoder.encode("이미 사용 중인 아이디입니다", "utf-8");
		response.sendRedirect(request.getContextPath() + "/member/insertMemberForm.jsp?msg=" + msg);
		return;
	} else {
		System.out.println("insertMemberAction 중복된 아이디 없음");
	}
	
	/*
	-- 입력시 member_pw값 암호화 시켜서 입력
	INSERT INTO member(member_id, member_pw, createdate, updatedate)
	VALUES('admin', PASSWORD('1234'), NOW(), NOW());
	*/
	
	// 쿼리2 생성 → 회원 정보 추가
	String sql2 = "INSERT INTO member(member_id, member_pw, createdate, updatedate) VALUES(?, PASSWORD(?), NOW(), NOW())";
	stmt2 = conn.prepareStatement(sql2);
	// ? 2개
	stmt2.setString(1, memberId);
	stmt2.setString(2, memberPw);
	// 디버깅
	System.out.println(stmt2 + " <-- insertMemberAction stmt2");
	
	// 데이터베이스에서 영향받은 행 수 반환
	int row = stmt2.executeUpdate();
	// 디버깅
	System.out.println(row + " <-- insertMemberAction row");
	
	// 입력행이 0행이면,
	if(row == 0) {		// 회원가입 페이지 재요청 
		response.sendRedirect(request.getContextPath()+"/member/insertMemberForm.jsp");
		return;
	} else {			// 회원가입이 완료되면 홈으로 돌아가기
		msg = URLEncoder.encode("회원가입이 완료되었습니다", "utf-8");
		response.sendRedirect(request.getContextPath()+"/home.jsp?msg=" + msg);
	}
%>