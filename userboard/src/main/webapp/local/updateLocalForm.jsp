<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import = "java.net.*" %>
<%@ page import = "java.sql.*" %>
<%@ page import = "java.util.*" %>
<%@ page import="vo.*" %>
<%
	// 인코딩 처리
	request.setCharacterEncoding("UTF-8");

	// 에러메시지 담을 때 사용할 변수
	String msg = null;
	
	/* 세션 유효성 검사 */ 
	// 로그인 되어있을때만, 지역 카테고리 수정 가능
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
	
	// DB의 local_name을 옵션으로 고를 수 있도록 쿼리 작성
	String ufLocalSql = "";
	PreparedStatement ufLocalStmt = null;
	ResultSet ufLocalRs = null;
	
	ufLocalSql = "select local_name from local";
	ufLocalStmt = conn.prepareStatement(ufLocalSql);
	ufLocalRs = ufLocalStmt.executeQuery();

	// sql쿼리문을 통해 불러온 값을 ArrayList에 저장
	ArrayList<Local> localNameList = new ArrayList<Local>();
	while(ufLocalRs.next()){
		Local local = new Local();
		local.setLocalName(ufLocalRs.getString("local_name"));
		localNameList.add(local);
	}
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>updateLocal</title>
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
	
	<div class="container">
		<!-- 지역 카테고리 수정 -->
		<h1>카테고리 수정</h1>
		<form action="<%=request.getContextPath()%>/local/updateLocalAction.jsp" method="post">
			<div>	
				<table class="table">
					<tr>
						<th>수정할 지역 이름을 선택해 주세요</th>
					</tr>
					<tr>
						<td>기존 카테고리명</td>
					</tr>
					<tr>
						<td>
							<select class="form-select" name="currentLocalName">
								<%
									for(Local local : localNameList) {
								%>
										<option value="<%=local.getLocalName()%>"><%=local.getLocalName()%></option>
								<%
									}
								%>
							</select>
						</td>
					</tr>
					<tr>
						<td>카테고리명 수정</td>
					</tr>
					<tr>
						<td><input type ="text" class="form-control" name="updateLocalName"></td>
					</tr>
				</table>
			</div>	
			
			<!-- 오류 메시지 -->
			<div class="text-danger">
				<%
					if(request.getParameter("msg") != null){
				%>
					<%=request.getParameter("msg")%>
				<%
					}
				%>
			</div>
			
			<div>
				<button type="submit" class="btn btn-outline-primary">지역수정</button>
			</div>
		</form>
	</div>
	
	<!-- Bootstrap core JS-->
	<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/js/bootstrap.bundle.min.js"></script>
	<!-- Core theme JS-->
	<script src="js/scripts.js"></script>
	
	<!-- include 페이지 : Copyright &copy; 구디아카데미 -->
	<div>
		<jsp:include page="/inc/copyright.jsp"></jsp:include>
	</div>
</body>
</html>