<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import = "java.net.*" %>
<%
	// 인코딩 처리
	request.setCharacterEncoding("UTF-8");

	// 요청분석 : 로그인 되어있을때만, 비밀번호 변경 가능
	
	// 에러메시지 담을 때 사용할 변수
	String msg = null;
	
	/* 세션 유효성 검사 */ 
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
<title>updatePwForm</title>
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
	
	<!-- 비밀번호 변경 : 현재 비밀번호가 맞을 때만 변경 가능 -->
	<div class="container">
		<h2 class="hfont">비밀번호 변경</h2>
		
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
		
		<div>
			<form action="<%=request.getContextPath()%>/member/updatePwAction.jsp" method="post">
				<table class="table border pfont">
					<tr>
						<th class="table-secondary">현재 비밀번호</th>
						<td><input type="password" name="currentPw"></td>
					</tr>
					<tr>
						<th class="table-secondary">새 비밀번호</th>
						<td><input type="password" name="newPw"></td>
					</tr>
					<tr>
						<th class="table-secondary">새 비밀번호 확인</th>
						<td><input type="password" name="newPwCheck"></td>
					</tr>
				</table>
				
				<div class="pfont">
					<button class="btn btn-secondary" type="submit">변경</button>
					<!-- 비밀번호 변경을 취소하고 싶으면 회원정보 화면으로 돌아갈 수 있도록 -->
					<a href="<%=request.getContextPath()%>/member/userInformation.jsp" class="btn btn-light">취소</a>
				</div>
			</form>
		</div>
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