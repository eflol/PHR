<%@ page contentType="text/html;charset=UTF-8"%>
<%@ page import="java.io.PrintWriter"%>
<%
	String p1addr = request.getParameter("p1addr");
  if (p1addr == null)  { p1addr=""; }

%>

<!doctype html>
<html>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<script type="text/javascript" src="./js/bignumber.min.js"></script>
<script type="text/javascript" src="./js/web3.js"></script>

<!-- jQuery (necessary for Bootstrap's JavaScript plugins) -->
<script src="./js/jquery.min.1.12.4.js"></script>
<script src="./js/bootstrap.min.js"></script>
<script src="./js/truffle-contract.js"></script>
<script src="./js/app.js"></script>

<link rel="stylesheet" type="text/css" href="./css/w3.css">
<link rel="stylesheet" type="text/css" href="./css/Roboto.css">
<link rel="stylesheet" type="text/css" href="./css/Lato.css">
<script type="text/javascript">


function search() {
  try
  {

    p1addr = $('#p1addr').val();    
    App.PHRInstance.getPerson(p1addr).then(function(scaddr) { 
      $.getJSON('../build/contracts/Person.json', function(data) {
        // Get the necessary contract artifact file and instantiate it with truffle-contract
        App.PersonArtifact = data;
        App.contracts.Person = TruffleContract(App.PersonArtifact);

        // Set the provider for our contract
        App.contracts.Person.setProvider(App.web3Provider);

        // 스마트컨트렉트의 주소를 가져온 person 주소로 변경
        App.contracts.Person.at(scaddr).then(function(instance) { 
          App.PersonInstance = instance; 
          //App.PersonInstance.contract.address  = scaddr;
          App.PersonInstance.getName().then(function(pData) {
            $('#name').val(pData);
          });
          App.PersonInstance.getBirth().then(function(pData) {
            $('#birth').val(pData);
          });
          App.PersonInstance.getRegistNum().then(function(pData) {
            $('#registNum').val(pData);
          });
          App.PersonInstance.getGender().then(function(pData) {
            $('#gender').val(pData);
          });
        });
      });
    });
    
    delete_all();
    App.PHRInstance.getMRLength(p1addr).then(function(len) {
      //alert(len);
      var my_tbody = document.getElementById('my-tbody');
      // var row = my_tbody.insertRow(0); // 상단에 추가
      for(i = 0; i < len; i++) {
        var row = my_tbody.insertRow( my_tbody.rows.length ); // 하단에 추가
        var cell1 = row.insertCell(0);
        var cell2 = row.insertCell(1);
        var cell3 = row.insertCell(2);
        var cell4 = row.insertCell(3);
        var cell5 = row.insertCell(4);
        var cell6 = row.insertCell(5);
        var cell7 = row.insertCell(6);
        cell1.id = ""+i+"."+"1";
        cell2.id = ""+i+"."+"2";
        cell3.id = ""+i+"."+"3";
        cell4.id = ""+i+"."+"4";
        cell5.id = ""+i+"."+"5";
        cell6.id = ""+i+"."+"6";
        cell7.id = ""+i+"."+"7";
      }

      if (len > 0)
      {
        App.PHRInstance.getPersonIdx(p1addr).then(function(pIdx) {
          //alert(pIdx);
          /*********************
          처치일시 : getMRtreatDate(uint idx)
          병원명   : getMRmedOrgAddr(uint idx).
          진료과   : getMRdepart(uint idx)
          진료의   : getMRmedStaff(uint idx)
          자료구분 : getMRclsData(uint idx) 
          첨부조회 : getMRattachKey

          <td>2018/09/04</td>
          <td>여의도성모병원</td>
          <td>가정의학과</td>
          <td>박성광</td>
          <td>X레이</td>
          <td><a href="">조회</a></td>
          function getMRmedOrgAddr(uint pPsIdx,uint pMRIdx) public constant returns(uint, address){return (pMRIdx, persons[pPsIdx].getMRmedOrgAddr(pMRIdx));}
          *********************/


          for(i = 0; i < len; i++) {
            App.PHRInstance.getMRtreatDate(pIdx, i).then(function(data) {
              //alert(data[0]);
              //alert(data.length);
              //alert(bin2string(data[1]));
              // data[0]에는 1번째인자가, data[1]에는 2번째인자가 byte배열로 리턴된다.
              var cell = document.getElementById(data[0]+'.1');
              //cell.innerHTML = bin2string(data[1]);
              cell.innerHTML = (data[1]);
            });

            App.PHRInstance.getMRmedOrgName(pIdx, i).then(function(data) {
              var cell = document.getElementById(data[0]+'.2');
              //cell.innerHTML = bin2string(data[1]);
              cell.innerHTML = (data[1]);
            });

            App.PHRInstance.getMRdepart(pIdx, i).then(function(data) {
              var cell = document.getElementById(data[0]+'.3');
              //cell.innerHTML = bin2string(data[1]);
              cell.innerHTML = (data[1]);
            });

            App.PHRInstance.getMRmedStaff(pIdx, i).then(function(data) {
              var cell = document.getElementById(data[0]+'.4');
              //cell.innerHTML = bin2string(data[1]);
              cell.innerHTML = (data[1]);
            });

            App.PHRInstance.getMRclsData(pIdx, i).then(function(data) {
              var cell = document.getElementById(data[0]+'.5');
              //cell.innerHTML = bin2string(data[1]);
              cell.innerHTML = (data[1]);
            });

            App.PHRInstance.getMRattachKey(pIdx, i).then(function(data) {
              //var attachKey = bin2string(data[1]);
              var attachKey = (data[1]);

              var cell = document.getElementById(data[0]+'.6');
              cell.innerHTML = cell.innerHTML + '<u onclick="winOpen(\''+attachKey.substring(0,64)+'\');">(보기)</u><input type="hidden" id="attachKey'+data[0]+'.3" name="attachKey" value="'+ attachKey.substring(0,64) +'">';

            });

            App.PHRInstance.getMRdiseaseCode(pIdx, i).then(function(data) {
              var cell = document.getElementById(data[0]+'.7');
              //cell.innerHTML = bin2string(data[1]);
              cell.innerHTML = (data[1]);
            });

          }
        });
      }
    });
  }
  catch (e)
  {
    logs(e);
  }
}

function winOpen(bzzurl) {
    var tempUrl = "http://localhost:8500/bzz:/" + bzzurl;
    var option = "toolbar=no,width=500,height=500,scrollbars,menubar=no,location=no";

    window.open(tempUrl, "첨부문서", option);
}

function bin2string(uintArray) {
    var encodedString = String.fromCharCode.apply(null, uintArray);
    var decodedString = decodeURIComponent(escape(encodedString));
    //alert("encodedString " + encodedString);
    //alert("decodedString " + decodedString);
    return decodedString;
}

function delete_row() {
  var my_tbody = document.getElementById('my-tbody');
  if (my_tbody.rows.length < 1) return;
  // my_tbody.deleteRow(0); // 상단부터 삭제
  my_tbody.deleteRow( my_tbody.rows.length-1 ); // 하단부터 삭제
}

function delete_all() {
  var my_tbody = document.getElementById('my-tbody');
  var length = my_tbody.rows.length;
  for (i = 0; i < length; i++)
  {
    my_tbody.deleteRow( my_tbody.rows.length-1 ); // 하단부터 삭제
  }
}

function medi_upload() {
  /*
환 자 명 : 홍길동
생년월일 : 1976-07-07
진 료 과 : 내과
진 료 의 : 박성광
진 료 일 : 2018-09-14
상병코드 : T78.4
개인계정 : 0xc5fdf4076b8f3a5357c5e395ab970b5b54098fef
  */
  var infoMsg = "";
  infoMsg = infoMsg + "의무기록 업로드 화면 전환" + "\n";
  infoMsg = infoMsg + "                         " + "\n";
  try
  {
    var custcell1 = $('#p1addr').val();

    var my_tbody = document.getElementById('my-tbody');
    var length = my_tbody.rows.length;
    for(i = 0; i < 1; i++) {
      var cell1 = document.getElementById(i+'.1'); // 처치일
      var cell2 = document.getElementById(i+'.2'); // 병원명
      var cell3 = document.getElementById(i+'.3'); // 진료과
      var cell4 = document.getElementById(i+'.4'); // 진료의
      var cell5 = document.getElementById(i+'.5'); // 자료구분
      var cell7 = document.getElementById(i+'.7'); // 상병코드

      //if (cell4val == true)
      {
        infoMsg = infoMsg + "환 자 명 : " + $('#name').val() + "\n";
        infoMsg = infoMsg + "생년월일 : " + $('#birth').val() + "\n";
        infoMsg = infoMsg + "진 료 과 : " + cell3.innerHTML + "\n";
        infoMsg = infoMsg + "진 료 의 : " + cell4.innerHTML + "\n";
        infoMsg = infoMsg + "진 료 일 : " + App.today + "\n";
        //infoMsg = infoMsg + "상병코드 : " + cell7.innerHTML + "\n";
        infoMsg = infoMsg + "개인계정 : " + $('#p1addr').val() + "\n";
        infoMsg = infoMsg + "=====================================" + "\n";
      }
    }
    
  }
  catch (e)
  {
    null;
  }
  alert(infoMsg);
  location.href="DP2medi_upload.jsp?name="+$('#name').val() +"&birth="+$('#birth').val() +"&p1addr="+$('#p1addr').val();
}

function batch() {
  var infoMsg = "";
  infoMsg = infoMsg + "의무기록 배치 업로드 수행" + "\n";
  alert(infoMsg);
}
</script>
<style>

body {
  font-family: "Roboto";
}

.panel2 {
  margin-top: 10px;
  margin-bottom: 10px;
  float: right;
  right: 3%;
  position: relative;
  text-align: center;
  opacity: 0.72;
  width: 95%
}

th {
  vertical-align: middle !important; 
}

td {
  text-align: left;
  border: 1px solid #888888;
  vertical-align: middle !important; 
  }


</style>
<body>
  <div class="panel2">
    <div class="w3-card-2 w3-container">    
      <div class="w3-row-padding w3-center">  
      <h3 class="w3-left">의료기관 시스템</h3>
      <table class="w3-table" style="background-color: #eeeeee;">
        <tr>
          <td width=120> SC주소 </td>
          <td><input type="text" id="scAddr" size="10" >
          </td>
          <td> 개인계정 </td>
          <td><input type="text" id="p1addr" size="10" value="<%=p1addr%>"/><input type="button" value="개인조회" onclick="search()"></td>
        </tr>
        <tr>
          <td width=120> 병원계정 </td>
          <td><input type="text" id="medOrgAddr" value="">
          </td>
          <td width=120> Pass </td>
          <td><input type="password" id="medOrgpass" value="lap243lap" size="10"></td>
        </tr>
      </table>
      <br>
      </div>
    </div>
  </div>
  <div class="panel2">
    <div class="w3-card-2 w3-container" style="min-height:100px">    
      <div class="w3-row-padding w3-center w3-margin-top">  
        <table class="w3-table-all w3-card-4">
          <thead>
            <tr class="w3-black">
              <th colspan="8">진료 내역</th>
            </tr>
          </thead>        
        </table>            
        <table  class="w3-table" style="background-color: #eeeeee;">
            <tr >
              <td width=100> 성&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 명</td>
              <td><input type="text" id="name" class="w3-input w3-border w3-grey" value="" size="2"></td>
              <td width=100>생년월일</td>
              <td><input type="text" id="birth" class="w3-input w3-border w3-grey" value="" size="2"></td>
            </tr>
            <tr >
              <td>주민번호</td>
              <td><input type="text" id="registNum" class="w3-input w3-border w3-grey" value="" size="2"></td>
              <td> 성&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 별</td>
              <td><input type="text" id="gender" class="w3-input w3-border w3-grey" value="" size="2"></td>
            </tr>
        </table>            
        <br>
        <br>
        <table class="w3-table-all w3-card-4">
          <thead>
            <tr class="w3-dark-grey">
              <td>처치일시</td>
              <td>병원명</td>
              <td>진료과</td>
              <td>진료의</td>
              <td>자료구분</td>
              <td>첨부문서</td>
              <td>상병코드</td>
            </tr>
          </thead>
          <tbody id="my-tbody">
            <!--tr>
              <td>2018/09/04</td>
              <td>여의도성모병원</td>
              <td>가정의학과</td>
              <td>박성광</td>
              <td>X레이</td>
              <td><a href="">조회</a></td>
            </tr>
            <tr>
              <td>2018/09/04</td>
              <td>여의도성모병원</td>
              <td>가정의학과</td>
              <td>박성광</td>
              <td>소견서</td>
              <td><a href="">조회</a></td>
            </tr>
            <tr>
              <td>2018/09/04</td>
              <td>여의도성모병원</td>
              <td>가정의학과</td>
              <td>박성광</td>
              <td>진단서</td>
              <td><a href="">조회</a></td>
            </tr>
            <tr>
              <td>2018/09/04</td>
              <td>여의도성모병원</td>
              <td>가정의학과</td>
              <td>박성광</td>
              <td>진료비영수증</td>
              <td><a href="">조회</a></td>
            </tr-->
          </tbody>
        
        </table>            
        <!-- 개인블록체인ID -->  
        <br>
        <table  class="w3-table">
            <tr >
              <th style="vertical-align: middle;">&nbsp;</th>
              <th class="w3-right">
              <input type="button" class="w3-btn w3-white w3-border w3-border-dark-grey w3-round-large" id="btnBatch" value="일괄 등록" onClick="batch()">
              <input type="button" class="w3-btn w3-white w3-border w3-border-dark-grey w3-round-large" id="btnUpload" value="의무기록 업로드" onClick="medi_upload()"></th>
            </tr>
        </table>           
        <br><br>
        <div id="messages"></div>
        <div id="logs" style="text-align: left;"></div>

      </div>
    </div>
  </div>
  
</body>
</html>