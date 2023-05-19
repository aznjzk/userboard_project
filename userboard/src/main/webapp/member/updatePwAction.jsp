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
	
	// 요청분석 : 로그인 되어있을때만, 비밀번호 변경 가능
		
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
	System.out.println(memberId + " <-- updatePwAction 변수 memberId");
	
	
	/* 요청값 유효성 검사 */
	// 요청값이 null이거나 공백이면 → 비밀번호 변경 페이지 재요청 및 오류메세지 출력
	if (request.getParameter("currentPw") == null
		|| request.getParameter("currentPw").equals("")){
		msg = URLEncoder.encode("현재 비밀번호를 입력해 주세요", "utf-8");
	} else if (request.getParameter("newPw") == null
		|| request.getParameter("newPw").equals("")){
		msg = URLEncoder.encode("새로운 비밀번호를 입력해 주세요", "utf-8");
		
	} else if (request.getParameter("newPwCheck") == null
		|| request.getParameter("newPwCheck").equals("")){
		msg = URLEncoder.encode("새로운 비밀번호를 다시 한번 입력해 주세요", "utf-8");
	} 
	if(msg != null) { // 위 ifelse문에 하나라도 해당된다
		response.sendRedirect(request.getContextPath() + "/member/updatePwForm.jsp?msg=" + msg);
		return;
	}
	// 유효성 검사 통과하면 변수에 저장
	String currentPw = request.getParameter("currentPw");
	String newPw = request.getParameter("newPw");
	String newPwCheck = request.getParameter("newPwCheck");
	// 디버깅
	System.out.println(currentPw + " <-- updatePwAction 변수 currentPw");
	System.out.println(newPw + " <-- updatePwAction 변수 newPw");
	System.out.println(newPwCheck + " <-- updatePwAction 변수 newPwCheck");
	
	
	if (currentPw.equals(newPw)) {
		msg = URLEncoder.encode("현재 비밀번호와 다른 비밀번호를 입력해 주세요", "utf-8");
		response.sendRedirect(request.getContextPath() + "/member/updatePwForm.jsp?msg=" + msg);
		return;
	}
	
	if (!newPwCheck.equals(newPw)){
		msg = URLEncoder.encode("새 비밀번호와 비밀번호 확인이 일치하지 않습니다", "utf-8");
		response.sendRedirect(request.getContextPath() + "/member/updatePwForm.jsp?msg=" + msg);
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
	
	// 쿼리 실행	
	String updatePwSql = "";
	PreparedStatement updatePwStmt = null;
	ResultSet updatePwRs = null;
	/*
		UPDATE member 
		SET member_pw = PASSWORD(?) 
		WHERE member_id = ? AND member_pw = PASSWORD(?)
	*/
	updatePwSql = "UPDATE member SET member_pw = PASSWORD(?) WHERE member_id = ? AND member_pw = PASSWORD(?)";
	updatePwStmt = conn.prepareStatement(updatePwSql);
	// ? 3개
	updatePwStmt.setString(1, newPw);
	updatePwStmt.setString(2, memberId);
	updatePwStmt.setString(3, currentPw);
	// 쿼리 디버깅
	System.out.println(updatePwStmt + " <-- updatePwAction updatePwStmt");
	
	// 영향받은 행의 개수
	int updatePwRow = 0;
	updatePwRow = updatePwStmt.executeUpdate();
	// 비밀번호 수정 성공 시 : 상세화면 재요청
	if(updatePwRow == 1){
		System.out.println(updatePwRow + " <-- updateAction updatePwRow : pw수정성공");
		msg = URLEncoder.encode("비밀번호 변경이 완료되었습니다", "utf-8");
		response.sendRedirect(request.getContextPath() + "/home.jsp?msg=" + msg);
		return;
	// 비밀번호 수정 실패 시 : 상세화면 재요청 및 오류메세지 출력
	} else { // 위의 ifelse문에도 안 걸렸는데 실패했다면, 현재 비밀번호를 잘못 입력했기 때문일 것
		System.out.println(updatePwRow + " <-- updateAction updatePwRow : pw수정실패");
		msg = URLEncoder.encode("현재 비밀번호를 정확하게 입력해 주세요", "utf-8");
		response.sendRedirect(request.getContextPath() + "/member/updatePwForm.jsp?msg=" + msg);
		return;
	}
%>