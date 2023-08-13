<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import = "java.net.*" %>
<%
	// 인코딩 처리
	request.setCharacterEncoding("UTF-8");	

	// 요청분석 : 로그인 안 했을 때만, 가입 가능
	
	// 에러메시지 담을 때 사용할 변수
	String msg = null;

	// session 유효성 검사
	if(session.getAttribute("loginMemberId") != null){
		msg = URLEncoder.encode("이미 로그인 되었습니다", "utf-8");
		response.sendRedirect(request.getContextPath() + "/home.jsp");
		return;
	}
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>insertMemberForm.jsp</title>
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

	<div class="container">
		<h1 class="hfont">회원가입 페이지</h1>
		<div class="text-danger pfont">
			<%
				if(request.getParameter("msg") != null){
			%>
				<%=request.getParameter("msg")%>
			<%
				}
			%>
		</div>	
		
		<div class="pfont">
		<form action="<%=request.getContextPath()%>/member/insertMemberAction.jsp" method="post">
			<table class="table border">
				<tr>
					<th class="table-secondary">아이디</th>
					<td><input type="text" name="memberId"></td>
				</tr>
				<tr>
					<th class="table-secondary">비밀번호</th>
					<td><input type="password" name="memberPw"></td>
				</tr>
				<tr>
					<th class="table-secondary">비밀번호 재입력</th>
					<td>
						<input type="password" name="memberPw2">
					</td>
				</tr>
			</table>
			<button type="submit" class="btn btn-outline-secondary">회원가입</button>
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