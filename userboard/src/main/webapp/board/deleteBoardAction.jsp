<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import = "java.sql.*"%>
<%@ page import = "java.net.*"%>
<%
	// 인코딩 처리
	request.setCharacterEncoding("utf-8");

	// ANSI CODE	
	final String RESET = "\u001B[0m"; 
	final String BG_CYAN = "\u001B[46m";
	final String CYAN = "\u001B[36m";
	final String BG_YELLOW = "\u001B[43m";
	
/* ------------------------------ 1. 컨트롤러 계층 ------------------------------ */

	// 요청분석 : 로그인이 되어있고, 게시글을 작성한 본인만 삭제 가능
	
	// 에러메시지 담을 때 사용할 변수
	String msg = null;

	/* 요청값 유효성 검사 */
	// 로그인 하지 않았거나, 작성자 본인이 아니거나, 게시글 번호가 넘어오지 않으면 삭제 할 수 없음 → 홈페이지 재요청
	// 세션값, 요청값 (boardNo, memberId)
	if(session.getAttribute("loginMemberId") == null
			|| request.getParameter("memberId") == null
			|| request.getParameter("memberId").equals("")
			|| request.getParameter("boardNo") == null
			|| request.getParameter("boardNo").equals("")) {
		msg = URLEncoder.encode("비정상적인 접근입니다","utf-8");
		response.sendRedirect(request.getContextPath()+"/home.jsp?msg=" + msg);
		return;
	}
	
	// 유효성 검사 통과하면 변수에 저장
	String sessionId = (String)session.getAttribute("loginMemberId");
	String memberId = request.getParameter("memberId");
	int boardNo = Integer.parseInt(request.getParameter("boardNo"));
	
	// sessionId와 memberId가 일치하는지 확인
	if(!sessionId.equals(memberId)) {
		msg = URLEncoder.encode("비정상적인 접근입니다","utf-8");
		response.sendRedirect(request.getContextPath()+"/home.jsp?msg=" + msg);
		return;
	}
	
	// 디버깅
	System.out.println(sessionId + " <-- deleteBoardAction sessionId");
	System.out.println(memberId + " <-- deleteBoardAction memberId");
	System.out.println(boardNo + " <-- deleteBoardAction boardNo");
	
/*------------------------------ 2. 모델 계층 -----------------------------*/
	
	// DB 연결
	String driver = "org.mariadb.jdbc.Driver";
	String dburl = "jdbc:mariadb://127.0.0.1:3306/userboard";
	String dbuser = "root";
	String dbpw = "java1234";
	Class.forName(driver);
	Connection conn = DriverManager.getConnection(dburl, dbuser, dbpw);
	
	// 쿼리 실행
	String sql = "DELETE FROM board WHERE board_no = ?";
	PreparedStatement stmt = conn.prepareStatement(sql);
	stmt.setInt(1, boardNo);
	System.out.println(stmt + " <-- deleteBoardAction stmt");
	
	// 영향받은 행의 개수
	int row = stmt.executeUpdate();
	// 게시글 삭제 성공 시 : 홈페이지 재요청
	if(row == 1) {
		System.out.println(row + " <-- deleteBoardAction 성공");
		msg = URLEncoder.encode("게시글 삭제에 성공하였습니다","utf-8");
		response.sendRedirect(request.getContextPath() + "/home.jsp?msg=" + msg);
		return;
	// 게시글 삭제 실패 시 : 해당 게시글 상세보기 페이지 재요청 및 오류메세지 출력
	} else {
		System.out.println(row + " <-- deleteBoardAction 실패");
		String boardMsg = URLEncoder.encode("게시글 삭제에 실패하였습니다 다시 시도해주세요","utf-8");
		response.sendRedirect(request.getContextPath() + "/board/boardOne.jsp?boardNo=" + boardNo + "&boardMsg=" + boardMsg);
		return;
	}
%>