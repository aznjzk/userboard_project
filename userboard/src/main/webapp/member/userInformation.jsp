<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import = "java.sql.*" %>
<%@ page import = "java.util.*" %>
<%@ page import = "vo.*" %>
<%
	// 인코딩 처리
	request.setCharacterEncoding("UTF-8");

	//ANSI CODE	
	final String RESET = "\u001B[0m"; 
	final String BG_YELLOW = "\u001B[43m";
	final String BG_BLUE = "\u001B[44m";
	final String BG_PURPLE = "\u001B[45m";
	final String BG_CYAN = "\u001B[46m";
	final String CYAN = "\u001B[36m";
	
/* ------------------------------ 1. 컨트롤러 계층 ------------------------------ */
	
	// 요청분석 : 로그인 되어있을때만, 회원정보 조회 가능
	
	/* 세션 유효성 검사 */ 
	if(session.getAttribute("loginMemberId") == null){
		response.sendRedirect(request.getContextPath() + "/home.jsp");
		return;
	}
	// 유효성 검사 통과하면 변수에 저장
	String memberId = (String)session.getAttribute("loginMemberId");
	// 디버깅
	System.out.println(memberId + " <-- userInformation 변수 memberId");
	
/*------------------------------ 2. 모델 계층 -----------------------------*/

	// DB 연결
	String driver = "org.mariadb.jdbc.Driver";
	String dbUrl = "jdbc:mariadb://127.0.0.1:3306/userboard";
	String dbUser = "root";
	String dbPw = "java1234";
	Class.forName(driver);
	Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPw);
	
	// 쿼리 실행	
	String userSql = "";
	PreparedStatement userStmt = null;
	ResultSet userRs = null;
	/*
		SELECT member_id,createdate
		FROM member
		WHERE member_id = ?
	*/
	userSql = "SELECT member_id,createdate FROM member WHERE member_id = ?";
	userStmt = conn.prepareStatement(userSql);
	// ? 1개
	userStmt.setString(1, memberId);
	// 쿼리 디버깅
	System.out.println(CYAN + userStmt + " <-- memberOne memberOneStmt" + RESET); 
	// 결과값
	userRs = userStmt.executeQuery();
	
	// 회원정보 : 1개 -> ArrayList가 아닌 Vo타입(Member)으로 저장
	Member user = null; 
	if(userRs.next()){
		user = new Member();
		user.setMemberId(userRs.getString("member_id"));
		user.setCreatedate(userRs.getString("createdate"));
	}

/* ------------------------------ 3. 뷰 계층 ------------------------------ */ 
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>userInformation</title>
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
		.aa{
			color: #6C757D;
			text-decoration: none;
			}
	</style>
</head>
<body>
	<!-- 메인메뉴(가로) -->
	<div class="pfont">
		<jsp:include page="/inc/mainmenu.jsp"></jsp:include>
	</div>
	
	<br>

<!--- [시작] 회원정보 ------------------------------------------------------------->

	<div class="container">
	<h1 class="hfont">회원정보</h1>
		<table class="table pfont">
			<tr>
				<th class="table-secondary">ID</th>
				<td><%=user.getMemberId()%></td>
			</tr>
			<tr>
				<th class="table-secondary">가입일</th>
				<td><%=user.getCreatedate()%></td>
			</tr>
		</table>
		
		<div class="pfont">
			<a href="<%=request.getContextPath()%>/member/updatePwForm.jsp" class="btn btn-outline-secondary">비밀번호변경</a>
			<a href="<%=request.getContextPath()%>/member/deleteMemberForm.jsp" class="btn btn-outline-danger">회원탈퇴</a>
		</div>
	</div>
			
<!------------------------------------------------------------- [끝] 회원정보 --->
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

	