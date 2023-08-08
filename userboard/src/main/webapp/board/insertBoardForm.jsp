<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
	// 1. 유효성 검사
	// 세션값 확인
	if(session.getAttribute("loginMemberId") == null) {
		response.sendRedirect(request.getContextPath()+"/home.jsp");
		return;
	}
	// 아이디 가져오기
	String memberId = (String)session.getAttribute("loginMemberId");
	System.out.println(memberId + " <- insertBoardForm session loginMemberId");
	
	// 2. 모델값
	// 드라이버 로딩 및 db 접속
	String driver = "org.mariadb.jdbc.Driver";
	String dburl = "jdbc:mariadb://127.0.0.1:3306/userboard";
	String dbuser = "root";
	String dbpw = "java1234";
	Class.forName(driver);
	Connection conn = DriverManager.getConnection(dburl, dbuser, dbpw);
	
	// 카테고리 조회를 위한 쿼리 작성
	String localSql = "SELECT local_name localName FROM local";
	PreparedStatement localStmt = conn.prepareStatement(localSql);
	ResultSet localRs = localStmt.executeQuery();
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>insertBoardForm.jsp</title>
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
	
	<!--- [시작] 게시글 insert form ------------------------------------------------------------->
	<div class="container">
		<h1 class="hfont">Create Post</h1>
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
			<form action="<%=request.getContextPath()%>/board/insertBoardAction.jsp" method="post">
				<table class="table table-bordered pfont">
					<tr>
						<th class="table-secondary">카테고리</th>
						<td>
							<select name="localName" class="form-select" id="exampleSelect1">
								<%
									// 생성된 카테고리 중 선택
									while(localRs.next()) {
								%>
									<option value="<%=localRs.getString("localName")%>"><%=localRs.getString("localName")%></option>
								<%
									}
								%>
							</select>
						</td>
					</tr>
					<tr>
						<th class="table-secondary">작성자</th>
						<td>
							<!-- 작성자는 현재 로그인한 아이디, 수정불가 (readonly) -->
							<input type="text" name="memberId" value="<%=memberId%>" class="form-control" readonly>
						</td>
					</tr>
					<tr>
						<th class="table-secondary">제목</th>
						<td>
							<input type="text" name="boardTitle" class="form-control">
						</td>
					</tr>
					<tr>
						<th class="table-secondary">내용</th>
						<td>
							<textarea rows="10" cols="163" name="boardContent"></textarea>
						</td>
					</tr>
				</table>
				<div class="pfont">
					<a href="<%=request.getContextPath()%>/home.jsp" class="btn btn-secondary">
						취소
					</a>
					<button type="submit" class="btn btn-outline-secondary">작성</button>
				</div>
			</form>
		</div>
	</div>
	<!---------------------- 게시글 insert form 끝 ---------------------->

	<!-- include 페이지 : Copyright &copy; 구디아카데미 -->
	<div class="pfont">
		<jsp:include page="/inc/copyright.jsp"></jsp:include>
	</div>
	
	<!-- Bootstrap core JS-->
	<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/js/bootstrap.bundle.min.js"></script>
	<!-- Core theme JS-->
	<script src="js/scripts.js"></script>
</body>
</html>