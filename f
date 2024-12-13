$ git diff develop...feature-set_headers_in_function|cat
diff --git a/src/main/resources/codetemplates/handler/golang/manager.go b/src/main/resources/codetemplates/handler/golang/manager.go
index c43dffb..5884c9b 100644
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
@@ -30,12 +32,29 @@ func main() {
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
+        }
+
+        parsedHeaders := parseHeaders(headers)
+        for key, values := range parsedHeaders {
+            for _, value := range values {
+                w.Header().Add(key, value)
+            }
         }
+
+        w.WriteHeader(statusCode);
+        fmt.Fprintf(w, body);
     })

     err := http.ListenAndServe(":8080", nil);
@@ -46,4 +65,14 @@ func main() {
         fmt.Printf("Error Starting Golang Server: %s\n", err);
         os.Exit(1);
     }
-}
\ No newline at end of file
+}
+
+// 헤더 파싱을 위한 유틸리티 함수
+func parseHeaders(headers []string) http.Header {
+    parsedHeaders := http.Header{}
+    for _, h := range headers {
+        parts := strings.Split(h, ":")
+        parsedHeaders.Add(strings.TrimSpace(parts[0]), strings.TrimSpace(parts[1]))
+    }
+    return parsedHeaders
+}
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
