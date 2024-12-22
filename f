package com.scf.manager.mvc.service;
import com.nimbusds.jose.JOSEException;
import com.nimbusds.jose.jwk.RSAKey;
import com.nimbusds.jose.jwk.gen.RSAKeyGenerator;
import com.scf.manager.base.domain.FunctionCode;
import com.scf.manager.base.repository.FunctionCodeRepository;
import com.scf.manager.common.enums.TypeEnums;
import com.scf.manager.common.exception.ResourceNotFoundException;
import com.scf.manager.common.util.AppUtil;
import com.scf.manager.common.util.UrlUtil;
import com.scf.manager.mvc.domain.*;
import com.scf.manager.mvc.dto.*;
import com.scf.manager.mvc.repository.*;
import io.fabric8.istio.client.DefaultIstioClient;
import io.fabric8.knative.client.DefaultKnativeClient;
import io.fabric8.knative.serving.v1.Service;
import io.fabric8.knative.serving.v1.ServiceList;
import io.fabric8.kubernetes.api.model.*;
import io.fabric8.kubernetes.client.DefaultKubernetesClient;
import io.fabric8.kubernetes.client.KubernetesClient;
import io.fabric8.kubernetes.client.KubernetesClientException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.io.IOUtils;
import org.apache.commons.lang3.StringUtils;
import org.jetbrains.annotations.NotNull;
import org.json.simple.JSONValue;
import org.json.simple.parser.JSONParser;
import org.json.simple.JSONObject;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.domain.Page;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.CollectionUtils;
import software.amazon.awssdk.auth.credentials.AwsBasicCredentials;
import software.amazon.awssdk.auth.credentials.StaticCredentialsProvider;
import software.amazon.awssdk.core.ResponseInputStream;
import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.services.s3.S3Client;
import software.amazon.awssdk.services.s3.S3Configuration;
import software.amazon.awssdk.services.s3.model.GetObjectRequest;
import software.amazon.awssdk.services.s3.model.HeadObjectRequest;
import software.amazon.awssdk.services.s3.model.HeadObjectResponse;
import software.amazon.awssdk.services.s3.presigner.S3Presigner;
import software.amazon.awssdk.services.s3.presigner.model.GetObjectPresignRequest;
import software.amazon.awssdk.services.s3.presigner.model.PresignedGetObjectRequest;


import javax.crypto.Cipher;
import javax.crypto.Mac;
import javax.crypto.SecretKey;
import javax.crypto.spec.IvParameterSpec;
import javax.crypto.spec.SecretKeySpec;
import javax.net.ssl.HostnameVerifier;
import javax.net.ssl.HttpsURLConnection;
import javax.net.ssl.SSLSession;
import java.io.*;

import com.fasterxml.jackson.databind.ObjectMapper;
import java.net.URI;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.Duration;
import java.util.*;
import java.util.stream.Collectors;

import static com.scf.manager.common.util.JsonUtil.convertJsonToMap;
@Slf4j
@org.springframework.stereotype.Service
@RequiredArgsConstructor
public class KmsService {
    @Value("${SCF_KEY}")
    private String scfEncryptKey;

    // URI
    private static String KMS_API_BASE_URI;
    // END POINT
    private static String KMS_API_DECRYPT = "/kms/v1/decrypt/%s";
    private static String KMS_API_CREATE_DATAKEY = "/kms/v1/datakey/plaintext/%s";
    // 샘플용 KEY TAG
    private static String KEY_NAME;

    private static String accessKey;
    private static String accessSecretKey;
    private static String method;
    private static String headerProjectId;
    private static String headerClientType;
    public JSONObject createDataKey(DataKeyDTO.Register reqDto) throws Exception {
        KMS_API_BASE_URI = reqDto.getEndpointUrl();
        accessKey=reqDto.getAccessKey();
        accessSecretKey=reqDto.getSecretKey();
        method="POST";
        headerProjectId=reqDto.getProjectId();
        headerClientType="OpenApi";
        KEY_NAME = reqDto.getMasterKey();

        // 새로운 데이터 키 생성을 요청
        JSONObject encryptedDataKey = getDataKey();
        return encryptedDataKey;
    }


    private static JSONObject getDataKey() throws Exception {
        String endPoint = String.format(KMS_API_CREATE_DATAKEY, KEY_NAME);
        JSONObject data = new JSONObject();
        data.put("requestPlainKey", false);

        // OpenAPI 호출
        JSONObject respJsonObject = callApi(endPoint, data.toJSONString());
        //return respJsonObject.get("dataKey").toString();
        return respJsonObject;
    }

    private static JSONObject callApi(String endPoint, String data) throws Exception {
        String host = KMS_API_BASE_URI + endPoint;
        String timestamp = Long.toString(System.currentTimeMillis());
        String signature = makeHmacSignature(host, timestamp);
        InputStream in = null;
        BufferedReader reader = null;
        HttpsURLConnection httpsConn = null;

        try {
            // HTTPS URL 연결
            URL url = new URL(host);
            httpsConn = (HttpsURLConnection) url.openConnection();

            // Hostname verification 설정
            httpsConn.setHostnameVerifier(new HostnameVerifier() {
                @Override
                public boolean verify(String hostname, SSLSession session) {
                    // Ignore host name verification. It always returns true.
                    return true;
                }
            });

            httpsConn.setDoInput(true);
            httpsConn.setUseCaches(false);
            httpsConn.setRequestMethod("POST");
            httpsConn.setRequestProperty("X-Cmp-ProjectId", headerProjectId);
            httpsConn.setRequestProperty("X-Cmp-AccessKey", accessKey);
            httpsConn.setRequestProperty("X-Cmp-Signature", signature);
            httpsConn.setRequestProperty("X-Cmp-ClientType", headerClientType);
            httpsConn.setRequestProperty("X-Cmp-Timestamp", timestamp);
            httpsConn.setRequestProperty("Content-Type", "application/json; utf-8");
            httpsConn.setRequestProperty("Accept", "application/json");
            httpsConn.setDoOutput(true); // OutputStream을 사용해서 post body 데이터 전송
            try (OutputStream os = httpsConn.getOutputStream()) {
                byte request_data[] = data.getBytes("utf-8");
                os.write(request_data);
                os.close();
            } catch (Exception e) {
                e.printStackTrace();
            }

        } catch (Exception e) {
            System.out.println("error : " + e);
        } finally {
            if (reader != null) {
                reader.close();
            }
            if (httpsConn != null) {
                httpsConn.disconnect();
            }
        }

        int responseCode = httpsConn.getResponseCode();

        // 호스트 연결
        httpsConn.connect();
        httpsConn.setInstanceFollowRedirects(true);

        // response 반환
        if (responseCode == HttpsURLConnection.HTTP_OK) { // 정상 호출 200
            in = httpsConn.getInputStream();
        } else { // 에러 발생
            in = httpsConn.getErrorStream();
        }

        JSONParser parser = new JSONParser();
        JSONObject repsObj = (JSONObject) parser.parse(new InputStreamReader(in, "UTF-8"));
        String jsonString = repsObj.toString();
        log.info("API call after sonny" + jsonString);
        return repsObj;

    }

    public static String makeHmacSignature(String url, String timestamp) {
        String body = method + url + timestamp + accessKey + headerProjectId + headerClientType;
        String encodeBase64Str;

        try {
            byte[] message = body.getBytes("UTF-8");
            byte[] secretKey = accessSecretKey.getBytes("UTF-8");

            Mac mac = Mac.getInstance("HmacSHA256");
            SecretKeySpec secretKeySpec = new SecretKeySpec(secretKey, "HmacSHA256");
            mac.init(secretKeySpec);
            byte[] hmacSha256 = mac.doFinal(message);
            encodeBase64Str = encodeBase64(hmacSha256);
        } catch (Exception e) {
            throw new RuntimeException("Failed to calculate hmac-sha256", e);
        }

        return encodeBase64Str;
    }

    private static String encodeBase64(byte[] bytesToEncode) {
        return Base64.getEncoder().encodeToString(bytesToEncode);
    }

    private static byte[] decodeBase64(String stringToDecode) {
        return Base64.getDecoder().decode(stringToDecode);
    }

    public String transferEnvEncrypt(DataKeyDTO.envEncrpyt reqDto, String functionKey) throws Exception {
        KMS_API_BASE_URI = reqDto.getEndpointUrl();
        accessKey=reqDto.getAccessKey();
        accessSecretKey=reqDto.getSecretKey();
        method="POST";
        headerProjectId=reqDto.getProjectId();
        headerClientType="OpenApi";
        KEY_NAME = reqDto.getMasterKey();

        // 암호화를 할 데이터 전송
        return encryptEnv(reqDto,functionKey);
    }

    public String encryptEnv(DataKeyDTO.envEncrpyt reqDto, String functionKey) throws Exception {
        Object obj=reqDto.getEnvValue();
        String dataKey=reqDto.getPlainText();
        Map<String, String> envelope = new HashMap<>();

        // 생성된 데이터 키를 AES-CBC 방식으로 암호화
        // Cipher Class 사용
        SecretKey secretKey = new SecretKeySpec(decodeBase64(dataKey), "AES");
        Cipher cipher = Cipher.getInstance("AES/CBC/PKCS5Padding");
        cipher.init(Cipher.ENCRYPT_MODE, secretKey);
        byte[] cipherEnv = cipher.doFinal(obj.toString().getBytes());
        envelope.put("envKey",reqDto.getEnvKey());
        envelope.put("cipherEnv", encodeBase64(cipherEnv));
        envelope.put("functionKey",functionKey);
        envelope.put("masterKey",reqDto.getMasterKey());
        envelope.put("encryptedDataKey",reqDto.getDataKey());

        return encryptWithKey(JSONObject.toJSONString(envelope), scfEncryptKey);
    }

    // 지정된 키를 사용하여 데이터를 AES 알고리즘으로 암호화
    private static String encryptWithKey(String targetData, String managerKey) throws Exception {
        // Base64 디코딩된 키
        byte[] managerKeyBytes = Arrays.copyOf(managerKey.getBytes(StandardCharsets.UTF_8), 16);
        // SecretKey 객체 생성
        SecretKey secretKey = new SecretKeySpec(managerKeyBytes, "AES");
        // Cipher 객체 초기화
        Cipher cipher = Cipher.getInstance("AES");
        cipher.init(Cipher.ENCRYPT_MODE, secretKey);
        // 데이터 암호화
        byte[] encryptedBytes = cipher.doFinal(targetData.getBytes());
        // 암호화된 데이터를 Base64로 인코딩하여 반환
        return encodeBase64(encryptedBytes);
    }

    public String decryptDataKey(String sealedKey) throws Exception {
        String endPoint = String.format(KMS_API_DECRYPT, KEY_NAME);
        JSONObject data = new JSONObject();
        data.put("cipherText", sealedKey);
        JSONObject respJsonObject = callApi(endPoint, data.toJSONString());
        String plaintext = (respJsonObject.get("decryptedData")).toString();
        return plaintext;
    }

    public String transferEnvDecrypt(DataKeyDTO.envDecrpyt reqDto) throws Exception {
        KMS_API_BASE_URI = reqDto.getEndpointUrl();
        accessKey=reqDto.getAccessKey();
        accessSecretKey=reqDto.getSecretKey();
        method="POST";
        headerProjectId=reqDto.getProjectId();
        headerClientType="OpenApi";


        String decryptedEnv = decryptEnv(reqDto.getCipherText());

        return decryptedEnv;
    }

    public String decryptEnv(String cipherText) throws Exception {
        String decryptedCipherText=decryptWithKey(cipherText,scfEncryptKey);
        // JSON 문자열을 Map으로 변환
        Map<String, String> resultMap = convertJsonToMap(decryptedCipherText);

        // "encryptedDataKey"에 해당하는 값을 추출
        String encryptedDataKey = resultMap.get("encryptedDataKey");
        String masterKey = resultMap.get("masterKey");
        String cipherEnv = resultMap.get("cipherEnv");
        KEY_NAME = masterKey;
        String decryptedDataKey = decryptDataKey(encryptedDataKey);
        //TODO 복호화 하는 부분 코딩해야함 - 240611 - Sonny
        // ↓↓↓↓ 복호화 추가 TBD ↓↓↓↓

        //decryptedDataKey를 통해 cipherEnv를 복호화하는 로직 추가 필요

        // ↑↑↑↑ 복호화 추가 TBD ↑↑↑↑

        // 추후 return 값으로 cipherEnv에 대한 복호화 변수값 반환 필요
        return decryptedCipherText;
    }

    private static String decryptWithKey(String targetData, String managerKey) throws Exception {
        // Base64 디코딩된 키
        //byte[] decodedKey = Base64.getDecoder().decode(mangerKey);
        byte[] managerKeyBytes = Arrays.copyOf(managerKey.getBytes(StandardCharsets.UTF_8), 16);
        // SecretKey 객체 생성
        SecretKey secretKey = new SecretKeySpec(managerKeyBytes, "AES");
        // 암호문 Base64 디코딩
        byte[] encryptedBytes = Base64.getDecoder().decode(targetData);
        // Cipher 객체 초기화
        Cipher cipher = Cipher.getInstance("AES");
        cipher.init(Cipher.DECRYPT_MODE, secretKey);

        // 복호화 수행
        byte[] decryptedBytes = cipher.doFinal(encryptedBytes);

        // 복호화된 데이터를 문자열로 변환
        return new String(decryptedBytes);
    }
}
