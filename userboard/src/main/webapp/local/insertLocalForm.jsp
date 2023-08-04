<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import = "java.net.*" %>
<%
	// 인코딩 처리
	request.setCharacterEncoding("UTF-8");

	// 에러메시지 담을 때 사용할 변수
	String msg = null;
	
	/* 세션 유효성 검사 */ 
	// 로그인 되어있을때만, 지역 카테고리 추가 가능
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
<title>insertLocal</title>
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
		<!-- 지역 카테고리 추가 -->
		<h1 class="hfont">카테고리 추가</h1>
		<form action="<%=request.getContextPath()%>/local/insertLocalAction.jsp" method="post">
			<div class="pfont">	
				<table class="table">
					<tr>
						<th>추가할 지역이름을 입력해 주세요</th>
					</tr>
					<tr>
						<td><input type="text" class="form-control" name="insertLocalName"></td>
					</tr>
				</table>
			</div>
	
			<div class="pfont">	
				<button type="submit" class="btn btn-outline-primary">지역추가</button>
			
				<!-- 오류 메시지 -->
				<span class="text-danger">
				<%
					if(request.getParameter("msg") != null){
				%>
					<%=request.getParameter("msg")%>
				<%
					}
				%>
				</span>
			</div>	
		</form>
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