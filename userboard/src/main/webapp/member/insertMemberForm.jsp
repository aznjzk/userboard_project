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
<!-- Latest compiled and minified CSS -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/css/bootstrap.min.css" rel="stylesheet">
  
<!-- Latest compiled JavaScript -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/js/bootstrap.bundle.min.js"></script>
</head>
<body>
	<div>
		<jsp:include page="/inc/mainmenu.jsp"></jsp:include>
	</div>

	<h1>회원가입 페이지</h1>
	<div class="text-danger">
		<%
			if(request.getParameter("msg") != null){
		%>
			<%=request.getParameter("msg")%>
		<%
			}
		%>
	</div>	
	<form action="<%=request.getContextPath()%>/member/insertMemberAction.jsp" method="post">
		<table>
			<tr>
				<td>아이디</td>
				<td><input type="text" name="memberId"></td>
			</tr>
			<tr>
				<td>비밀번호</td>
				<td><input type="password" name="memberPw"></td>
			</tr>
			<tr>
				<td>비밀번호 재입력</td>
				<td>
					<input type="password" name="memberPw2">
				</td>
			</tr>
		</table>
		<button type="submit">회원가입</button>
	</form>
	
	<div>
		<jsp:include page="/inc/copyright.jsp"></jsp:include>
	</div>
</body>
</html>