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

	// 요청분석 : 로그인이 되어있고, 게시글을 작성한 본인만 수정 가능
	
	// 에러메시지 담을 때 사용할 변수
	String msg = null;

	/* 요청값 유효성 검사 */
	// 로그인 하지 않았거나, 작성자 본인이 아니거나, 게시글 번호가 넘어오지 않으면 수정 할 수 없음 → 홈페이지 재요청
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
	
	// sessionId와 memberId가 일치하는지 확인
	if(!sessionId.equals(memberId)) {
		msg = URLEncoder.encode("비정상적인 접근입니다","utf-8");
		response.sendRedirect(request.getContextPath()+"/home.jsp?msg=" + msg);
		return;
	}
	
	// 일치하면 boardNo도 불러오기
	int boardNo = Integer.parseInt(request.getParameter("boardNo"));
	
	// 디버깅
	System.out.println(sessionId + " <-- updateBoardAction sessionId");
	System.out.println(memberId + " <-- updateBoardAction memberId");
	System.out.println(boardNo + " <-- updateBoardAction boardNo");
	
	// 나머지 요청값도 검사
	// 요청값이 null이거나 공백이면 → 게시글 수정 페이지 재요청 및 오류메세지 출력
	// localName, boardTitle, boardContent
	if(request.getParameter("localName") == null
			|| request.getParameter("localName").equals("")) {
		msg = URLEncoder.encode("카테고리를 선택해주세요","utf-8");
	} else if(request.getParameter("boardTitle") == null
			|| request.getParameter("boardTitle").equals("")) {
		msg = URLEncoder.encode("제목을 입력해주세요","utf-8");
	} else if(request.getParameter("boardContent") == null
			|| request.getParameter("boardContent").equals("")) {
		msg = URLEncoder.encode("내용을 입력해주세요","utf-8");
	}
	if(msg != null) {
		response.sendRedirect(request.getContextPath() + "/board/updateBoardForm.jsp?boardNo=" + boardNo + "&memberId=" + memberId + "&msg=" + msg);
		return;
	}
	
	// 유효성 검사를 통과하면 변수에 저장
	String localName = request.getParameter("localName");
	String boardTitle = request.getParameter("boardTitle");
	String boardContent = request.getParameter("boardContent");
	
	// 디버깅
	System.out.println(localName + " <-- updateBoardAction localName");
	System.out.println(boardTitle + " <-- updateBoardAction boardTitle");
	System.out.println(boardContent + " <-- updateBoardAction boardContent");
	
/*------------------------------ 2. 모델 계층 -----------------------------*/
	
	// DB 연결
	String driver = "org.mariadb.jdbc.Driver";
	String dburl = "jdbc:mariadb://127.0.0.1:3306/userboard";
	String dbuser = "root";
	String dbpw = "java1234";
	Class.forName(driver);
	Connection conn = DriverManager.getConnection(dburl, dbuser, dbpw);
	
	// 쿼리 실행
	String sql = "UPDATE board SET local_name = ?, board_title = ?, board_content = ?, updatedate = NOW() WHERE board_no = ?";
	PreparedStatement stmt = conn.prepareStatement(sql);
	stmt.setString(1, localName);
	stmt.setString(2, boardTitle);
	stmt.setString(3, boardContent);
	stmt.setInt(4, boardNo);
	
	// 영향받은 행의 개수
	int row = stmt.executeUpdate();
	// 게시글 수정 성공 시 : 해당 게시글 상세보기 페이지 재요청
	if(row == 1) {
		System.out.println(row + " <-- updateBoardAction 성공");
		String boardMsg = URLEncoder.encode("게시글 수정에 성공하였습니다","utf-8");
		response.sendRedirect(request.getContextPath() + "/board/boardOne.jsp?boardNo=" + boardNo + "&boardMsg=" + boardMsg);
		return;
	// 게시글 수정 실패 시 : 게시글 수정 화면 재요청 및 오류메세지 출력
	} else {
		System.out.println(row + " <-- updateBoardAction 실패");
		msg = URLEncoder.encode("게시글 수정에 실패하였습니다 다시 시도해주세요","utf-8");
		response.sendRedirect(request.getContextPath() + "/board/updateBoardForm.jsp?boardNo=" + boardNo + "&memberId=" + memberId + "&msg=" + msg);
		return;
	}
%>