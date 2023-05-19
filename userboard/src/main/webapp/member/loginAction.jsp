<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import = "java.sql.*" %>
<%@ page import = "java.net.*" %>
<%@ page import = "vo.*" %>
<%
	// 인코딩 처리
	request.setCharacterEncoding("UTF-8");

	// 요청분석 : 로그인 안 했을 때만, 로그인 가능
	
	// 에러메시지 담을 때 사용할 변수
	String msg = null;

	// session 유효성 검사
	if(session.getAttribute("loginMemberId") != null){
		msg = URLEncoder.encode("이미 로그인 되었습니다", "utf-8");
		response.sendRedirect(request.getContextPath() + "/home.jsp");
		return;
	}
	
	// 요청값 유효성 검사
	if(request.getParameter("memberId") == null 
			|| request.getParameter("memberId").equals("")) {
			msg = URLEncoder.encode("아이디를 입력해 주세요", "utf-8");
	} else if(request.getParameter("memberPw") == null 
			|| request.getParameter("memberPw").equals("")) {
			msg = URLEncoder.encode("비밀번호를 입력해 주세요", "utf-8");
	}
	if(msg != null) { // 위 ifelse문에 하나라도 해당된다
		response.sendRedirect(request.getContextPath()+"/home.jsp?msg="+msg);
		return;
	}
	
	// 요청값을 변수에 할당
	String memberId = request.getParameter("memberId");
	String memberPw = request.getParameter("memberPw");
	// 프라이빗으로 바꾸면 여기 바꿔야함
	Member paramMember = new Member();
	paramMember.setMemberId(memberId);
	paramMember.setMemberPw(memberPw);
	
	String driver = "org.mariadb.jdbc.Driver";
	String dburl = "jdbc:mariadb://127.0.0.1:3306/userboard";
	String dbuser = "root";
	String dbpw = "java1234";
	Class.forName(driver);
	Connection conn = null;
	PreparedStatement stmt = null;
	ResultSet rs = null;
	conn = DriverManager.getConnection(dburl, dbuser, dbpw);
	/*
		SELECT member_id memberId FROM member 
		WHERE member_id = ? AND member_pw = PASSWORD(?)"
	*/
	String sql = "SELECT member_id memberId FROM member WHERE member_id = ? AND member_pw = PASSWORD(?)";
	stmt = conn.prepareStatement(sql);
	// 프라이빗으로 바꾸면 여기 바꿔야함
	stmt.setString(1, paramMember.getMemberId());
	stmt.setString(2, paramMember.getMemberPw());
	System.out.println(stmt);
	rs = stmt.executeQuery();
	if(rs.next()) { // 로그인 성공시
		// 세션에 로그인 정보(memberId) 저장
		session.setAttribute("loginMemberId", rs.getString("memberId"));
		System.out.println("로그인 성공 세션정보 : " + session.getAttribute("loginMemberId"));
		msg = "";
	} else { // 로그인 실패시
		System.out.println("로그인 실패");
		msg = URLEncoder.encode("아이디 또는 패스워드를 잘못 입력하였습니다", "utf-8");
	}
	response.sendRedirect(request.getContextPath()+"/home.jsp?msg=" + msg);
%>