CREATE OR REPLACE PROCEDURE InsertEnroll(sStudentId IN VARCHAR2,
  sCourseId IN VARCHAR2,
  nCourseIdNo IN NUMBER, result  OUT VARCHAR2)
  IS
    too_many_sumCourseUnit  EXCEPTION;
    too_many_courses  EXCEPTION;
    too_many_students  EXCEPTION;
    duplicate_time  EXCEPTION;

    nYear  NUMBER;
    nSemester  NUMBER;

    nCname course.c_name%type;
    nSumCourseUnit  NUMBER;
    nCourseUnit  NUMBER;
    nCnt  NUMBER;
    nTeachMax  NUMBER;

  BEGIN
    result := '';

select c_name
into nCname
from course
where c_no=sCourseId;



nTeachMax:=0;
  DBMS_OUTPUT.put_line('#');
  DBMS_OUTPUT.put_line(sStudentId || '님이 과목번호 ' || sCourseId ||
  ', 분반 ' || TO_CHAR(nCourseIdNo) || '의 수강 등록을 요청하였습니다.');
  /* 년도, 학기 알아내기 */
    nYear := Date2EnrollYear(SYSDATE);
    nSemester := Date2EnrollSemester(SYSDATE);

  /* 에러 처리 1 : 최대학점 초과여부 */
    SELECT SUM(t.c_grade)
    INTO nSumCourseUnit
    FROM   teach t, enroll e
    WHERE  e.s_id = sStudentId and e.year = nYear and
         e.semester = nSemester  and  e.c_name = t.c_name and e.c_no = t.c_no and e.split_no=t.split_no;

    SELECT c_grade
    INTO nCourseUnit
    FROM teach
    WHERE c_no = sCourseId and split_no=nCourseIdNo and t_year=nYear and t_semester=nSemester;

    IF (nSumCourseUnit + nCourseUnit > 18)
    THEN
       RAISE too_many_sumCourseUnit;
    END IF;

  /* 에러 처리 2 : 동일한 과목 신청 여부 */
    SELECT COUNT(*)
    INTO nCnt
    FROM   enroll
    WHERE  s_id = sStudentId and c_no = sCourseId;

    IF (nCnt > 0)
    THEN
       RAISE too_many_courses;
    END IF;

    /* 에러 처리 3 : 수강신청 인원 초과 여부 */
    SELECT t_max
    INTO nTeachMax  
    FROM   teach
    WHERE  t_year= nYear and t_semester = nSemester
   and c_no = sCourseId and split_no= nCourseIdNo;

    SELECT COUNT(*)
    INTO   nCnt
    FROM   enroll
    WHERE  year = nYear and semester = nSemester
           and c_no = sCourseId and split_no = nCourseIdNo;


    IF (nCnt >= nTeachMax)
    THEN
       RAISE too_many_students;
    END IF;

     /* 에러 처리 4 : 신청한 과목들 시간 중복 여부  */
    SELECT COUNT(*)
    INTO   nCnt
    FROM
    (
    SELECT t_time
    FROM teach
    WHERE t_year=nYear and t_semester = nSemester and
          c_no = sCourseId and split_no = nCourseIdNo
    INTERSECT
    SELECT t.t_time
    FROM  teach t, enroll e
    WHERE  e.s_id=sStudentId and e.year=nYear and e.semester = nSemester and
  t.t_year=nYear and t.t_semester = nSemester and
  e.c_name=t.c_name and e.c_no=t.c_no and e.split_no=t.split_no
    );
    IF (nCnt > 0)
    THEN
       RAISE duplicate_time;
    END IF;

 /* 수강 신청 등록 */
    INSERT INTO enroll(S_ID,YEAR,SEMESTER, C_NO,C_NAME,SPLIT_NO)
    VALUES (sStudentId, nYear,nSemester, sCourseId, nCname,nCourseIdNo);
  COMMIT;
    result := '수강신청 등록이 완료되었습니다.';
  EXCEPTION
    WHEN too_many_sumCourseUnit  THEN
   result := '최대학점을 초과하였습니다';
    WHEN too_many_courses   THEN
   result := '이미 등록된 과목을 신청하였습니다';
    WHEN too_many_students  THEN
   result := '수강신청 인원이 초과되어 등록이 불가능합니다';
    WHEN duplicate_time  THEN
   result := '이미 등록된 과목 중 중복되는 시간이 존재합니다';
    WHEN OTHERS THEN
   ROLLBACK;
         result :=nTeachMax;
COMMIT;
END;
/
