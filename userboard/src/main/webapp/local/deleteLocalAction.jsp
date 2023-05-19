<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import = "java.sql.*" %>
<%@ page import = "java.net.*" %>
<%@ page import = "vo.*" %>
<%
/* ------------------------------ 1. 컨트롤러 계층 ------------------------------ */
	
	// 요청분석 : 로그인 되어있을때만, 지역 카테고리 삭제 가능
	
	// 인코딩 처리
	request.setCharacterEncoding("UTF-8");

	// 에러메시지 담을 때 사용할 변수
	String msg = null;
	
	/* 세션 유효성 검사 */ 
	if(session.getAttribute("loginMemberId") == null){
		msg = URLEncoder.encode("로그인 후 이용해 주세요.", "utf-8");
		response.sendRedirect(request.getContextPath() + "/home.jsp");
		return;
	}
	// 유효성 검사 통과하면 변수에 저장
	String memberId = (String)session.getAttribute("loginMemberId");
	// 디버깅
	System.out.println(memberId + " <-- deleteMemberAction 변수 memberId");
	
	
	/* 요청값 유효성검사 */
	if(request.getParameter("deleteLocalName") == null 
			|| request.getParameter("deleteLocalName").equals("")) {
			msg = URLEncoder.encode("지역을 선택해 주세요", "utf-8");
		response.sendRedirect(request.getContextPath()+"/local/deleteLocalForm.jsp?msg=" + msg);
		return;
	}
	
	// 유효성 검사 통과하면 변수에 저장
	String deleteLocalName = request.getParameter("deleteLocalName");
	// 디버깅
	System.out.println(deleteLocalName + " <-- deleteLocalAction deleteLocalName");
	
	/*------------------------------ 2. 모델 계층 -----------------------------*/

	// DB 연결
	String driver = "org.mariadb.jdbc.Driver";
	String dbUrl = "jdbc:mariadb://127.0.0.1:3306/userboard";
	String dbUser = "root";
	String dbPw = "java1234";
	Class.forName(driver);
	Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPw);
	
	// 해당 카테고리를 사용 중인 게시물의 개수
	String useLocalNameSql = "";
	PreparedStatement useLocalNameStmt = null;
	ResultSet useLocalNameRs = null;
	/*
		SELECT COUNT(*) 
		FROM board 
		WHERE local_name = ?
	*/
	useLocalNameSql ="SELECT COUNT(*) FROM board WHERE local_name = ?";
	useLocalNameStmt = conn.prepareStatement(useLocalNameSql);
	// ? 1개
	useLocalNameStmt.setString(1, deleteLocalName);
	
	// 쿼리 실행 결과를 변수에 저장 → 0일 경우 : 해당 카테고리의 게시글 없음 
	useLocalNameRs = useLocalNameStmt.executeQuery();
	int useCnt = 0;
	if(useLocalNameRs.next()){
		useCnt = useLocalNameRs.getInt("count(*)");
	}
	
	// useCnt가 0이 아니면 : 카테고리를 사용하고 있는 게시글이 존재한다는 뜻 → 지역 삭제페이지 재요청
	if( useCnt != 0){
		msg = URLEncoder.encode("해당 카테고리는 사용 중이므로 삭제할 수 없습니다", "utf-8");
		response.sendRedirect(request.getContextPath()+"/local/deleteLocalForm.jsp?msg=" + msg);
		return;
	}
	
	// 지역 이름을 삭제하는 쿼리	
	String deleteLocalSql = "";
	PreparedStatement deleteLocalStmt = null;
	ResultSet deleteLocalRs = null;
	/*
		DELETE FROM local 
		where local_name = ?
	*/
	deleteLocalSql = "DELETE FROM local where local_name = ?";
	deleteLocalStmt = conn.prepareStatement(deleteLocalSql);
	// ? 1개
	deleteLocalStmt.setString(1, deleteLocalName);
	// 디버깅	
	System.out.println(deleteLocalStmt + " <-- deleteLocalAction deleteLocalStmt");
	
	// 영향받은 행의 개수
	int deleteLocalRow = 0;
	deleteLocalRow = deleteLocalStmt.executeUpdate();
	// 지역 삭제 성공 시 : 지역 카테고리 편집 페이지 재요청
	if(deleteLocalRow == 1){
		System.out.println(deleteLocalRow + " <-- deleteLocalRow : 지역 삭제 성공");
		msg = URLEncoder.encode("지역 삭제가 완료되었습니다", "utf-8");
		response.sendRedirect(request.getContextPath() + "/local/category.jsp?msg=" + msg);
		return;
	// 지역 삭제 실패 시 : 지역 삭제페이지 재요청
	} else { 
		System.out.println(deleteLocalRow + " <-- deleteLocalRow : 지역 삭제 실패");
		msg = URLEncoder.encode("지역 삭제에 실패하였습니다", "utf-8");
		response.sendRedirect(request.getContextPath() + "/local/deleteLocalForm.jsp?msg=" + msg);
		return;
	}
%>