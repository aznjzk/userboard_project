<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<!-- Core theme CSS (includes Bootstrap)-->
<link href="css/styles.css" rel="stylesheet" />

<!-- Responsive navbar-->
<nav class="navbar navbar-expand-lg navbar-dark bg-dark">
	<div class="container">
		<a class="navbar-brand" href="<%=request.getContextPath()%>/home.jsp">Home</a>
		<button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarSupportedContent" aria-controls="navbarSupportedContent" aria-expanded="false" aria-label="Toggle navigation"><span class="navbar-toggler-icon"></span></button>
			<div class="collapse navbar-collapse" id="navbarSupportedContent">
				<ul class="navbar-nav ms-auto mb-2 mb-lg-0">
				<%
					// 로그인 전
					if(session.getAttribute("loginMemberId") == null) {
				%>
					<li class="nav-item"><a class="nav-link active" aria-current="page" href="<%=request.getContextPath()%>/member/insertMemberForm.jsp">회원가입</a></li>
				<%		 		
					// 로그인 후
					} else { 
				%>
					<li class="nav-item"><a class="nav-link" href="<%=request.getContextPath()%>/local/category.jsp">카테고리 관리</a></li>
					<li class="nav-item"><a class="nav-link" href="<%=request.getContextPath()%>/member/userInformation.jsp">회원정보</a></li>
					<li class="nav-item"><a class="nav-link active" aria-current="page" href="<%=request.getContextPath()%>/member/logoutAction.jsp">로그아웃</a></li>
				<%
					}
				%>
				</ul>
			</div>
	</div>
</nav>