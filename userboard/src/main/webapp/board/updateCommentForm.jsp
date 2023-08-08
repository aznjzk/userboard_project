<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import = "java.sql.*" %>
<%@ page import = "java.net.*" %>
<%@ page import = "java.util.*" %>
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
	
	// 요청분석: 로그인 되어있을때만, 댓글 수정 가능
	
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
	
	/* 현재 파라미터값 디버깅 */
	System.out.println(CYAN + request.getParameter("boardNo") + " <-- boardOne param boardNo" + RESET); 
	

	/* 요청값 유효성 검사 */
	// 요청값이 null이거나 공백이면 → home페이지 재요청 및 코드진행 종료
	if(request.getParameter("boardNo") == null 
		|| request.getParameter("boardNo").equals("")){
		response.sendRedirect(request.getContextPath()+"/home.jsp");
		return;
	} else if(request.getParameter("commentNo")==null
		|| request.getParameter("commentNo").equals("")){
		response.sendRedirect(request.getContextPath()+"/home.jsp");
		return;
	}

	
	/* 유효성 검사를 통과하면 변수에 저장 */
	int boardNo = Integer.parseInt(request.getParameter("boardNo"));
	int commentNo = Integer.parseInt(request.getParameter("commentNo"));
	// 디버깅
	System.out.println(boardNo + " <-- boardOne 변수 boardNo");
	System.out.println(commentNo + " <-- boardOne 변수 commentNo");
	
	/* 페이징을 위한 변수 설정 */
	int currentPage = 1;	// 현재 페이지
	int rowPerPage = 10;	// 페이지당 출력할 행의 개수
	int startRow = 0;		// 시작 행번호
	int totalRow = 0; 		// 마지막 행번호
	int lastPage = 0;		// 마지막 페이지
	

/*------------------------------ 2. 모델 계층 -----------------------------*/

	// DB 연결
	String driver = "org.mariadb.jdbc.Driver";
	String dburl = "jdbc:mariadb://127.0.0.1:3306/userboard";
	String dbuser = "root";
	String dbpw = "java1234";
	Class.forName(driver);
	Connection conn = DriverManager.getConnection(dburl, dbuser, dbpw);
	
	// 2-1) board one 결과셋 : 해당 boardNo의 게시글 상세보기
	String boardOneSql = "";
	PreparedStatement boardOneStmt = null;
	ResultSet boardOneRs = null;
	
	/*
		SELECT board_no boardNo, local_name localName, board_title boardTitle, board_content boardContent, member_id memberId, createdate, updatedate
		FROM board
		WHERE board_no = ?
	*/
	
	boardOneSql = "SELECT board_no boardNo, local_name localName, board_title boardTitle, board_content boardContent, member_id memberId, createdate, updatedate FROM board WHERE board_no = ?";
	boardOneStmt = conn.prepareStatement(boardOneSql);
	// ? 1개
	boardOneStmt.setInt(1, boardNo);
	// 쿼리 디버깅
	System.out.println(CYAN + boardOneStmt + " <-- boardOne boardOneStmt" + RESET);
	
	boardOneRs = boardOneStmt.executeQuery();

	// 게시글 상세내용 : 1개 -> ArrayList가 아닌 Vo타입(Board)으로 저장
	Board board = null; 
	if(boardOneRs.next()){
		board = new Board();
		board.setBoardNo(boardOneRs.getInt("boardNo"));
		board.setLocalName(boardOneRs.getString("localName"));
		board.setBoardTitle(boardOneRs.getString("boardTitle"));
		board.setBoardContent(boardOneRs.getString("boardContent"));
		board.setMemberId(boardOneRs.getString("memberId"));
		board.setCreatedate(boardOneRs.getString("createdate"));
		board.setUpdatedate(boardOneRs.getString("updatedate"));
	}
	// 디버깅
	System.out.println(CYAN + board + " <-- boardOne board" + RESET);

	
	// 2-2) comment list 결과셋 : 해당 boardNo의 댓글 리스트 출력
	String commentListSql = "";
	PreparedStatement commentListStmt = null;
	ResultSet commentListRs  = null;
	
	/*
		SELECT comment_no commentNo, board_no boardNo, comment_content commentContent
		FROM comment
		WHERE board_no = ?
		ORDER BY createdate DESC
		LIMIT ?, ?
	*/
	
	commentListSql = "SELECT comment_no commentNo, board_no boardNo, comment_content commentContent, member_id memberId, createdate, updatedate FROM comment WHERE board_no = ? ORDER BY createdate DESC LIMIT ?, ?";
	commentListStmt = conn.prepareStatement(commentListSql);
	// ? 3개
	commentListStmt.setInt(1, boardNo);
	commentListStmt.setInt(2, startRow);
	commentListStmt.setInt(3, rowPerPage);
	// 쿼리 디버깅
	System.out.println(CYAN + commentListStmt + " <-- boardOne commentListStmt" + RESET); 
	
	commentListRs = commentListStmt.executeQuery();
	
	// Rs --> ArrayList
	ArrayList<Comment> commentList = new ArrayList<Comment>();
	while(commentListRs.next()){
		Comment c = new Comment();
		c.setCommentNo(commentListRs.getInt("commentNo"));
		c.setBoardNo(commentListRs.getInt("boardNo"));
		c.setCommentContent(commentListRs.getString("commentContent"));
		c.setMemberId(commentListRs.getString("memberId"));
		c.setCreatedate(commentListRs.getString("createdate"));
		c.setUpdatedate(commentListRs.getString("updatedate"));
		commentList.add(c);
	}
	System.out.println(commentList.size() + " <-- boardOne commentList.size()");
	

/* ------------------------------ 3. 뷰 계층 ------------------------------ */ 

%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>boardOne</title>
	<!-- 부트스트랩5 사용 -->
	<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/css/bootstrap.min.css" rel="stylesheet">
	<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/js/bootstrap.bundle.min.js"></script>
	<!-- 구글 폰트 적용 -->
	<link rel="preconnect" href="https://fonts.googleapis.com">
	<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
	<link href="https://fonts.googleapis.com/css2?family=Black+Han+Sans&family=Cute+Font&family=Do+Hyeon&display=swap" rel="stylesheet">
	<style>
		.hfont{
			font-family: 'Black Han Sans', sans-serif;
		}
		.pfont{
			font-family: 'Do Hyeon', sans-serif;
		}
	</style>
</head>
<body>
	<!-- 메인메뉴(가로) -->
	<div class="pfont">
		<jsp:include page="/inc/mainmenu.jsp"></jsp:include>
	</div>
	
	<br>
	
	<!--- [시작] 게시글 ------------------------------------------------------------->
	<div class="container">
	
		<!-- 3-1) board one 결과셋 -->
		<div>
			<h1 class="hfont">게시글 상세내용</h1>
			<table class="table table-bordered pfont">
				<tr>
					<th class="table-secondary">번호</th>
					<td><%=board.getBoardNo()%></td>
				</tr>
				<tr>
					<th class="table-secondary">지역</th>
					<td><%=board.getLocalName()%></td>
				</tr>
				<tr>
					<th class="table-secondary">제목</th>
					<td><%=board.getBoardTitle()%></td>
				</tr>
				<tr>
					<th class="table-secondary">본문</th>
					<td><%=board.getBoardContent()%></td>
				</tr>
				<tr>
					<th class="table-secondary">작성자</th>
					<td><%=board.getMemberId()%></td>
				</tr>
				<tr>
					<th class="table-secondary">작성일</th>
					<td><%=board.getCreatedate()%></td>
				</tr>
				<tr>
					<th class="table-secondary">수정일</th>
					<td><%=board.getUpdatedate()%></td>
				</tr>
			</table>
		</div>
		
		<!-- 수정, 삭제 버튼 -->
		<%	// 로그인한 사용자이면서 && 로그인 아이디와 게시글 작성자가 같을 때만 → 수정,삭제 허용 
			if(loginMemberId != null
			&& loginMemberId.equals(board.getMemberId())) { 
		%>
		<div class="pfont">
			<form action="<%=request.getContextPath()%>/board/deleteBoardAction.jsp?boardNo=<%=boardNo%>&memberId=<%=board.getMemberId()%>" method="post">
				<button type="submit" class="btn btn-outline-secondary" style="float:right">삭제</button>
			</form>
			<form action="<%=request.getContextPath()%>/board/updateBoardForm.jsp?boardNo=<%=boardNo%>&memberId=<%=board.getMemberId()%>" method="post">
				<button type="submit" class="btn btn-outline-secondary" style="float:right">수정</button>
			</form>
		</div>
		<%
			}
		%>
		<br>
		
		<!------------------------------------------------------------- [끝] 게시글 --->
		
		<!--- [시작] 댓글 ------------------------------------------------------------->
		
		<!--  3-2) comment 입력 : 세션 유무에 따른 분기 -->
		<h2 class="hfont">댓글</h2>
		<!-- 오류 메시지 -->
		<div class="text-danger pfont">
			<%
				if(request.getParameter("msg") != null) {
			%>
				<%=request.getParameter("msg")%>
			<%
				}
			%>
		</div> 
	<%
		for(Comment c : commentList) {
	%>
		<table class="table pfont">	
			<thead class="table-secondary">
				<tr>
					<th><%=c.getMemberId()%></th>
				</tr>
			</thead>
			<tbody>
	<%		// 로그인한 사용자이면서 && 로그인 아이디와 댓글 작성자가 같을 때만 → 수정 허용 
			if(loginMemberId != null
			&& loginMemberId.equals(c.getMemberId())){ 
	%>		
				<tr>
					<td>
						<form action="<%=request.getContextPath()%>/board/updateCommentAction.jsp" method="post">
							<input type="hidden" name="boardNo" value="<%=board.getBoardNo()%>">
							<input type="hidden" name="commentNo" value="<%=c.getCommentNo()%>">
							<textarea rows="2" cols="80" name="updateCommentContent"><%=c.getCommentContent()%></textarea>
							<button type="submit" class="btn btn-secondary" style="float:right">수정</button>
						</form>
					</td>
				</tr>
	<%
			} else {
	%>
				<tr>
					<td><%=c.getCommentContent()%></td>
				</tr>
	<%		
			}
	%>
				<tr>
					<td style="color:gray"> 
						작성 : <%=c.getCreatedate()%>
						/ 수정 : <%=c.getUpdatedate()%>
					</td>
				</tr>
			</tbody>
	<%
		}
	%>		
				
		</table>
	</div>
	
	
	
	<!-- comment 페이징 -->
	<div class="text-center pfont">
		<%=currentPage%>페이지
	</div>
	
	<!------------------------------------------------------------- [끝] 댓글 --->
	
</body>
</html>