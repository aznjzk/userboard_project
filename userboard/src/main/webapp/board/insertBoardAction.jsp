<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import = "java.sql.*"%>
<%@ page import = "java.net.*"%>
<%@ page import = "vo.*"%>
<%
	// 인코딩 처리
	request.setCharacterEncoding("utf-8");

	// ANSI CODE	
	final String RESET = "\u001B[0m"; 
	final String BG_CYAN = "\u001B[46m";
	final String CYAN = "\u001B[36m";
	final String BG_YELLOW = "\u001B[43m";
	
/* ------------------------------ 1. 컨트롤러 계층 ------------------------------ */

	// 요청분석 : 로그인 한 사람만 게시글 입력 가능 → DB에 저장

	// 에러메시지 담을 때 사용할 변수
	String msg = null;
	

	/* 세션 유효성 검사 */ 
	// 로그인 하지 않으면 게시글 입력 할 수 없음 → 홈페이지 재요청
	if(session.getAttribute("loginMemberId") == null){
		msg = URLEncoder.encode("로그인 후 이용해 주세요.", "utf-8");
		response.sendRedirect(request.getContextPath() + "/home.jsp?msg=" + msg);
		return;
	}
	
	// 유효성 검사 통과하면 변수에 저장
	String loginMemberId = (String)session.getAttribute("loginMemberId");
	// 디버깅
	System.out.println(loginMemberId + " <-- insertBoardAction 변수 loginMemberId");

	
	/* 요청값 유효성 검사 */
	// 요청값이 null이거나 공백이면 → 게시글 입력 페이지 재요청 및 오류메세지 출력
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
		response.sendRedirect(request.getContextPath() + "/board/insertBoardForm.jsp?msg=" + msg);
		return;
	}
	
	// 유효성 검사를 통과하면 변수에 저장
	String memberId = request.getParameter("memberId");
	String localName = request.getParameter("localName");
	String boardTitle = request.getParameter("boardTitle");
	String boardContent = request.getParameter("boardContent");
	
	// 디버깅
	System.out.println(memberId + " <-- insertBoardAction memberId");
	System.out.println(localName + " <-- insertBoardAction localName");
	System.out.println(boardTitle + " <-- insertBoardAction boardTitle");
	System.out.println(boardContent + " <-- insertBoardAction boardContent");
	
	// 파라미터값 클래스에 저장
	Board paramBoard = new Board();
	paramBoard.setMemberId(memberId);
	paramBoard.setLocalName(localName);
	paramBoard.setBoardTitle(boardTitle);
	paramBoard.setBoardContent(boardContent);
	
	/*------------------------------ 2. 모델 계층 -----------------------------*/
	
	// DB 연결
	String driver = "org.mariadb.jdbc.Driver";
	String dburl = "jdbc:mariadb://127.0.0.1:3306/userboard";
	String dbuser = "root";
	String dbpw = "java1234";
	Class.forName(driver);
	Connection conn = DriverManager.getConnection(dburl, dbuser, dbpw);
	
	// 쿼리 실행
	String sql = "INSERT INTO board(local_name, board_title, board_content, member_id, createdate, updatedate) VALUES(?,?,?,?,NOW(),NOW())";
	PreparedStatement stmt = conn.prepareStatement(sql);
	stmt.setString(1, paramBoard.getLocalName());
	stmt.setString(2, paramBoard.getBoardTitle());
	stmt.setString(3, paramBoard.getBoardContent());
	stmt.setString(4, paramBoard.getMemberId());
	System.out.println(stmt + " <-- insertBoardAction stmt");
	
	// 영향받은 행의 개수
	int row = stmt.executeUpdate();
	// 게시글 입력 성공 시 : 홈페이지 재요청
	if(row == 1) {
		System.out.println(row + " <-- insertBoardAction : 게시글 입력성공");
		msg = URLEncoder.encode("게시글 작성에 성공하였습니다","utf-8");
		response.sendRedirect(request.getContextPath() + "/home.jsp?msg=" + msg);
		return;
	// 게시글 입력 실패 시 : 게시글 입력 화면 재요청 및 오류메세지 출력
	} else {
		System.out.println(row + " <-- insertBoardAction : 게시글 입력실패");
		msg = URLEncoder.encode("게시글 작성에 실패하였습니다 다시 시도해주세요","utf-8");
		response.sendRedirect(request.getContextPath() + "/insertBoardForm.jsp?msg=" + msg);
		return;
	}
%>