j1.son@SDS-DIS-15776 MINGW64 /c/project/functions-manager (feature-set_headers_in_function)
$ git diff develop..feature-set_headers_in_function|cat
diff --git a/.github/CODEOWNERS b/.github/CODEOWNERS
deleted file mode 100644
index 15e02cb..0000000
--- a/.github/CODEOWNERS
+++ /dev/null
@@ -1,5 +0,0 @@
-# 모든 file에 대한 code owners 지정
-* @bluefriday @gyeongyeol @jeongwonson @cloudpark
-
-# java file에 대한 code owners 지정
-*.java @bluefriday @gyeongyeol @jeongwonson @cloudpark
diff --git a/.github/ISSUE_TEMPLATE/github-issue-template.md b/.github/ISSUE_TEMPLATE/github-issue-template.md
index 73a2d39..b1c86bb 100644
--- a/.github/ISSUE_TEMPLATE/github-issue-template.md
+++ b/.github/ISSUE_TEMPLATE/github-issue-template.md
@@ -7,14 +7,13 @@ assignees: ''

 ---

-## 이슈 내용
->
-
-
-
-
-## 기타
->
+## 목적
+>

+## 작업 상세 내용
+- [ ] 상세1

+## 참고 사항
+- [ ] 예시

+## 연관 브랜치 이름
\ No newline at end of file
diff --git a/.github/pull_request_template.md b/.github/pull_request_template.md
index 956103b..409362b 100644
--- a/.github/pull_request_template.md
+++ b/.github/pull_request_template.md
@@ -1,21 +1,11 @@
-## PR 개요
-// 이 PR의 목적은 무엇인지 혹은 왜 이 PR이 필요한지 기재
+## 연관 이슈
+이슈번호 : (없으면 n/a)

+## PR 체크리스트
+다음 항목을 모두 만족하는지 한번 더 확인해주세요.

+- [ ] 어떤 배경으로 해당 Branch가 생성되었는지 충분한 설명이 있습니까?
+- [ ] 해당 내용에 대해 충분히 테스트가 되었나요?

-## 개발 내용
-// 실제 어느 부분을 작업했는지 기재
-
-
-
-## 작업 전 결과
-// 이전에는 어떻게 동작했었는지
-
-
-
-## 작업 후 결과
-// 이후에는 어떻게 동작하는지
-
-
-
-## 기타
\ No newline at end of file
+## PR 요청내용
+내용 기입
diff --git a/CODEOWNERS b/CODEOWNERS
new file mode 100644
index 0000000..e8d8ac0
--- /dev/null
+++ b/CODEOWNERS
@@ -0,0 +1,5 @@
+# 모든 file에 대한 code owners 지정
+* @bluefriday @gyeongyeol @jeongwonson
+
+# java file에 대한 code owners 지정
+*.java @bluefriday @gyeongyeol @jeongwonson @jmyung
\ No newline at end of file
diff --git a/README.md b/README.md
index c5dcd07..d448d26 100644
--- a/README.md
+++ b/README.md
@@ -4,56 +4,26 @@ SCP Functions Service manager module
 환경 구성 참조링크
 https://devops.sdsdev.co.kr/confluence/x/zBukH

-## Cloud Functions🧑‍💻
-* 이희창(팀장)👍
-* 손정원👍
-* 최경열👍
-* 박운한👍
-
-## 그라운드 룰📄
-### GIT BRANCH 전략💯
-1. 개발하기 전 "Issue" 페이지에 개발 내용 정리하고 개발 진행하기
-2. "main" 브랜치에서 직접 개발하지 않고 브랜치 신규 생성하여 로컬 리파지토리에서 작업하기
-3. 테스트코드를 적극 활용하여 개발 내용 검증하기
-4. 테스트 완료된 신규 브랜치는 "main" 브랜치에 merge 전 팀원들에게 PR 요청하기
-5. merge 완료된 신규 브랜치는 삭제하기
-
-### COMMIT 전략💯
-1. Commit 은 의미있는 최소한의 기능 단위로 수행하기
-2. Commit 메세지는 팀원들이 이해 가능할 수 있는 메세지로 요약하여 작성하기
-3. Commit 전에 코드 포맷팅을 활용하여, 가독성을 향상 시키고, Confilct 를 최소화 하기
-
-### PR 전략💯
-1. 관련 Issue 1개당 1개 PR로 개발하기
-2. PR에 대한 내용 작성 시 PR 템플릿을 활용하여 자세히 내용 기술하기
-3. PR 생성 시 Label을 사용하여 어떤 유형의 PR인지 표기하기
-   - 새 기능 : Feature✨
-   - 리팩토링 : Refacotring♻️
-   - 테스트 : Test✅
-   - 버그 수정 : Bugfix🐛
-   - 긴급 수정 : Hotfix🚑
-   - 보안이슈 반영 : Security🔒
-   - 성능 개선 : Performance⚡️
-   - 문서 추가/수정 : Documentation📝
-   - 코드/파일 삭제 : Remove🔥
-   - 변경내용 되돌리기 : Rewind⏪
-   - 브랜치 합병 : Merge🔀
-4. PR은 되도록 단일 기능에 관한 수정으로 하기
-5. PR 생성 후 팀원들에게 메신저 통해 PR 검토요청하기
-
-### MERGE 전략💯
-1. PR에 대한 merge승인 수는 2명
-2. merge 충돌 시 마지막 코드 담당자와 상의 후 merge 처리하기
-
-### 코드리뷰 전략💯
-1. 모든 리뷰어와 요청자는 수평적이고 동등한 위치를 가진다고 생각하기
-2. 형식적으로 코드리뷰를 하지않고 수정한 부분에 대해 꼼꼼히 확인하고 코멘트하기
-3. 리뷰 요청에 대해서 가급적 당일에 코드리뷰 해주기 (늦어도 다음날까지 진행하되 PR생성 후 24시간 이내 진행하기)
-4. 리뷰 작성 시 이모지를 적극적으로 활용하기 (gitmoji | An emoji guide for your commit messages)
-5. 리뷰어는 퇴근 1시간 전 혹시 모를 코드리뷰가 있는지 확인하기
-6. 생각이 다른 내용이나 잘못된 내용이라도 비판이나 비난보다는 칭찬과 격려로 코멘트시작 후 대안 제시하기
-7. commit 메세지 및 PR내용은 의미있고 이해하기 쉽게 자세히 작성하기
-8. 리뷰어가 제안한 사항에 대한 반영여부는 요청자가 결정하기
+## Cloud Functions
+* 이희창(팀장)
+* 손정원
+* 최경열
+* 명제상 (코드리뷰어)
+* 박운한
+
+## 그라운드 룰
+1. 코드리뷰시, 서로를 존중하는 말 사용하기.
+2. 테스트 커버리지는 최소 70%는 달성한다.
+3. 코드 push 전, 빌드 및 단위 테스트를 수행한다.
+4. 코드 push 전 항목별 SAM지표 4.0 이상을 확인한다.
+5. 리팩토링 목적의 PR인 경우, 회귀(Regression) 테스트를 반드시 수행한다. (추가로 가능하다면 Junit Test를 생성)
+6. 소스 로직이나 기술 내용에 대하여, Git comment로 질문과 답변을 주고 받아 과제원들이 공유하기 쉽게 한다.
+7. 리뷰어로 할당 최대한 빠른 시간 내에 리뷰를 수행하여, PR요청자가 머지할 수 있도록 돕는다. 단, 리뷰를 수행할 수 없는 상황에서는 리뷰어 해제하고, 코멘트를 남긴다.     
+
+## Git Branch, PR, Merge 정책
+1. Git flow 기반 branch 정책을 사용하며, 이중 development, feature, bugfix 를 사용하며, release branch는 제외한다.
+2. development는 2명이상 approve, master는 1명이상 approve 되면 merge한다.
+3. feature branch는 merge 완료 후 삭제한다.

 ## 코딩스타일, 컨벤션 40
-* CoCook 코딩 스타일(Java) 을 따른다. https://devops.sdsdev.co.kr/confluence/display/SPC/Coding+Style
+* CoCook 코딩 스타일을 따른다. https://devops.sdsdev.co.kr/confluence/display/SPC/Coding+Style
diff --git a/img.png b/img.png
deleted file mode 100644
index 0fcd33e..0000000
Binary files a/img.png and /dev/null differ
diff --git a/src/main/resources/codetemplates/handler/golang/manager.go b/src/main/resources/codetemplates/handler/golang/manager.go
index c43dffb..e01078b 100644
--- a/src/main/resources/codetemplates/handler/golang/manager.go
+++ b/src/main/resources/codetemplates/handler/golang/manager.go
@@ -7,11 +7,13 @@ import (
     "errors"
     "test/gofunction"
     "encoding/json"
+    "strings"
 )

 type Response struct {
     StatusCode      int `json:"statusCode"`
     Body            string `json:"body"`
+    Headers         []string `json:"headers"`
 }

 func main() {
@@ -30,12 +32,27 @@ func main() {
             fmt.Println("Response Structure mismatched...");
         }

-        if resp.StatusCode != 0 && resp.Body != "" {
-            w.WriteHeader(resp.StatusCode);
-            fmt.Fprintf(w, resp.Body);
-        } else {
-            fmt.Fprintf(w, response);
+        statusCode := 200;
+        body := response;
+        headers := []string {"Content-Type:application/json"}
+
+        if resp.StatusCode != 0 {
+            statusCode = resp.StatusCode;
+        }
+        if resp.Body != "" {
+            body = resp.Body;
+        }
+        if len(resp.Headers) != 0 {
+            headers = resp.Headers;
         }
+
+        for _, v := range headers {
+            tmp := strings.Split(v, ":");
+            w.Header().Add(tmp[0], tmp[1]);
+        }
+
+        w.WriteHeader(statusCode);
+        fmt.Fprintf(w, body);
     })

     err := http.ListenAndServe(":8080", nil);
diff --git a/src/main/resources/codetemplates/handler/nodejs/manager.js b/src/main/resources/codetemplates/handler/nodejs/manager.js
index f37770f..0f22d2a 100644
--- a/src/main/resources/codetemplates/handler/nodejs/manager.js
+++ b/src/main/resources/codetemplates/handler/nodejs/manager.js
@@ -9,17 +9,27 @@ app.use(express.urlencoded({ extended: true }));
 app.all("/*", async (req, res) => {
     try {
         const response = await nodefunction.handleRequest(req);
+        var statusCode = 200;
+        var body = response;
+        var headers = {'Content-Type': 'application/json'};

-        if (typeof response === "object" && response.statusCode && response.body) {
-            res.set({'Content-Type': 'application/json'});
-            res.status(response.statusCode).send(response.body);
-        } else {
-            res.set({'Content-Type': 'application/json'});
-            res.status(200).send(response);
+        if (typeof response === "object") {
+            if (response.statusCode) {
+                statusCode = response.statusCode;
+            }
+            if (response.body) {
+                body = response.body;
+            }
+            if (response.headers) {
+                headers = response.headers;
+            }
         }
+        res.set(headers);
+        res.status(statusCode).send(body);
+
     } catch (error) {
         console.error('An Error Occurred: ', error);
-        res.status(500).send('Internal Server Error');
+        res.status(500).send(error);
     }
 })

diff --git a/src/main/resources/codetemplates/handler/php/index.php b/src/main/resources/codetemplates/handler/php/index.php
index b69ad16..7f726e2 100644
--- a/src/main/resources/codetemplates/handler/php/index.php
+++ b/src/main/resources/codetemplates/handler/php/index.php
@@ -5,15 +5,29 @@ $uri = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
 # Route to Function Code (GET, POST, PUT, DELETE, etc)
 try{
     $result = handle_request();
-    header("Content-Type:application/json");

-    if (is_array($result) && array_key_exists('statusCode', $result) && array_key_exists('body', $result)) {
-        http_response_code($result['statusCode']);
-        echo json_encode($result['body']);
-    } else {
-        http_response_code(200);
-        echo json_encode($result);
+    $statusCode = 200;
+    $body = $result;
+    $headers = array("Content-Type:application/json");
+
+    if (is_array($result)) {
+        if (array_key_exists('statusCode', $result)) {
+            $statusCode = $result['statusCode'];
+        }
+        if (array_key_exists('body', $result)) {
+            $body = $result['body'];
+        }
+        if (array_key_exists('headers', $result)) {
+            $headers = $result['headers'];
+        }
+    }
+
+    foreach ($headers as $header) {
+        header($header);
     }
+
+    http_response_code($statusCode);
+    echo json_encode($body);
 }
 catch (\Exception $e) {
     http_response_code(500);
diff --git a/src/main/resources/codetemplates/handler/python/manager.py b/src/main/resources/codetemplates/handler/python/manager.py
index 69d84b5..1fb9c10 100644
--- a/src/main/resources/codetemplates/handler/python/manager.py
+++ b/src/main/resources/codetemplates/handler/python/manager.py
@@ -12,13 +12,24 @@ HTTP_METHODS = ['GET', 'HEAD', 'POST', 'PUT', 'DELETE', 'CONNECT', 'OPTIONS', 'T
 def function_route(path):
     try:
         data = pythonfunction.handle_request(request)
-        if type(data) is dict and data['statusCode'] is not None and data['body'] is not None:
-            return Response(data['body'], status=data['statusCode'], mimetype='application/json')
-        else:
-            return Response(data, status=200, mimetype='application/json')
+
+        statusCode = 200
+        body = data
+        headers = {'Content-Type' : 'application/json'}
+
+        if 'statusCode' in data:
+            statusCode = data['statusCode']
+        if 'body' in data:
+            body = data['body']
+        if 'headers' in data:
+            headers = data['headers']
+
+        return Response(body, status=statusCode, headers=headers)
+
     except Exception as e:
         print('An Error Occurred: ', e)
         return Response('Internal Server Error', status=500, mimetype='text/plain')
+
 # DO NOT DELETE BELOW LINES #
 if __name__ == '__main__':
     app.run(host="0.0.0.0", port="8080")
\ No newline at end of file

