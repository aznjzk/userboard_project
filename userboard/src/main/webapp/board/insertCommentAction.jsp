<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import = "java.sql.*" %>
<%@ page import = "java.net.*"%>
<%
	// 인코딩 처리
	response.setCharacterEncoding("UTF-8");

	// ANSI CODE	
	final String RESET = "\u001B[0m"; 
	final String BG_CYAN = "\u001B[46m";
	final String CYAN = "\u001B[36m";
	final String BG_YELLOW = "\u001B[43m";
	
/* ------------------------------ 1. 컨트롤러 계층 ------------------------------ */
	
	// 요청분석 : 댓글입력 → DB에 저장
	
	/* 세션 유효성 검사 */ 
	// 로그인 하지 않으면 댓글입력 할 수 없음 → 홈페이지 재요청
	if(session.getAttribute("loginMemberId") == null){
		response.sendRedirect(request.getContextPath() + "/home.jsp");
		return;
	}
	
	/* 현재 파라미터값 디버깅 */
	System.out.println(CYAN + request.getParameter("boardNo") + " <- insertCommentAction param boardNo" + RESET);
	System.out.println(CYAN + request.getParameter("memberId") + " <- insertCommentAction param memberId" + RESET);
	System.out.println(CYAN + request.getParameter("commentContent") + " <- insertCommentAction param commentContent" + RESET);
	
	/* 요청값 유효성 검사 */
	// boardNo, memberId
	if(request.getParameter("boardNo") == null
			|| request.getParameter("boardNo").equals("")
			|| request.getParameter("memberId") == null
			|| request.getParameter("memberId").equals("")) {
		response.sendRedirect(request.getContextPath() + "/home.jsp");
		return;
	}
	// 유효성 검사를 통과하면 변수에 저장(형변환)
	int boardNo = Integer.parseInt(request.getParameter("boardNo"));
	String memberId = request.getParameter("memberId");
		
	// commentContent
	if(request.getParameter("commentContent") == null
			|| request.getParameter("commentContent").equals("")) {
		String msg = URLEncoder.encode("댓글 내용을 입력해주세요!", "utf-8");
		response.sendRedirect(request.getContextPath() + "/board/boardOne.jsp?boardNo=" + boardNo + "&msg=" + msg);
		return;
	}
	// 유효성 검사를 통과하면 변수에 저장
	String commentContent = request.getParameter("commentContent");
	
	
	/* 요청 이후 파라미터값 디버깅 */
	System.out.println(BG_CYAN + boardNo + " <-- insertCommentAction 변수 boardNo" + RESET);
	System.out.println(BG_CYAN + memberId + " <-- insertCommentAction 변수 memberId" + RESET);
	System.out.println(BG_CYAN + commentContent + " <-- insertCommentAction 변수 commentContent" + RESET);
	
	/*------------------------------ 2. 모델 계층 -----------------------------*/

	// DB 연결
	String driver = "org.mariadb.jdbc.Driver";
	String dbUrl = "jdbc:mariadb://127.0.0.1:3306/userboard";
	String dbUser = "root";
	String dbPw = "java1234";
	Class.forName(driver);
	Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPw);
	
	// 쿼리 실행
	String commentSql = "";
	PreparedStatement commentStmt = null;
	/*
		INSERT INTO COMMENT (board_no, comment_content, member_id, createdate, updatedate)
		VALUES(?, ?, ?, NOW(), NOW())
	*/
	commentSql = "INSERT INTO COMMENT (board_no, comment_content, member_id, createdate, updatedate) VALUES(?, ?, ?, NOW(), NOW())";
	// ? 4개
	commentStmt = conn.prepareStatement(commentSql);
	commentStmt.setInt(1, boardNo);
	commentStmt.setString(2, commentContent);
	commentStmt.setString(3, memberId);
	// 쿼리 디버깅
	System.out.println(BG_YELLOW + commentStmt + " <-- insertCommentAction commentStmt" + RESET);
	
	// 영향받은 행의 개수
	int commentRow = 0; 
	commentRow = commentStmt.executeUpdate();
	
	// 댓글 입력 성공 시 : 상세화면 재요청
	if(commentRow == 1){
		System.out.println(commentRow + " <-- insertCommentAction commentRow : 댓글입력성공");
		response.sendRedirect(request.getContextPath() + "/board/boardOne.jsp?boardNo=" + boardNo);
		return;
	// 댓글 입력 실패 시 : 상세화면 재요청 및 오류메세지 출력
	} else{
		System.out.println(commentRow + " <-- insertCommentAction commentRow : 댓글입력실패");
		String msg = URLEncoder.encode("댓글이 등록되지 않았습니다", "utf-8");
		response.sendRedirect(request.getContextPath() + "/board/boardOne.jsp?boardNo=" + boardNo + "&msg=" + msg);
		return;
	}
%>