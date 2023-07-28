<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import = "java.net.*" %>
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
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>category</title>
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
		<!-- 지역 카테고리 상세보기 및 수정 삭제 버튼 -->
		<h2>지역 카테고리 관리 페이지</h2>
		
		<!-- 오류 메시지 -->
		<div class="text-primary">
			<%
				if(request.getParameter("msg") != null){
			%>
				<%=request.getParameter("msg")%>
			<%
				}
			%>
		</div>
		
		<div>
		<table class="table">
			<tr>
				<td>
					<a class="btn btn-outline-primary" href="<%=request.getContextPath()%>/local/insertLocalForm.jsp">지역 추가</a>
				</td>
			</tr>
			<tr>
				<td>
					<a class="btn btn-outline-primary" href="<%=request.getContextPath()%>/local/updateLocalForm.jsp">지역 수정</a>
				</td>
			</tr>
			<tr>
				<td>
					<a class="btn btn-outline-primary" href="<%=request.getContextPath()%>/local/deleteLocalForm.jsp">지역 삭제</a>
				</td>
			</tr>
		</table>
		</div>
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