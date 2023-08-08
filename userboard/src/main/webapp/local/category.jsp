<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import = "java.net.*" %>
<%@ page import = "java.sql.*" %>
<%@ page import = "java.util.*" %>
<%@ page import = "vo.*" %>
<%
	// 인코딩 처리
	request.setCharacterEncoding("UTF-8");

	// 에러메시지 담을 때 사용할 변수
	String msg = null;
	
	/* 세션 유효성 검사 */ 
	// 로그인 되어있을때만, 지역 카테고리 관리 가능
	if(session.getAttribute("loginMemberId") == null){
		msg = URLEncoder.encode("로그인 후 이용해 주세요.", "utf-8");
		response.sendRedirect(request.getContextPath() + "/home.jsp");
		return;
	}
	// DB 연결
	String driver = "org.mariadb.jdbc.Driver";
	String dburl = "jdbc:mariadb://127.0.0.1:3306/userboard";
	String dbuser = "root";
	String dbpw = "java1234";
	Class.forName(driver);
	Connection conn = DriverManager.getConnection(dburl, dbuser, dbpw);
	
	// DB의 local_name을 출력하는 쿼리 작성
	String ufLocalSql = "";
	PreparedStatement ufLocalStmt = null;
	ResultSet ufLocalRs = null;
	
	ufLocalSql = "SELECT local.local_name localName, COUNT(board.local_name) cnt, local.createdate createdate, local.updatedate updatedate FROM local LEFT JOIN board ON local.local_name = board.local_name GROUP BY local.local_name, local.createdate, local.updatedate";
	ufLocalStmt = conn.prepareStatement(ufLocalSql);
	ufLocalRs = ufLocalStmt.executeQuery();

	// sql쿼리문을 통해 불러온 값을 HashMap에 저장
	ArrayList<HashMap<String, Object>> localNameList = new ArrayList<HashMap<String, Object>>();
	while(ufLocalRs.next()){
		HashMap<String, Object> local = new HashMap<String, Object>();
		local.put("localName", ufLocalRs.getString("localName"));
		local.put("cnt", ufLocalRs.getInt("cnt"));
		local.put("createdate", ufLocalRs.getString("createdate"));
		local.put("updatedate", ufLocalRs.getString("updatedate"));
		localNameList.add(local);
	}
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>category</title>
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
	
	<div class="container">
		<div class="row">
			<div class="col">
				<h2 class="hfont">지역 카테고리 관리 페이지</h2>
			</div>
			<div class="col text-end justify-content-end">
				<!-- 지역 카테고리 추가 수정 삭제 버튼 -->
				<div class="pfont">
					<a class="btn btn-outline-secondary" href="<%=request.getContextPath()%>/local/insertLocalForm.jsp">지역 추가</a>
					<a class="btn btn-outline-secondary" href="<%=request.getContextPath()%>/local/updateLocalForm.jsp">지역 수정</a>
					<a class="btn btn-outline-secondary" href="<%=request.getContextPath()%>/local/deleteLocalForm.jsp">지역 삭제</a>
				</div>
			</div>
		</div>
		
		<!-- 오류 메시지 -->
		<div class="text-danger pfont">
			<%
				if(request.getParameter("msg") != null){
			%>
				<%=request.getParameter("msg")%>
			<%
				}
			%>
		</div>
	
		<br>
	
		<table class="table pfont" style="text-align: center;">
			<tr>
				<th>지역 이름</th>
				<th>게시글 수</th>
				<th>생성일</th>
				<th>수정일</th>
			</tr>
		<%
			for(HashMap<String, Object> local : localNameList) {
		%>
			<tr>
				<td><%=local.get("localName")%></td>
				<td><%=local.get("cnt")%></td>
				<td><%=local.get("createdate")%></td>
				<td><%=local.get("updatedate")%></td>
			</tr>
		<%
			}
		%>
		</table>
	</div>
	
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