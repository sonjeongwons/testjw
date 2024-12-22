package com.scf.manager.mvc.dto;
import lombok.*;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class DataKeyDTO {

    private String endpointUrl;
    private String projectId;
    private String accessKey;
    private String secretKey;
    private String masterKey;
    private String dataKey;
    private String keyVersion;
    private String plainText;
    private String envKey;
    private String envValue;

    @Data
    @AllArgsConstructor
    @NoArgsConstructor
    @Builder
    public static class Register {
        private String endpointUrl;
        private String projectId;
        private String accessKey;
        private String secretKey;
        private String masterKey;
    }

    @Data
    @AllArgsConstructor
    @NoArgsConstructor
    @Builder
    public static class envEncrpyt {
        private String endpointUrl;
        private String projectId;
        private String accessKey;
        private String secretKey;
        private String masterKey;
        private String dataKey;
        private String plainText;
        private String envKey;
        private String envValue;
    }

    @Data
    @AllArgsConstructor
    @NoArgsConstructor
    @Builder
    public static class envDecrpyt {
        private String endpointUrl;
        private String projectId;
        private String accessKey;
        private String secretKey;
        private String cipherText;
    }

    @Data
    @AllArgsConstructor
    @NoArgsConstructor
    @Builder
    public static class Response {
        private String projectId;
        private String dataKey;
        private String keyVersion;
        private String plainText;
    }
}


@Slf4j
@Service
@RequiredArgsConstructor
public class KmsService {

    @Value("${SCF_KEY}")
    private String scfEncryptKey;

    // URI
    private static final String KMS_API_DECRYPT = "/kms/v1/decrypt/%s";
    private static final String KMS_API_CREATE_DATAKEY = "/kms/v1/datakey/plaintext/%s";

    private String kmsApiBaseUri;
    private String keyName;
    private String accessKey;
    private String accessSecretKey;
    private String method;
    private String headerProjectId;
    private String headerClientType;

    public JSONObject createDataKey(DataKeyDTO.Register reqDto) throws Exception {
        initializeApiConfig(reqDto);
        return callKmsApi(KMS_API_CREATE_DATAKEY, buildCreateDataKeyPayload());
    }

    public String transferEnvEncrypt(DataKeyDTO.envEncrpyt reqDto, String functionKey) throws Exception {
        initializeApiConfig(reqDto);
        Map<String, String> envelope = buildEncryptionEnvelope(reqDto, functionKey);
        return encryptWithKey(convertMapToJson(envelope), scfEncryptKey);
    }

    public String transferEnvDecrypt(DataKeyDTO.envDecrpyt reqDto) throws Exception {
        initializeApiConfig(reqDto);
        String decryptedJson = decryptWithKey(reqDto.getCipherText(), scfEncryptKey);
        Map<String, String> decryptedData = convertJsonToMap(decryptedJson);
        String decryptedDataKey = callDecryptDataKey(decryptedData.get("encryptedDataKey"));
        return decryptEnvValue(decryptedData.get("cipherEnv"), decryptedDataKey);
    }

    // ===== Helper Methods =====

    private void initializeApiConfig(DataKeyDTO.Register reqDto) {
        kmsApiBaseUri = reqDto.getEndpointUrl();
        accessKey = reqDto.getAccessKey();
        accessSecretKey = reqDto.getSecretKey();
        method = "POST";
        headerProjectId = reqDto.getProjectId();
        headerClientType = "OpenApi";
        keyName = reqDto.getMasterKey();
    }

    private JSONObject buildCreateDataKeyPayload() {
        JSONObject data = new JSONObject();
        data.put("requestPlainKey", false);
        return data;
    }

    private Map<String, String> buildEncryptionEnvelope(DataKeyDTO.envEncrpyt reqDto, String functionKey) throws Exception {
        SecretKey secretKey = createSecretKeyFromBase64(reqDto.getPlainText());
        byte[] cipherEnv = encryptData(reqDto.getEnvValue().toString().getBytes(StandardCharsets.UTF_8), secretKey);
        return Map.of(
                "envKey", reqDto.getEnvKey(),
                "cipherEnv", encodeBase64(cipherEnv),
                "functionKey", functionKey,
                "masterKey", reqDto.getMasterKey(),
                "encryptedDataKey", reqDto.getDataKey()
        );
    }

    private JSONObject callKmsApi(String endpointTemplate, JSONObject payload) throws Exception {
        String endpoint = String.format(endpointTemplate, keyName);
        String url = kmsApiBaseUri + endpoint;
        String timestamp = String.valueOf(System.currentTimeMillis());
        String signature = generateHmacSignature(url, timestamp);

        return performHttpPost(url, payload.toJSONString(), buildHeaders(timestamp, signature));
    }

    private Map<String, String> buildHeaders(String timestamp, String signature) {
        return Map.of(
                "X-Cmp-ProjectId", headerProjectId,
                "X-Cmp-AccessKey", accessKey,
                "X-Cmp-Signature", signature,
                "X-Cmp-ClientType", headerClientType,
                "X-Cmp-Timestamp", timestamp,
                "Content-Type", "application/json; utf-8",
                "Accept", "application/json"
        );
    }

    private String callDecryptDataKey(String encryptedDataKey) throws Exception {
        JSONObject payload = new JSONObject();
        payload.put("cipherText", encryptedDataKey);
        JSONObject response = callKmsApi(KMS_API_DECRYPT, payload);
        return (String) response.get("decryptedData");
    }

    private String generateHmacSignature(String url, String timestamp) {
        try {
            String body = method + url + timestamp + accessKey + headerProjectId + headerClientType;
            byte[] message = body.getBytes(StandardCharsets.UTF_8);
            byte[] secretKey = accessSecretKey.getBytes(StandardCharsets.UTF_8);

            Mac mac = Mac.getInstance("HmacSHA256");
            mac.init(new SecretKeySpec(secretKey, "HmacSHA256"));
            return encodeBase64(mac.doFinal(message));
        } catch (Exception e) {
            throw new RuntimeException("Failed to calculate HMAC-SHA256 signature", e);
        }
    }

    private SecretKey createSecretKeyFromBase64(String base64Key) {
        byte[] keyBytes = decodeBase64(base64Key);
        return new SecretKeySpec(keyBytes, "AES");
    }

    private byte[] encryptData(byte[] data, SecretKey secretKey) throws Exception {
        Cipher cipher = Cipher.getInstance("AES/CBC/PKCS5Padding");
        cipher.init(Cipher.ENCRYPT_MODE, secretKey);
        return cipher.doFinal(data);
    }

    private String decryptEnvValue(String encryptedValue, String key) throws Exception {
        SecretKey secretKey = createSecretKeyFromBase64(key);
        byte[] encryptedBytes = decodeBase64(encryptedValue);
        Cipher cipher = Cipher.getInstance("AES/CBC/PKCS5Padding");
        cipher.init(Cipher.DECRYPT_MODE, secretKey);
        return new String(cipher.doFinal(encryptedBytes), StandardCharsets.UTF_8);
    }

    private JSONObject performHttpPost(String url, String body, Map<String, String> headers) throws Exception {
        HttpsURLConnection connection = null;
        try {
            URL endpoint = new URL(url);
            connection = (HttpsURLConnection) endpoint.openConnection();
            connection.setRequestMethod("POST");
            connection.setDoOutput(true);
            headers.forEach(connection::setRequestProperty);

            try (OutputStream os = connection.getOutputStream()) {
                os.write(body.getBytes(StandardCharsets.UTF_8));
            }

            int responseCode = connection.getResponseCode();
            InputStream responseStream = (responseCode == 200)
                    ? connection.getInputStream()
                    : connection.getErrorStream();

            return (JSONObject) new JSONParser().parse(new InputStreamReader(responseStream, StandardCharsets.UTF_8));
        } finally {
            if (connection != null) connection.disconnect();
        }
    }

    private String encryptWithKey(String targetData, String key) throws Exception {
        SecretKey secretKey = createSecretKeyFromBase64(key);
        byte[] encryptedBytes = encryptData(targetData.getBytes(StandardCharsets.UTF_8), secretKey);
        return encodeBase64(encryptedBytes);
    }

    private String decryptWithKey(String encryptedData, String key) throws Exception {
        SecretKey secretKey = createSecretKeyFromBase64(key);
        byte[] encryptedBytes = decodeBase64(encryptedData);
        Cipher cipher = Cipher.getInstance("AES");
        cipher.init(Cipher.DECRYPT_MODE, secretKey);
        return new String(cipher.doFinal(encryptedBytes), StandardCharsets.UTF_8);
    }

    private String encodeBase64(byte[] bytes) {
        return Base64.getEncoder().encodeToString(bytes);
    }

    private byte[] decodeBase64(String base64String) {
        return Base64.getDecoder().decode(base64String);
    }

    private String convertMapToJson(Map<String, String> map) {
        return new JSONObject(map).toJSONString();
    }
}


아래는 기존 코드를 리팩토링한 버전입니다. 리팩토링된 주요 변경사항은 메소드 간 코드 중복 제거, 가독성 개선, 책임 분리, 그리고 클린 코드 원칙 적용에 중점을 두었습니다. 기존 메소드와 인터페이스는 변경하지 않았으며, KmsService 클래스 내부에서만 리팩토링이 수행되었습니다.

메소드별 변경점과 개선 사항
1. createDataKey
코드 중복 제거: API 호출 로직을 callKmsApi 메소드로 분리.
입력 데이터 생성 분리: buildCreateDataKeyPayload 메소드로 API 요청 데이터 생성 책임 분리.
2. transferEnvEncrypt
코드 단순화: 암호화 로직을 buildEncryptionEnvelope와 encryptWithKey로 분리.
데이터 구조 관리 개선: Map을 JSON으로 변환하여 관리.
3. transferEnvDecrypt
복호화 책임 분리: 데이터 키 복호화와 환경 변수 복호화를 별도 메소드(callDecryptDataKey, decryptEnvValue)로 분리.
JSON 처리 개선: 복호화된 데이터를 Map으로 변환해 처리.
공통 개선
HTTP 호출 분리: performHttpPost 메소드로 HTTP POST 요청 처리 로직 분리.
HMAC 생성 개선: generateHmacSignature 메소드로 HMAC 생성 로직 분리.
코드 재사용성 증가: 암호화 및 복호화 로직 통합(encryptData, decryptEnvValue).
