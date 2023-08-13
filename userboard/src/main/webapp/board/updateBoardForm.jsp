<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.net.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="vo.*" %>
<%
	// 인코딩 처리
	request.setCharacterEncoding("UTF-8");

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
	// 세션값, 요청값 (boardNo, memberId)
	if(session.getAttribute("loginMemberId") == null
			|| request.getParameter("boardNo") == null
			|| request.getParameter("boardNo").equals("")
			|| request.getParameter("memberId") == null
			|| request.getParameter("memberId").equals("")) {
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
	
/*------------------------------ 2. 모델 계층 -----------------------------*/
	
	// DB 연결
	String driver = "org.mariadb.jdbc.Driver";
	String dburl = "jdbc:mariadb://127.0.0.1:3306/userboard";
	String dbuser = "root";
	String dbpw = "java1234";
	Class.forName(driver);
	Connection conn = DriverManager.getConnection(dburl, dbuser, dbpw);
	
	// 쿼리 실행
	String sql = "SELECT board_no boardNo, local_name localName, member_id memberId, board_title boardTitle, board_content boardContent, createdate, updatedate FROM board WHERE board_no = ?";
	PreparedStatement stmt = conn.prepareStatement(sql);
	stmt.setInt(1, boardNo);
	ResultSet rs = stmt.executeQuery();
	
	// vo타입으로 바꾸기(데이터베이스에서 가져온 결과를 "Board" 객체에 저장)
	Board board = null;
	if(rs.next()) {
		board = new Board();
		board.setBoardNo(rs.getInt("boardNo"));
		board.setLocalName(rs.getString("localName"));
		board.setMemberId(rs.getString("memberId"));
		board.setBoardTitle(rs.getString("boardTitle"));
		board.setBoardContent(rs.getString("boardContent"));
		board.setCreatedate(rs.getString("createdate"));
		board.setUpdatedate(rs.getString("updatedate"));
	}
	
	// 카테고리 조회를 위한 쿼리 작성
	String localSql = "SELECT local_name localName FROM local";
	PreparedStatement localStmt = conn.prepareStatement(localSql);
	ResultSet localRs = localStmt.executeQuery();
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>updateBoardForm</title>
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
		footer{
			position: absolute;  
		    bottom: 0;
		    width: 100%;
		}	
	</style>
</head>
<body>
	<!-- 메인메뉴(가로) -->
	<div class="pfont">
		<jsp:include page="/inc/mainmenu.jsp"></jsp:include>
	</div>
	
	<br>

<!--- [시작] 게시글 update form ------------------------------------------------------------->
	<div class="container">
		<h1 class="hfont">게시글 수정</h1>
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
		<div>
			<form action="<%=request.getContextPath()%>/board/updateBoardAction.jsp" method="post">
				<table class="table border pfont">
					<tr>
						<th class="table-secondary">글번호</th>
						<td>
							<!-- 글번호는 수정불가 (readonly) -->
							<input type="number" name="boardNo" value="<%=board.getBoardNo()%>" class="form-control" readonly>
						<td>
					</tr>
					<tr>
						<th class="table-secondary">카테고리</th>
						<td>
							<select name="localName" class="form-select">
								<%
									// 수정 전 카테고리 표시
									while(localRs.next()) {
								%>
									<option value="<%=localRs.getString("localName")%>" 
								<%
										if(localRs.getString("localName").equals(board.getLocalName())){%> selected 
								<%
										}
								%>	>
											<%=localRs.getString("localName")%>
									</option>
								<%
									}
								%>
							</select>
						</td>
					</tr>
					<tr>
						<th class="table-secondary">작성자</th>
						<td>
							<!-- 작성자는 수정불가 (readonly) -->
							<input type="text" name="memberId" value="<%=board.getMemberId()%>" class="form-control" readonly>
						</td>
					</tr>
					<tr>
						<th class="table-secondary">제목</th>
						<td>
							<input type="text" name="boardTitle" class="form-control" value="<%=board.getBoardTitle()%>">
						</td>
					</tr>
					<tr>
						<th class="table-secondary">내용</th>
						<td>
							<textarea rows="10" cols="161" name="boardContent"><%=board.getBoardContent()%></textarea>
						</td>
					</tr>
				</table>
				<div class="pfont">
					<a href="<%=request.getContextPath()%>/board/boardOne.jsp?boardNo=<%=boardNo%>" class="btn btn-secondary">
						취소
					</a>
					<button type="submit" class="btn btn-outline-secondary">수정</button>
				</div>
			</form>
		</div>
	</div>
	<!---------------------- 게시글 update form 끝 ---------------------->
	
	<!-- include 페이지 : Copyright &copy; 구디아카데미 -->
	<div class="pfont">
		<jsp:include page="/inc/copyright.jsp"></jsp:include>
	</div>
	
	<!-- Bootstrap core JS-->
	<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/js/bootstrap.bundle.min.js"></script>
	<!-- Core theme JS-->
	<script src="js/scripts.js"></script>
</html>