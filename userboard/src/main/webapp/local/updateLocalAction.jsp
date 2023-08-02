<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import = "java.sql.*" %>
<%@ page import = "java.net.*" %>
<%@ page import = "vo.*" %>
<%
/* ------------------------------ 1. 컨트롤러 계층 ------------------------------ */
	
	// 요청분석 : 로그인 되어있을때만, 지역 카테고리 수정 가능
	
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
	System.out.println(memberId + " <-- updateMemberAction 변수 memberId");
	
	
	/* 요청값 유효성검사 */
	if(request.getParameter("currentLocalName") == null 
		|| request.getParameter("currentLocalName").equals("")) {
		msg = URLEncoder.encode("지역을 선택해 주세요", "utf-8");
	} else if (request.getParameter("updateLocalName") == null 
		|| request.getParameter("updateLocalName").equals("")) {
		msg = URLEncoder.encode("지역을 입력해 주세요", "utf-8");
	}
	if(msg != null) {
		response.sendRedirect(request.getContextPath()+"/local/updateLocalForm.jsp?msg=" + msg);
		return;
	}
	
	// 유효성 검사 통과하면 변수에 저장
	String currentLocalName = request.getParameter("currentLocalName");
	String updateLocalName = request.getParameter("updateLocalName");
	// 디버깅
	System.out.println(currentLocalName + " <-- updateLocalAction currentLocalName");
	System.out.println(updateLocalName + " <-- updateLocalAction updateLocalName");
	
	if (currentLocalName.equals(updateLocalName)) {
		msg = URLEncoder.encode("기존과 다른 지역을 입력해 주세요", "utf-8");
		response.sendRedirect(request.getContextPath() + "/local/updateLocalForm.jsp?msg=" + msg);
		return;
	}
	
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
	useLocalNameStmt.setString(1, currentLocalName);
	
	// 쿼리 실행 결과를 변수에 저장 → 0일 경우 : 해당 카테고리의 게시글 없음 
	useLocalNameRs = useLocalNameStmt.executeQuery();
	int useCnt = 0;
	if(useLocalNameRs.next()){
		useCnt = useLocalNameRs.getInt("count(*)");
	}
	
	// useCnt가 0이 아니면 : 카테고리를 사용하고 있는 게시글이 존재한다는 뜻 → 지역 수정페이지 재요청
	if(useCnt != 0){
		msg = URLEncoder.encode("해당 카테고리는 사용 중이므로 수정할 수 없습니다", "utf-8");
		response.sendRedirect(request.getContextPath()+"/local/updateLocalForm.jsp?msg=" + msg);
		return;
	}
	
	
	// updateLocalName이 이미 존재하는지 확인하는 쿼리
	String checkLocalNameSql = "";
	PreparedStatement checkLocalNameStmt = null;
	ResultSet checkLocalNameRs = null;
	/*
		SELECT COUNT(*) 
		FROM local 
		WHERE local_name = ?
	*/
	checkLocalNameSql = "SELECT COUNT(*) FROM local WHERE local_name = ?";
	checkLocalNameStmt = conn.prepareStatement(checkLocalNameSql);
	checkLocalNameStmt.setString(1, updateLocalName);
	checkLocalNameRs = checkLocalNameStmt.executeQuery();

	// 이미 존재하는 경우
	if (checkLocalNameRs.next()) {
	    int count = checkLocalNameRs.getInt(1);
	    if (count > 0) {
	        msg = URLEncoder.encode("이미 존재하는 지역입니다.", "utf-8");
	        response.sendRedirect(request.getContextPath() + "/local/updateLocalForm.jsp?msg=" + msg);
	        return;
	    }
	}

	
	// 지역 이름을 수정하는 쿼리	
	String updateLocalSql = "";
	PreparedStatement updateLocalStmt = null;
	ResultSet updateLocalRs = null;
	/*
		UPDATE local
		SET local_name = ?
		WHERE local_name = ?
	*/
	updateLocalSql = "UPDATE local SET local_name = ?, updatedate = NOW() WHERE local_name = ?";
	updateLocalStmt = conn.prepareStatement(updateLocalSql);
	// ? 2개
	updateLocalStmt.setString(1, updateLocalName);
	updateLocalStmt.setString(2, currentLocalName);
	// 디버깅	
	System.out.println(updateLocalStmt + " <-- updateLocalAction updateLocalStmt");
	
	// 영향받은 행의 개수
	int updateLocalRow = 0;
	updateLocalRow = updateLocalStmt.executeUpdate();
	// 지역 수정 성공 시 : 지역 카테고리 편집 페이지 재요청
	if(updateLocalRow == 1){
		System.out.println(updateLocalRow + " <-- updateLocalRow : 지역 수정 성공");
		msg = URLEncoder.encode("지역 수정이 완료되었습니다", "utf-8");
		response.sendRedirect(request.getContextPath() + "/local/category.jsp?msg=" + msg);
		return;
	// 지역 수정 실패 시 : 지역 수정페이지 재요청
	} else { 
		System.out.println(updateLocalRow + " <-- updateLocalRow : 지역 수정 실패");
		msg = URLEncoder.encode("지역 수정에 실패하였습니다", "utf-8");
		response.sendRedirect(request.getContextPath() + "/local/updateLocalForm.jsp?msg=" + msg);
		return;
	}
%>