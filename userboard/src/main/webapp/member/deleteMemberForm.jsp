<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import = "java.net.*" %>
<%
	// 인코딩 처리
	request.setCharacterEncoding("UTF-8");

	// 요청분석 : 로그인 되어있을때만, 회원 탈퇴 가능
	
	// 에러메시지 담을 때 사용할 변수
	String msg = null;
	
	/* 세션 유효성 검사 */ 
	if(session.getAttribute("loginMemberId") == null){
		msg = URLEncoder.encode("로그인 후 이용해 주세요.", "utf-8");
		response.sendRedirect(request.getContextPath() + "/home.jsp");
		return;
	}
	
	// 유효성검사 통과하면 변수에 저장,,,?
			
	System.out.println(session.getAttribute("loginMemberId"));
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>deleteMemberForm</title>
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
	
	<!-- 회원탈퇴 : 현재 비밀번호가 맞을 때만 탈퇴 가능 -->
	<h1>회원탈퇴</h1>
	
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
	<form action="<%=request.getContextPath()%>/member/deleteMemberAction.jsp" method="post">
		<table>
			<tr>
				<th>비밀번호 확인</th>
				<td>
					<input type="password" name="memberPw">
				</td>
			</tr>
		</table>
		<br>
		<button type="submit" class="btn btn-danger">탈퇴하기</button>
	</form>
</div>
</body>
</html>