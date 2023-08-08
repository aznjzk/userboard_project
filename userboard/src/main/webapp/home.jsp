<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import = "java.sql.*" %>
<%@ page import = "java.net.*" %>
<%@ page import = "java.util.*" %>
<%@ page import = "vo.*" %>
<%
	// 인코딩 처리
	request.setCharacterEncoding("UTF-8");

	// ANSI CODE	
	final String RESET = "\u001B[0m"; 
	final String BG_YELLOW = "\u001B[43m";
	final String BG_BLUE = "\u001B[44m";
	final String BG_PURPLE = "\u001B[45m";
	final String BG_CYAN = "\u001B[46m";
	final String CYAN = "\u001B[36m";
	
/*------------------------------ 1. 요청분석(컨트롤러 계층) -----------------------------*/
	
	// 현재 로그인 사용자의 Id
	String loginMemberId = (String)session.getAttribute("loginMemberId");;

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
	int rowPerPage = 5;		// 페이지당 출력할 행의 개수 (디폴트 값 5)
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
	
	/*
	pagePerPage = 10 일때
		
		currentPage	  minPage		  maxPage
			 1			 1				10
			13			11				20
			29			21				30	
	*/
		
	// 하단 페이지목록 : 한 번에 보여줄 페이지의 개수
	int pagePerPage = 10;
	// 페이지 목록 중 가장 작은 숫자의 페이지
	int minPage = ((currentPage - 1) / pagePerPage ) * pagePerPage + 1;
	// 페이지 목록 중 가장 큰 숫자의 페이지
	int maxPage = minPage + (pagePerPage - 1);
	// maxPage 가 last Page보다 커버리면 안되니까 lastPage를 넣어준다
	if (maxPage > lastPage){
		maxPage = lastPage;
	}
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>homeCSS</title>
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
	
	<!-- Page header with logo and tagline-->
	<header class="py-5 bg-image border-bottom mb-4">
	   	<div class="container">
	       	<div class="text-center my-5">
	            <h1 class="fw-bolder hfont">Welcome to Blog Home!</h1>
	            <p class="lead mb-0 pfont">프로젝트 개요 : 여행 게시판 블로그형식으로 어쩌구 저쩌구 </p>
	            <p class="lead mb-0 pfont">담당 기능 : 페이징, 게시판출력, 카테고리별 조회, 검색 기능</p>
	            <p class="lead mb-0 pfont">개발 내용 : 모델1 방식을 사용하여 여행블로그 구현</p>
	            <p class="lead mb-0 pfont">쇼핑몰 내에서 관리자, 회원, 비회원의 기능별 차등 부여</p>
	            <p class="lead mb-0 pfont">관리자는 상품, 주문상태, 문의, 리뷰관리, 고객리스트조회, 직원관리 가능</p>
	            <p class="lead mb-0 pfont">A Bootstrap 5 starter layout for your next blog homepage</p>
	            <p class="lead mb-0 pfont">개발 환경 : SQL, JavaScript Library JQuery, BootStrap4 Database MariaDB</p>
	            <p class="lead mb-0 pfont">A Bootstrap 5 starter layout for your next blog homepage</p>
	        </div>
	    </div>
	</header>
	
	<!-- Page content-->
	<div class="container">
		<div class="row">
	        <!-- Side widgets-->
			<div class="col-lg-3">
			
			<!-- login widget : 로그인 폼 -->
			<%
				if(session.getAttribute("loginMemberId") == null) {  // 로그인을 하지 않은 경우에만 로그인폼 출력
			%>
				<div class="card mb-4">
				<div class="card-header hfont">login</div>
					<div class="card-body pfont">
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
							
							<!-- 오류 메시지 -->
							<div class="d-flex justify-content-center text-danger pfont">
							<%
								if(request.getParameter("idMsg") != null){
							%>
									<%=request.getParameter("idMsg")%>
							<%
								}
							%>
							</div>
							
							<div class="d-flex justify-content-center pfont">
								<button class="btn btn-secondary center" type="submit">로그인</button>
							</div>
						</form>
					</div>
				</div>
			<%   
				} else { // 로그인에 성공한 경우
				loginMemberId = (String)(session.getAttribute("loginMemberId"));
			%>
				<div class="card mb-4">
					<div class="text-center pfont">
						<br>
						<p><%=loginMemberId%>님 환영합니다&#128075;&#127995;</p>
							<a class="btn btn-outline-secondary" href="<%=request.getContextPath()%>/member/userInformation.jsp">회원정보</a>
							<a class="btn btn-secondary" href="<%=request.getContextPath()%>/member/logoutAction.jsp">로그아웃</a>
						<br> &nbsp;
					</div>
				</div>
			<%		
				}
			%>
                    
				<!-- Categories widget : 서브메뉴(세로) subMenuList1모델 출력 -->
				<div class="card mb-4">
					<div class="card-header hfont">
					<%
						if(localName == null || localName.equals("전체")) {
					%>
							Categories
					<%
						} else {
					%>
							Categories : <%=localName%>
					<%
						}
					%>
					</div>
					<div class="card-body">
						<ul class="list-unstyled mb-0 pfont">
						<%
							for(HashMap<String, Object> m : subMenuList) {
						%>
						<li>
							<a href="<%=request.getContextPath()%>/home.jsp?localName=<%=(String)m.get("localName")%>" class="aa">
								<%=(String)m.get("localName")%>(<%=(Integer)m.get("cnt")%>)
							</a>
						</li>
						<%		
							}
						%>
						</ul>
					</div>
				</div>
			
				<!-- Search widget-->
				<div class="card mb-4">
					<div class="card-header hfont">Search</div>
					<div class="card-body">
						<div class="input-group pfont">
							<input class="form-control" type="text" placeholder="Enter search term..." aria-label="Enter search term..." aria-describedby="button-search" />
							<button class="btn btn-secondary" id="button-search" type="button">Go!</button>
						</div>
					</div>
				</div>
			</div>
					
			<!-- Blog entries-->
			<div class="col-lg-9">
			<table class="table" frame="void" >
				<tr>
					<td>
						<div class="d-flex justify-content-between align-items-center">
							<h2 class="hfont"><%=localName%>글보기</h2>
							
							<!-- 오류 메시지 -->
							<p class="d-flex justify-content-center text-danger pfont">
							<%
								if(request.getParameter("msg") != null){
							%>
									<%=request.getParameter("msg")%>
							<%
								}
							%>
							</p>
							
							<!-- 글쓰기 버튼 -->
							<%	// 로그인되어있을때만 글쓰기 허용 
								if(loginMemberId != null) { 
							%>
								<div class="pfont">
									<a href="<%=request.getContextPath()%>/board/insertBoardForm.jsp" class="btn btn-secondary" type="button">글쓰기</a>
								</div>
							<%
								}
							%>
						</div>
					</td>
				</tr>
				<tr>
					<td>
					<%
						for(Board b : boardList) {
					%>
						<!-- Featured blog post-->
						<div class="card mb-4">
						    <div class="card-body">
						        <div class="small text-muted pfont"><%=b.getLocalName()%> | <%=b.getCreatedate()%></div>
								<br>
								<h2 class="card-title hfont"><%=b.getBoardTitle()%></h2>
								<p class="card-text pfont"><%=b.getBoardContent()%> . . . <a href="<%=request.getContextPath()%>//board/boardOne.jsp?boardNo=<%=b.getBoardNo()%>" class="aa">더보기</a></p>
						    </div>
						</div>
					<%		
						}
					%> 
					</td>
				</tr>
			</table>
	    	</div>
	    </div>
	    
		<!-- Pagination -->		
		<div>
			<nav aria-label="Pagination">
			<hr class="my-0" />
				<ul class="pagination justify-content-center my-4 pfont">
				<%
					if(minPage != 1) {
				%>
					<li class="page-item active" aria-current="page"><a class="page-link" href="./home.jsp?localName=<%=localName%>&currentPage=<%=minPage-pagePerPage%>">Newer</a></li>
				<%
					} else { // 1페이지에서는 이전버튼 비활성화
				%>
					<li class="page-item disabled"><a class="page-link" href="./home.jsp?localName=<%=localName%>&currentPage=<%=minPage-pagePerPage%>">Newer</a></li>
				<%
					}
				
					for(int i = minPage; i <= maxPage; i++) {
						if(i != currentPage) {
				%>    
					<li class="page-item"><a class="page-link" href="./home.jsp?localName=<%=localName%>&currentPage=<%=i%>"><%=i%></a></li>
				<%
						} else { // 현재페이지에서는 버튼 비활성화
				%>
					<li class="page-item disabled">
						<span class="page-link" tabindex="-1" aria-disabled="true"><%=i%></span>
					</li>
				<%
						}
					}
				
					if(maxPage != lastPage) {
				%>
						<li class="page-item active"><a class="page-link" href="./home.jsp?localName=<%=localName%>&currentPage=<%=maxPage+1%>">Older</a></li>
				<%
					} else { // 마지막 페이지에서는 다음버튼 비활성화
				%>
						<li class="page-item disabled" aria-current="page"><a class="page-link" href="./home.jsp?localName=<%=localName%>&currentPage=<%=maxPage+1%>">Older</a></li>
				<%
					}
				%>
				</ul>
			</nav>
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