<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import = "java.sql.*" %>
<%@ page import = "java.net.*" %>
<%@ page import = "vo.*" %>
<%
/* ------------------------------ 1. 컨트롤러 계층 ------------------------------ */
	
	// 요청분석 : 로그인 되어있을때만, 지역 카테고리 수정 가능
	
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
	System.out.println(memberId + " <-- updateMemberAction 변수 memberId");
	
	
	/* 요청값 유효성검사 */
	if(request.getParameter("currentLocalName") == null 
		|| request.getParameter("currentLocalName").equals("")) {
		msg = URLEncoder.encode("지역을 선택해 주세요", "utf-8");
	} else if (request.getParameter("updateLocalName") == null 
		|| request.getParameter("updateLocalName").equals("")) {
		msg = URLEncoder.encode("지역을 입력해 주세요", "utf-8");
	}
	if(msg != null) {
		response.sendRedirect(request.getContextPath()+"/local/updateLocalForm.jsp?msg=" + msg);
		return;
	}
	
	// 유효성 검사 통과하면 변수에 저장
	String currentLocalName = request.getParameter("currentLocalName");
	String updateLocalName = request.getParameter("updateLocalName");
	// 디버깅
	System.out.println(currentLocalName + " <-- updateLocalAction currentLocalName");
	System.out.println(updateLocalName + " <-- updateLocalAction updateLocalName");
	
	if (currentLocalName.equals(updateLocalName)) {
		msg = URLEncoder.encode("기존과 다른 지역을 입력해 주세요", "utf-8");
		response.sendRedirect(request.getContextPath() + "/local/updateLocalForm.jsp?msg=" + msg);
		return;
	}
	
	/*------------------------------ 2. 모델 계층 -----------------------------*/

	// DB 연결
	String driver = "org.mariadb.jdbc.Driver";
	String dbUrl = "jdbc:mariadb://127.0.0.1:3306/userboard";
	String dbUser = "root";
	String dbPw = "java1234";
	Class.forName(driver);
	Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPw);
	
	
	// 지역 이름을 수정하는 쿼리	
	String updateLocalSql = "";
	PreparedStatement updateLocalStmt = null;
	ResultSet updateLocalRs = null;
	/*
		UPDATE local
		SET local_name = ?
		WHERE local_name = ?
	*/
	updateLocalSql = "UPDATE local SET local_name = ? WHERE local_name = ?";
	updateLocalStmt = conn.prepareStatement(updateLocalSql);
	// ? 2개
	updateLocalStmt.setString(1, updateLocalName);
	updateLocalStmt.setString(2, currentLocalName);
	// 디버깅	
	System.out.println(updateLocalStmt + " <-- updateLocalAction updateLocalStmt");
	
	// 영향받은 행의 개수
	int updateLocalRow = 0;
	updateLocalRow = updateLocalStmt.executeUpdate();
	// 지역 수정 성공 시 : 지역 카테고리 편집 페이지 재요청
	if(updateLocalRow == 1){
		System.out.println(updateLocalRow + " <-- updateLocalRow : 지역 수정 성공");
		msg = URLEncoder.encode("지역 수정이 완료되었습니다", "utf-8");
		response.sendRedirect(request.getContextPath() + "/local/category.jsp?msg=" + msg);
		return;
	// 지역 수정 실패 시 : 지역 수정페이지 재요청
	} else { 
		System.out.println(updateLocalRow + " <-- updateLocalRow : 지역 수정 실패");
		msg = URLEncoder.encode("지역 수정에 실패하였습니다", "utf-8");
		response.sendRedirect(request.getContextPath() + "/local/updateLocalForm.jsp?msg=" + msg);
		return;
	}
%>