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
	
	// 요청분석 : 로그인 되어있을때만, 댓글 지우기 가능
	
	// 에러메시지 담을 때 사용할 변수
	String msg = null;

	/* 세션 유효성 검사 */ 
	if(session.getAttribute("loginMemberId") == null){
		msg = URLEncoder.encode("로그인 후 이용해 주세요.", "utf-8");
		response.sendRedirect(request.getContextPath() + "/home.jsp?msg=" + msg);
		return;
	}
	// 유효성 검사 통과하면 변수에 저장
	String loginMemberId = (String)session.getAttribute("loginMemberId");
	// 디버깅
	System.out.println(loginMemberId + " <-- deleteCommentAction 변수 loginMemberId");
	
	System.out.println(request.getParameter("boardNo") + " <-- deleteCommentAction param boardNo"); 
	
	/*------------------------------ 2. 모델 계층 -----------------------------*/

	// DB 연결
	String driver = "org.mariadb.jdbc.Driver";
	String dbUrl = "jdbc:mariadb://127.0.0.1:3306/userboard";
	String dbUser = "root";
	String dbPw = "java1234";
	Class.forName(driver);
	Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPw);
	
	// 쿼리 실행	
	String deleteCommentSql = "";
	PreparedStatement deleteCommentStmt = null;
	ResultSet deleteCommentRs = null;
	/*
		DELETE FROM comment
		WHERE member_id = ?, comment_no = ? 
	*/
	
	deleteCommentSql = "DELETE FROM comment WHERE member_id = ? ";
	deleteCommentStmt = conn.prepareStatement(deleteCommentSql);
	// ? 1개
	deleteCommentStmt.setString(1, loginMemberId);
	// 디버깅
	System.out.println(deleteCommentStmt + " <-- deleteCommentAction deleteCommentStmt");
	
	// 영향받은 행의 개수
	int deleteCommentRow = 0;
	deleteCommentRow = deleteCommentStmt.executeUpdate();
	// 댓글 삭제 성공 시 
	if(deleteCommentRow == 1){
		System.out.println(deleteCommentRow + " <-- deleteCommentAction deleteCommentRow : 댓글삭제성공");
		msg = URLEncoder.encode("댓글 삭제가 완료되었습니다", "utf-8");
		response.sendRedirect(request.getContextPath() + "/home.jsp?msg=" + msg);
		return;
	// 댓글 삭제 실패 시 
	} else { // 위의 유효성검사에서도 안 걸렸는데 실패했다면, 댓글 작성자가 아니기 때문일 것??????????
		System.out.println(deleteCommentRow + " <-- updateAction updatePwRow : 댓글삭제실패");
		msg = URLEncoder.encode("댓글 작성자만 삭제 가능합니다", "utf-8");
		response.sendRedirect(request.getContextPath() + "/home.jsp?msg=" + msg);
		return;
	}
%>