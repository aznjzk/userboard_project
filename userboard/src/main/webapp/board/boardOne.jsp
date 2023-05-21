<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import = "java.sql.*" %>
<%@ page import = "java.net.*" %>
<%@ page import = "java.util.*" %>
<%@ page import = "vo.*" %>
<%
	// 인코딩 처리
	response.setCharacterEncoding("UTF-8");

	// ANSI CODE	
	final String RESET = "\u001B[0m"; 
	final String BG_YELLOW = "\u001B[43m";
	final String BG_BLUE = "\u001B[44m";
	final String BG_PURPLE = "\u001B[45m";
	final String BG_CYAN = "\u001B[46m";
	final String CYAN = "\u001B[36m";
	
/* ------------------------------ 1. 컨트롤러 계층 ------------------------------ */
	
	// 요청분석: 로그인 여부 관계 없이 상세페이지 read가능
	// 현재 로그인 사용자의 Id
	String loginMemberId = null;
	if(session.getAttribute("loginMemberId") != null){
		loginMemberId = (String)session.getAttribute("loginMemberId");
	}

	
	
	/* 현재 파라미터값 디버깅 */
	System.out.println(CYAN + request.getParameter("boardNo") + " <-- boardOne param boardNo" + RESET); 
	
	// 에러메시지 담을 때 사용할 변수
	String msg = null;

	/* 요청값 유효성 검사 */
	// 요청값이 null이거나 공백이면 → home페이지 재요청 및 코드진행 종료
	if(request.getParameter("boardNo") == null 
		|| request.getParameter("boardNo").equals("")){
		response.sendRedirect(request.getContextPath()+"/home.jsp");
		return;
	}
	
	/* 유효성 검사를 통과하면 변수에 저장 */
	int boardNo = Integer.parseInt(request.getParameter("boardNo"));
	// 디버깅
	System.out.println(boardNo + " <-- boardOne 변수 boardNo");
	
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
</head>
<body>
	<!-- 메인메뉴(가로) -->
	<div>
		<jsp:include page="/inc/mainmenu.jsp"></jsp:include>
	</div>
	
	<br>
	
	<!--- [시작] 게시글 ------------------------------------------------------------->
	
	<!-- 3-1) board one 결과셋 -->
	<div>
	<h1>게시글 상세내용</h1>
		<table class="table table-bordered">
			<tr>
				<th>번호</th><!-- 1행 -->
				<td><%=board.getBoardNo()%></td>
			</tr>
			<tr>
				<th>지역</th><!-- 2행 -->
				<td><%=board.getLocalName()%></td>
			</tr>
			<tr>
				<th>제목</th><!-- 3행 -->
				<td><%=board.getBoardTitle()%></td>
			</tr>
			<tr>
				<th>본문</th><!-- 4행 -->
				<td><%=board.getBoardContent()%></td>
			</tr>
			<tr>
				<th>작성자</th><!-- 5행 -->
				<td><%=board.getMemberId()%></td>
			</tr>
			<tr>
				<th>작성일</th><!-- 6행 -->
				<td><%=board.getCreatedate()%></td>
			</tr>
			<tr>
				<th>수정일</th><!-- 7행 -->
				<td><%=board.getUpdatedate()%></td>
			</tr>
		</table>
	</div>
	
	<!-- 수정, 삭제 버튼 -->
	<%	// 로그인한 사용자이면서 && 로그인 아이디와 게시글 작성자가 같을 때만 → 수정,삭제 허용 
		if(loginMemberId != null
		&& loginMemberId.equals(board.getMemberId())) { 
	%>
	<div>
		<form action="<%=request.getContextPath()%>/board/deleteBoardAction.jsp" method="post">
			<button type="submit" class="btn btn-light" style="float:right">삭제</button>
		</form>
		<form action="<%=request.getContextPath()%>/board/updateBoardAction.jsp" method="post">
			<button type="submit" class="btn btn-light" style="float:right">수정</button>
		</form>
	</div>
	<%
		}
	%>
	<br>
	
	<!------------------------------------------------------------- [끝] 게시글 --->
	
	<!--- [시작] 댓글 ------------------------------------------------------------->
	
	<!--  3-2) comment 입력 : 세션 유무에 따른 분기 -->
	<h2>댓글</h2>
	<%
		// 로그인 사용자만 댓글 입력 허용
		if(loginMemberId != null) {
	%>
			<form action="<%=request.getContextPath()%>/board/insertCommentAction.jsp" method="post">
				<!-- boardNo와 memberId는 입력값이 없기 때문에 hidden으로 넘긴다 -->
				<input type="hidden" name="boardNo" value="<%=board.getBoardNo()%>">
				<input type="hidden" name="memberId" value="<%=loginMemberId%>">
				<table>
					<tr>
						<th>&#128483; <%=loginMemberId%></th>
					</tr>	
					<tr>	
						<td>
							<textarea rows="2" cols="80" name="commentContent"></textarea>
						</td>
					</tr>
					<tr>
						<td>
							<button type="submit" class="btn btn-light" style="float:right">등록</button>
						</td>
					</tr>
				</table>
			</form>
	<%
		}
	%>
	
	<!-- 오류 메시지 -->
	<div class="text-danger">
		<%
			if(request.getParameter("msg") != null) {
		%>
			<%=request.getParameter("msg")%>
		<%
			}
		%>
	</div> 
	
	<br>

	<!--  3-3) comment list 결과셋 : 로그인 여부에 따라 분기 -->
	
		<%
			for(Comment c : commentList) {
		%>
		
		<table class="table">	
			<thead class="table-light">
			<tr>
				<th><%=c.getMemberId()%></th>
			</tr>
			</thead>
			<tbody>
			<tr>
				<td><%=c.getCommentContent()%></td>
			<tr>
			</tr>
			<tr>
				<td style="color:gray"> 
					작성 : <%=c.getCreatedate()%>
					/ 수정 : <%=c.getUpdatedate()%>
				</td>
			</tr>
		
			
		<%	// 로그인한 사용자이면서 && 로그인 아이디와 댓글 작성자가 같을 때만 → 수정,삭제 허용 
			if(loginMemberId != null
			&& loginMemberId.equals(c.getMemberId())){ 
		%>		
			<tr>
				<td>
					<form action="<%=request.getContextPath()%>/board/deleteCommentAction.jsp" method="post">
						<button type="submit" class="btn btn-light" style="float:right">삭제</button>
					</form>
					<form action="<%=request.getContextPath()%>/board/updateCommentForm.jsp?boardNo=<%=board.getBoardNo()%>&commentNo=<%=c.getCommentNo()%>" method="post">
						<button type="submit" class="btn btn-light" style="float:right">수정</button>
					</form>
				</td>
			</tr>
			
		<%
			}
		
			}
		%>
		</tbody>
	</table>
	
	
	<!-- comment 페이징 -->
	<div>
		<%=currentPage%>페이지
	</div>
	
	<!------------------------------------------------------------- [끝] 댓글 --->
	
</body>
</html>