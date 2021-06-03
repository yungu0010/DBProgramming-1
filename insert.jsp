<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.sql.*"  %>
<html><head><title>수강신청 입력</title>

<script>
function fff(){
	var search=document.getElementById("SSS");
	var CNO=search.cno.value;
	
	//alert("local함수 cno="+CNO);
	
	location.href="insert.jsp?cno="+CNO;
	
}
</script>
</head>
<body>
<%@ include file="top.jsp" %>
<%   if (session_id==null) response.sendRedirect("login.jsp");  %>

<%
	Connection myConn = null;
	Statement stmt = null;
	java.sql.CallableStatement cstmt=null;
	ResultSet myResultSet = null;
	ResultSet rset;
	ResultSet rs;
	
	String mySQL = "";
	String dburl = "jdbc:oracle:thin:@localhost:1521:xe";
	String user="db1912056";
	String passwd="ss2";
    String dbdriver = "oracle.jdbc.driver.OracleDriver";    
	
    
    try {
		Class.forName(dbdriver);
	    myConn =  DriverManager.getConnection (dburl, user, passwd);
		stmt = myConn.createStatement();	
    } catch(SQLException ex) {
	     System.err.println("SQLException: " + ex.getMessage());
    }
    
    
	String cno=request.getParameter("cno");
	System.out.println("selected cousre ID:"+cno);
	
	if(session_id instanceof String){System.out.println("session아이디는 문자열이다");}
	%>

<form id="SSS" method="POST" action="insert.jsp" width="75%" align="center">
<input type="text" name="cno" value="">
<input type="submit" value="과목아이디검색" onclick="fff()"/>
</form>

<%
if(cno!=""&&cno!=null){
	%>
	<h4>2021년 2학기 과목아이디=<%=cno %> 목록</h4>
	<%
}else {
	%><h4>2021년 2학기 수강신청가능목록</h4><%
}
%>

<table class="enroll_tb" width="75%" align="center" border>
<br>
<tr><th class="enroll_th">교시</th><th class="enroll_th">과목번호</th><th class="enroll_th">분반</th><th class="enroll_th">과목명</th><th class="enroll_th">학점</th>
      <th class="enroll_th">수강신청</th></tr>
	<%
	//검색완료후 빈검색->초기화 else로 가는지 확인
	if(cno!=null&&cno!=""){
		String listsplit="{call cno_search(?,?,?)}";
		cstmt=myConn.prepareCall(listsplit);
		cstmt.registerOutParameter(1,oracle.jdbc.OracleTypes.CURSOR);
		cstmt.setString(2, cno);
		cstmt.setString(3, session_id);
		cstmt.execute();
		rs=(ResultSet) cstmt.getObject(1);//커서결과를 resultset으로 가져오기
		
		if(rs !=null ){
			while(rs.next()){
				String c_no = rs.getString("c_no");  //과목번호
				int split_no = rs.getInt("split_no");	//분반	
				String c_name = rs.getString("c_name");  //과목명
				int grade = rs.getInt("c_grade");	 //학점
				int time= rs.getInt("t_time");	//교시
				
				%>
				<tr>
				  <td class="enroll_td" align="center"><%= time %></td>
				  <td class="enroll_td" align="center"><%= c_no %></td>
				  <td class="enroll_td" align="center"><%= split_no %></td> 
				  <td class="enroll_td" align="center"><%= c_name %></td>
				  <td class="enroll_td" align="center"><%= grade %></td>
				  <td class="enroll_td" align="center"><a id="subscribe" href="insert_verify.jsp?c_no=<%=c_no%>&split_no=<%=split_no%>">신청</a></td>
				</tr>
				<%
		
				
			}
		}
		
	}
	else{
		//mySQL = "select c_no,split_no,c_name,c_grade,t_year,t_semester,t_time from teach where t_year=2021 and t_semester=2 and (c_no,split_no) not in (select e.c_no,e.split_no from enroll e,teach t where s_id='" + session_id + "' and t.split_no=e.split_no') order by t_time";
		mySQL = "select c_no,split_no,c_name,c_grade,t_year,t_semester,t_time from teach where t_year=2021 and t_semester=2 and (c_no,split_no) not in (select e.c_no,e.split_no from enroll e,teach t where s_id='" + session_id + " and t.split_no=e.split_no') order by t_time";
		
		myResultSet = stmt.executeQuery(mySQL);
		if (myResultSet != null) {
			while (myResultSet.next()) {	
				String c_no = myResultSet.getString("c_no");  //과목번호
				int split_no = myResultSet.getInt("split_no");	//분반	
				String c_name = myResultSet.getString("c_name");  //과목명
				int grade = myResultSet.getInt("c_grade");	 //학점
				int time= myResultSet.getInt("t_time");	//교시
		%>
		<tr>
		  <td class="enroll_td" align="center"><%= time %></td>
		  <td class="enroll_td" align="center"><%= c_no %></td>
		  <td class="enroll_td" align="center"><%= split_no %></td> 
		  <td class="enroll_td" align="center"><%= c_name %></td>
		  <td class="enroll_td" align="center"><%= grade %></td>
		  <td class="enroll_td" align="center"><a id="subscribe" href="insert_verify.jsp?c_no=<%=c_no%>&split_no=<%=split_no%>">신청</a></td>
		</tr>
		<%
				}
			}
	}
			stmt.close();  myConn.close();
		%>
		</table></body></html>
