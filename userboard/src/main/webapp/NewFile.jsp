<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import = "java.sql.*" %>
<%@ page import = "java.net.*" %>
<%@ page import = "java.util.*" %>
<%@ page import = "vo.*" %>
<%
	// 인코딩 처리
	response.setCharacterEncoding("UTF-8");

	// ANSI CODE	
	final String RESET = "\u001B[0m"; 
	final String BG_YELLOW = "\u001B[43m";
	final String BG_BLUE = "\u001B[44m";
	final String BG_PURPLE = "\u001B[45m";
	final String BG_CYAN = "\u001B[46m";
	final String CYAN = "\u001B[36m";
	
/*------------------------------ 1. 요청분석(컨트롤러 계층) -----------------------------*/
	
	/* 현재 파라미터값 디버깅 */
	System.out.println(CYAN + request.getParameter("localName") + " <-- home param localName" + RESET);
	System.out.println(CYAN + request.getParameter("currentPage") + " <-- home param currentPage" + RESET);
	
	/* localName의 디폴트 값을 "전체"로 설정 */
	// null로 넘어와도 → 전체 카테고리의 게시글을 출력하고
	// "전체"로 넘어와도 → 전체 카테고리의 게시글을 출력해야 하기 때문
	String localName = "전체";
	
	// 요청 분석 - 지역별 카테고리
	// null 또는 전체가 아니면 → 즉 요청값이 있으면 변수에 저장
	if(request.getParameter("localName") != null){
		localName = request.getParameter("localName");
	}
	
	/* 페이징을 위한 변수 설정 */
	int currentPage = 1;	// 현재 페이지 (디폴트 값 1)
	int rowPerPage = 10;	// 페이지당 출력할 행의 개수 (디폴트 값 10)
	int startRow = 0;		// 시작 행번호
	int totalRow = 0; 		// 마지막 행번호
	int lastPage = 0;		// 마지막 페이지
		
	// 요청 분석 - 현재 페이지
	// null이 아니면 → 요청값을 int로 형변환하여 변수에 저장
	if(request.getParameter("currentPage") != null) {
	   currentPage = Integer.parseInt(request.getParameter("currentPage"));
	}
	
	/* 요청 이후 파라미터값 디버깅 */
	System.out.println(BG_CYAN + localName + " <-- home 변수 localName" + RESET);
	System.out.println(BG_CYAN + currentPage + " <-- home 변수 currentPage" + RESET);
	
	
/*------------------------------ 2. 모델 계층 -----------------------------*/

	// DB 연결
	String driver = "org.mariadb.jdbc.Driver";
	String dburl = "jdbc:mariadb://127.0.0.1:3306/userboard";
	String dbuser = "root";
	String dbpw = "java1234";
	Class.forName(driver);
	Connection conn = DriverManager.getConnection(dburl, dbuser, dbpw);
	
	/* 1) 게시판 목록 결과셋(모델) 쿼리 : 지역카테고리를 누르면 해당하는 지역의 게시글을 10개씩 출력 */
	String boardSql = "";
	PreparedStatement boardStmt = null;
	ResultSet boardRs = null;
	/*
		SELECT 
			board_no boardNo,
			local_name localName,
			board_title boardTitle,
			LEFT(board_content, 30) boardContent,
			createdate
		FROM board
		WHERE local_name = ?
		ORDER BY createdate DESC
		LIMIT ?, ?
	*/
	
	// LIMIT절에 넣을 변수 값 할당
	rowPerPage = 5;
	startRow = (currentPage-1) * rowPerPage;
		
	// localName의 요청값에 따른 쿼리문 분기
	if(localName.equals("전체")) {
		boardSql = "SELECT board_no boardNo, local_name localName, board_title boardTitle, LEFT(board_content, 30) boardContent, createdate FROM board ORDER BY createdate DESC LIMIT ?, ?";
		boardStmt = conn.prepareStatement(boardSql);
		// ? 2개
		boardStmt.setInt(1, startRow);
		boardStmt.setInt(2, rowPerPage);
		// 쿼리 디버깅
		System.out.println(BG_BLUE + boardStmt + " <-- home boardStmt" + RESET);
	} else {
		boardSql = "SELECT board_no boardNo, local_name localName, board_title boardTitle, LEFT(board_content, 30) boardContent, createdate FROM board WHERE local_name = ? ORDER BY createdate DESC LIMIT ?, ?";
		boardStmt = conn.prepareStatement(boardSql);
		// ? 3개
		boardStmt.setString(1, localName);
		boardStmt.setInt(2, startRow);
		boardStmt.setInt(3, rowPerPage);
		// 쿼리 디버깅
		System.out.println(BG_BLUE + boardStmt + " <-- home boardStmt" + RESET);
	}
	boardRs = boardStmt.executeQuery(); // DB쿼리 결과셋 모델
	
	// boardRs --> boardList
	ArrayList<Board> boardList = new ArrayList<Board>(); // 애플리케이션에서 사용할 모델(사이즈 0)
	while(boardRs.next()) {
		Board b = new Board();
		b.setBoardNo(boardRs.getInt("boardNo"));
		b.setLocalName(boardRs.getString("localName"));
		b.setBoardTitle(boardRs.getString("boardTitle"));
		b.setBoardContent(boardRs.getString("boardContent"));
		b.setCreatedate(boardRs.getString("createdate"));
		boardList.add(b);
	}
	// 디버깅
	System.out.println(BG_YELLOW + boardList);
	System.out.println(boardList.size() + " <-- home boardList.size()" + RESET);	
	

	/* 2) 서브메뉴 결과셋(모델) 쿼리 : 전체 게시글 개수 및 지역카테고리별 게시글 개수를 출력 */
	String subMenuSql = "";
	PreparedStatement subMenuStmt = null;
	ResultSet subMenuRs = null;
	/*
		SELECT '전체' localName, COUNT(local_name) cnt FROM board
		UNION ALL 
		SELECT local_name, COUNT(local_name) FROM board GROUP BY local_name
		UNION ALL SELECT local_name, 0 cnt FROM local WHERE local_name NOT IN (SELECT local_name FROM board)
		→ 현재 board테이블에 없지만, local테이블에는 있는 지역을 추가하는 쿼리( = 해당 지역에 게시글이 없어도 서브메뉴에 나올 수 있게끔 )
	*/
	subMenuSql = "SELECT '전체' localName, COUNT(local_name) cnt FROM board UNION All SELECT local_name, COUNT(*) cnt FROM board GROUP BY local_name UNION ALL SELECT local_name, 0 cnt FROM local WHERE local_name NOT IN (SELECT local_name FROM board)";
	subMenuStmt = conn.prepareStatement(subMenuSql);
	subMenuRs = subMenuStmt.executeQuery();
	
	// subMenuList <-- 모델데이터
	ArrayList<HashMap<String, Object>> subMenuList = new ArrayList<HashMap<String, Object>>();
	while(subMenuRs.next()){
		HashMap<String, Object> m = new HashMap<String, Object>();
		m.put("localName", subMenuRs.getString("localName"));
		m.put("cnt", subMenuRs.getInt("cnt"));
		subMenuList.add(m);
	}
	// 디버깅
	System.out.println(BG_PURPLE + subMenuList.size() + " <-- home subMenuList.size()" + RESET);


	/* 페이지네이션 */
	String pageSql = "";
	PreparedStatement pageStmt = null;
	ResultSet pageRs = null;
	/*
		SELECT COUNT(*) FROM board
		WHERE local_name = ?
	*/
	// localName에 따라 분기 where절 추가 
	if(localName.equals("전체")) { 	
		pageSql = "SELECT COUNT(*) FROM board";
		pageStmt = conn.prepareStatement(pageSql);
		// 쿼리 디버깅
		System.out.println(BG_BLUE + pageStmt + " <-- home pageStmt" + RESET);
	} else { 	
		pageSql = "SELECT COUNT(*) FROM board WHERE local_name = ?";
		pageStmt = conn.prepareStatement(pageSql);
		// ? 1개
		pageStmt.setString(1, localName);
		// 쿼리 디버깅
		System.out.println(BG_BLUE + pageStmt + " <-- home pageStmt" + RESET);
	}
	pageRs = pageStmt.executeQuery();
	
	// 마지막 행값 저장
	if(pageRs.next()) {
		totalRow = pageRs.getInt("COUNT(*)");
		// 디버깅
		System.out.println(totalRow + " <-- home totalRow 마지막행");
	}
	// 마지막페이지에서 딱 나누어 떨어지지않을 경우 페이지 하나 추가
	lastPage = totalRow / rowPerPage;
	if(totalRow % rowPerPage != 0) {
		lastPage = lastPage + 1;
	}
	System.out.println(lastPage + " <-- home lastPage 마지막페이지");
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>homeCSS</title>
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
	
        <!-- Page header with logo and tagline-->
        <header class="py-5 bg-light border-bottom mb-4">
            <div class="container">
                <div class="text-center my-5">
                    <h1 class="fw-bolder">Welcome to Blog Home!</h1>
                    <p class="lead mb-0">A Bootstrap 5 starter layout for your next blog homepage</p>
                </div>
            </div>
        </header>
        <!-- Page content-->
        <div class="container">
            <div class="row">
                <!-- Blog entries-->
                <div class="col-lg-8">
                <%
					for(Board b : boardList) {
				%>
                    <!-- Featured blog post-->
                    <div class="card mb-4">
                        <a href="#!"></a>
                        <div class="card-body">
                            <div class="small text-muted"><%=b.getLocalName()%> | <%=b.getCreatedate()%></div>
                            <br>
                            <h2 class="card-title"><%=b.getBoardTitle()%></h2>
                            <p class="card-text"><%=b.getBoardContent()%> . . . </p>
                        </div>
                    </div>
                <%		
					}
				%> 
                    
                    <!-- Pagination-->
                    <nav aria-label="Pagination">
                        <hr class="my-0" />
                        <ul class="pagination justify-content-center my-4">
                            <li class="page-item disabled"><a class="page-link" href="#" tabindex="-1" aria-disabled="true">Newer</a></li>
                            <li class="page-item active" aria-current="page"><a class="page-link" href="#!">1</a></li>
                            <li class="page-item"><a class="page-link" href="#!">2</a></li>
                            <li class="page-item"><a class="page-link" href="#!">3</a></li>
                            <li class="page-item disabled"><a class="page-link" href="#!">...</a></li>
                            <li class="page-item"><a class="page-link" href="#!">15</a></li>
                            <li class="page-item"><a class="page-link" href="#!">Older</a></li>
                        </ul>
                    </nav>
                </div>
        	</div>        
        </div>
		<!-- Side widgets-->
		<div class="col-lg-4">
			<!-- Side widget : 로그인 폼 -->
			<%
				if(session.getAttribute("loginMemberId") == null) {  // 로그인을 하지 않은 경우에만 로그인폼 출력
			%>
			<div class="card mb-4">
			<div class="card-header">로그인</div>
				<div class="container text-center">
				<form action="<%=request.getContextPath()%>/member/loginAction.jsp" method="post">
						<table>
							<tr>
								<td>&#128100;</td>
								<td><input class="form-control" type="text" name="memberId"></td>
							</tr>
							<tr>
								<td>&#128274;</td>
								<td><input class="form-control" type="password" name="memberPw"></td>
							</tr>
						</table>
						<div>
							<button class="btn btn-primary center" type="submit">로그인</button>
						</div>
					</form>
				<%   
					} else { // 로그인에 성공한 경우
					String loginMemberId = (String)(session.getAttribute("loginMemberId"));
				%>
					<div class="card mb-4">
					<div class="container text-center">
					<p><%=loginMemberId%>님 환영합니다</p>
				<%		
					}
				%>
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
				</div>
			</div>
                    
			<!-- Categories widget : 서브메뉴(세로) subMenuList1모델 출력 -->
			<div class="card mb-4">
				<div class="card-header">Categories 지역 선택</div>
				<div class="card-body">
					<div class="row">
						<div class="col-sm-12">
							<ul class="list-unstyled mb-0">
							<%
								for(HashMap<String, Object> m : subMenuList) {
							%>
							<li>
								<a href="<%=request.getContextPath()%>/home.jsp?localName=<%=(String)m.get("localName")%>">
									<%=(String)m.get("localName")%>(<%=(Integer)m.get("cnt")%>)
								</a>
							</li>
							<%		
								}
							%>
							</ul>
						</div>
					</div>
				</div>
			</div>
			<!-- Search widget-->
			<div class="card mb-4">
				<div class="card-header">Search</div>
					<div class="card-body">
						<div class="input-group">
							<input class="form-control" type="text" placeholder="Enter search term..." aria-label="Enter search term..." aria-describedby="button-search" />
							<button class="btn btn-primary" id="button-search" type="button">Go!</button>
						</div>
					</div>
				</div>
			</div>
		</div>
	</div>

        <!-- Footer-->
        <footer class="py-5 bg-dark">
            <div class="container"><p class="m-0 text-center text-white">Copyright &copy; Your Website 2023</p></div>
        </footer>
        <!-- Bootstrap core JS-->
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/js/bootstrap.bundle.min.js"></script>
        <!-- Core theme JS-->
        <script src="js/scripts.js"></script>
	
	<br>
	<!-------------------- home 내용 : 로그인 폼 / 카테고리별 게시글 10개씩 -------------------->
	
	<!-- 로그인 폼 -->
	<div>
		<%
			if(session.getAttribute("loginMemberId") == null) {  // 로그인을 하지 않은 경우에만 로그인폼 출력
		%>
			<form action="<%=request.getContextPath()%>/member/loginAction.jsp" method="post">
				<h2>로그인</h2>
				<table class="table table-bordered">
					<tr>
						<td>아이디</td>
						<td><input type="text" name="memberId"></td>
					</tr>
					<tr>
						<td>비밀번호</td>
						<td><input type="password" name="memberPw"></td>
					</tr>
				</table>
			<button type="submit">로그인</button>
			</form>
		<%   
			} else { // 로그인에 성공한 경우
			String loginMemberId = (String)(session.getAttribute("loginMemberId"));
		%>
			<p><%=loginMemberId%>님 환영합니다</p>
		<%		
			}
		%>
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
	
	<br>
	
	<!---[시작] boardList--------------------------------------------------->
	<!-- 카테고리별 게시글 10개씩  -->
	<h2><%=localName%> 게시글</h2>
	<div>
	<table class="table table-bordered table-hover">
		<thead class="table-primary">
			<tr>
				<th>지역</th>
				<th>제목</th>
				<th>작성일</th>
			</tr>
		</thead>
		<tbody>
		<%
			for(Board b : boardList) {
		%>
			<tr>
				<td><%=b.getLocalName()%></td>
				<td>
					<a href="<%=request.getContextPath()%>/board/boardOne.jsp?boardNo=<%=b.getBoardNo()%>">
						<%=b.getBoardTitle()%>
					</a>
				</td>
				<td><%=b.getCreatedate()%></td>
			</tr>
		<%		
			}
		%>
		</tbody>	
	</table>
 
	</div>
	<!---[끝]boardList--------------------------------------------------->
	
	<!-- 페이지네이션 -->
	<div class="text-center">
	<%
		// '이전'은 현재 페이지가 1보다 클때만 보여준다
		if(currentPage > 1) {
	%>
			<a href="./home.jsp?localName=<%=localName%>&currentPage=<%=currentPage-1%>"
				class="btn btn-light">이전</a>
	<%		
		}
	%>
			<%=currentPage%>페이지
	<%	
		// '다음'은 마지막페이지 전까지만 보여준다
		if(currentPage < lastPage) {	
	%>
			<a href="./home.jsp?localName=<%=localName%>&currentPage=<%=currentPage+1%>" 
				class="btn btn-light">다음</a>
	<%
		}
	%>
	<br>
		마지막 페이지 <%=lastPage%>
	</div>
	
	<!-- include 페이지 : Copyright &copy; 구디아카데미 -->
	<div>
		<jsp:include page="/inc/copyright.jsp"></jsp:include>
	</div>
</body>
</html>