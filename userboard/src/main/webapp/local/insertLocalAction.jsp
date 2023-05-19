<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import = "java.sql.*" %>
<%@ page import = "java.net.*" %>
<%@ page import = "vo.*" %>
<%
/* ------------------------------ 1. 컨트롤러 계층 ------------------------------ */
	
	// 요청분석 : 로그인 되어있을때만, 지역 카테고리 추가 가능
	
	// 인코딩 처리
	request.setCharacterEncoding("UTF-8");

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
	
	
	/* 요청값 유효성검사 */
	if(request.getParameter("insertLocalName") == null 
			|| request.getParameter("insertLocalName").equals("")) {
			msg = URLEncoder.encode("지역을 입력해 주세요", "utf-8");
		response.sendRedirect(request.getContextPath()+"/local/insertLocalForm.jsp?msg=" + msg);
		return;
	}
	
	// 유효성 검사 통과하면 변수에 저장
	String insertLocalName = request.getParameter("insertLocalName");
	// 디버깅
	System.out.println(insertLocalName + " <-- insertLocalAction insertLocalName");
	
	/*------------------------------ 2. 모델 계층 -----------------------------*/

	// DB 연결
	String driver = "org.mariadb.jdbc.Driver";
	String dbUrl = "jdbc:mariadb://127.0.0.1:3306/userboard";
	String dbUser = "root";
	String dbPw = "java1234";
	Class.forName(driver);
	Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPw);
	
	// 1) 지역이름이 이미 있는지 확인하기 위한 쿼리
	String confirmLocalSql = "";
	PreparedStatement confirmLocalStmt = null;
	ResultSet confirmLocalRs = null;
	
	confirmLocalSql = "select count(*) cnt from local where local_name = ?";
	confirmLocalStmt = conn.prepareStatement(confirmLocalSql);
	// ? 1개
	confirmLocalStmt.setString(1, insertLocalName);
	// 쿼리 디버깅
	System.out.println(confirmLocalStmt + " <-- insertLocalAction confirmLocalStmt");
	
	// 쿼리 실행 후 결과값 저장
	confirmLocalRs = confirmLocalStmt.executeQuery();
	int cnt = 0;
	if(confirmLocalRs.next()){
		cnt = confirmLocalRs.getInt("cnt");
	}
	
	// cnt가 0이 아니면 (=이미 있는 지역 이름이면) redirect
	if(cnt != 0){
		msg = URLEncoder.encode("이미 존재하는 지역이름 입니다.", "utf-8");
		response.sendRedirect(request.getContextPath() + "/local/insertLocalForm.jsp?msg=" + msg);
		return;
	}
	
	// 지역 이름을 추가하는 쿼리	
	String insertLocalSql = "";
	PreparedStatement insertLocalStmt = null;
	ResultSet insertLocalRs = null;
	/*
		INSERT INTO local(local_name, createdate, updatedate)
		VALUES(?, NOW(), NOW())
	*/
	insertLocalSql = "INSERT INTO local(local_name, createdate, updatedate) VALUES(?, NOW(), NOW())";
	insertLocalStmt = conn.prepareStatement(insertLocalSql);
	// ? 1개
	insertLocalStmt.setString(1, insertLocalName);
	// 디버깅
	System.out.println(insertLocalStmt + " <-- insertLocalAction insertLocalStmt");
	
	// 영향받은 행의 개수
	int insertLocalRow = 0;
	insertLocalRow = insertLocalStmt.executeUpdate();
	// 지역 추가 성공 시 : 지역 카테고리 편집 페이지 재요청
	if(insertLocalRow == 1){
		System.out.println(insertLocalRow + " <-- insertLocalRow : 지역 추가 성공");
		msg = URLEncoder.encode("지역 추가가 완료되었습니다", "utf-8");
		response.sendRedirect(request.getContextPath() + "/local/category.jsp?msg=" + msg);
		return;
	// 지역 추가 실패 시 : 지역 추가페이지 재요청
	} else { 
		System.out.println(insertLocalRow + " <-- insertLocalRow : 지역 추가 실패");
		msg = URLEncoder.encode("지역 추가에 실패하였습니다", "utf-8");
		response.sendRedirect(request.getContextPath() + "/local/insertLocalForm.jsp?msg=" + msg);
		return;
	}
%>