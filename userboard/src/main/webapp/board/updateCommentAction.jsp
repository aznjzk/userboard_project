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
	
	// 요청분석 : 로그인 되어있을때만, 댓글 수정 가능
	
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
	System.out.println(loginMemberId + " <-- updateCommentAction 변수 loginMemberId");
	
	/* 요청값 유효성 검사 */
	// 요청값이 null이거나 공백이면 → 댓글 페이지 재요청 및 오류메세지 출력
	if (request.getParameter("updateCommentContent") == null
		|| request.getParameter("updateCommentContent").equals("")
		|| request.getParameter("commentNo")== null
		|| request.getParameter("commentNo").equals("")){
		msg = URLEncoder.encode("댓글을 입력해주세요", "utf-8");
		response.sendRedirect(request.getContextPath() + "/board/updateCommentForm.jsp?boardNo="+request.getParameter("boardNo")+"&commentNo="+request.getParameter("commentNo")+"&msg=" + msg);
		return;
	}
	// 유효성 검사 통과하면 변수에 저장
	String updateCommentContent = request.getParameter("updateCommentContent");
	String commentNo = request.getParameter("commentNo");
	// 디버깅
	System.out.println(updateCommentContent + " <-- updateCommentAction 변수 updateCommentContent");
	System.out.println(commentNo + " <-- updateCommentAction 변수 commentNo");
	
	/*------------------------------ 2. 모델 계층 -----------------------------*/

	// DB 연결
	String driver = "org.mariadb.jdbc.Driver";
	String dbUrl = "jdbc:mariadb://127.0.0.1:3306/userboard";
	String dbUser = "root";
	String dbPw = "java1234";
	Class.forName(driver);
	Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPw);
	

	// 2-2) 댓글 수정 
	String updateCommentSql = "";
	PreparedStatement updateCommentStmt = null;
	ResultSet updateCommentRs  = null;
	
	/*
		UPDATE comment
		SET comment_content = ?
		WHERE member_id = ? AND comment_no = ?
	*/
	
	updateCommentSql = "UPDATE comment SET comment_content = ? , updatedate=now() WHERE member_id = ? AND comment_no = ?";
	updateCommentStmt = conn.prepareStatement(updateCommentSql);
	// ? 3개
	updateCommentStmt.setString(1, updateCommentContent);
	updateCommentStmt.setString(2, loginMemberId);
	updateCommentStmt.setString(3, commentNo);
	// 디버깅
	System.out.println(updateCommentStmt + " <-- updateComment updateCommentStmt"); 
	
	// 영향받은 행의 개수
	int updateCommentRow = updateCommentStmt.executeUpdate();
	
	// 댓글 수정 성공 시 
	if(updateCommentRow == 1){
		System.out.println(updateCommentRow + " <-- updateCommentAction updateCommentRow : 댓글수정성공");
		msg = URLEncoder.encode("댓글 수정에 성공하였습니다", "utf-8");
		response.sendRedirect(request.getContextPath() + "/board/boardOne.jsp?boardNo="+request.getParameter("boardNo")+"&msg=" + msg);
		return;
	
	// 댓글 수정 실패 시 
	} else { 
		System.out.println(updateCommentRow + " <-- updateAction updatePwRow : 댓글수정실패");
		msg = URLEncoder.encode("댓글 수정에 실패하였습니다", "utf-8");
		response.sendRedirect(request.getContextPath() + "/home.jsp?msg=" + msg);
		return;
	}
	
%>