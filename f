@Service
@RequiredArgsConstructor
@Slf4j
public class KmsService {

    @Value("${SCF_KEY}")
    private String scfEncryptKey;

    private final KmsApiClient kmsApiClient; // API 호출 전용 클라이언트
    private final EncryptionUtil encryptionUtil; // 암호화 유틸리티

    /**
     * 데이터 키 생성 API 호출 메소드
     */
    public JSONObject createDataKey(DataKeyDTO.Register reqDto) throws Exception {
        KmsApiConfig config = buildApiConfig(reqDto); // 설정 객체 생성
        JSONObject requestData = new JSONObject();
        requestData.put("requestPlainKey", false);

        // KMS API 호출
        return kmsApiClient.callApi(config, config.getCreateDataKeyEndpoint(), requestData);
    }

    /**
     * 환경 변수를 암호화하여 반환
     */
    public String transferEnvEncrypt(DataKeyDTO.envEncrpyt reqDto, String functionKey) throws Exception {
        Map<String, String> envelope = buildEncryptionEnvelope(reqDto, functionKey);
        return encryptionUtil.encryptWithKey(encryptionUtil.toJsonString(envelope), scfEncryptKey);
    }

    /**
     * 환경 변수를 복호화하여 반환
     */
    public String transferEnvDecrypt(DataKeyDTO.envDecrpyt reqDto) throws Exception {
        String decryptedJson = encryptionUtil.decryptWithKey(reqDto.getCipherText(), scfEncryptKey);
        Map<String, String> decryptedData = encryptionUtil.parseJsonToMap(decryptedJson);

        // 데이터 키 복호화
        String decryptedDataKey = kmsApiClient.decryptDataKey(decryptedData.get("encryptedDataKey"));

        // 복호화된 데이터를 반환
        return encryptionUtil.decryptEnvValue(decryptedData.get("cipherEnv"), decryptedDataKey);
    }

    // ====== Helper Methods ======

    private KmsApiConfig buildApiConfig(DataKeyDTO.Register reqDto) {
        return new KmsApiConfig(
                reqDto.getEndpointUrl(),
                reqDto.getAccessKey(),
                reqDto.getSecretKey(),
                reqDto.getProjectId(),
                reqDto.getMasterKey()
        );
    }

    private Map<String, String> buildEncryptionEnvelope(DataKeyDTO.envEncrpyt reqDto, String functionKey) throws Exception {
        SecretKey secretKey = encryptionUtil.createAesKey(reqDto.getPlainText());
        byte[] encryptedEnv = encryptionUtil.encryptData(reqDto.getEnvValue().toString(), secretKey);

        return Map.of(
                "envKey", reqDto.getEnvKey(),
                "cipherEnv", encryptionUtil.encodeBase64(encryptedEnv),
                "functionKey", functionKey,
                "masterKey", reqDto.getMasterKey(),
                "encryptedDataKey", reqDto.getDataKey()
        );
    }
}





리팩토링을 수행하면서 createDataKey, transferEnvEncrypt, transferEnvDecrypt 메소드를 중심으로 코드를 개선하였습니다. 나머지 메소드는 이 세 메소드를 보조하는 방식으로 유지하되, 코드의 가독성과 재사용성을 높이는 방향으로 수정했습니다.

아래는 리팩토링된 코드와 메소드별 변경사항에 대한 상세 설명입니다.



메소드별 변경사항과 개선 이유
1. createDataKey
변경 사항:

설정 객체화: KmsApiConfig 객체를 생성하여 API 설정값을 캡슐화.
중복 코드 제거: KMS API 호출 로직을 KmsApiClient로 분리하여 재사용성을 확보.
가독성 향상: API 요청 데이터 생성과 호출 로직을 분리.
변경 이유:

API 호출에 필요한 설정값(KMS_API_BASE_URI, accessKey 등)을 매번 수동으로 설정하는 중복 코드를 제거.
호출 로직을 별도 유틸리티로 분리해 테스트 및 유지보수를 용이하게 함.
2. transferEnvEncrypt
변경 사항:

암호화 로직 분리: 암호화와 관련된 로직은 EncryptionUtil에서 처리하도록 위임.
캡슐화: 암호화 데이터를 buildEncryptionEnvelope라는 헬퍼 메소드로 분리.
변경 이유:

암호화 로직을 분리함으로써 메소드의 역할을 단순화.
암호화 데이터 생성 과정을 메소드로 분리해 코드 중복 제거 및 재사용성을 확보.
3. transferEnvDecrypt
변경 사항:

복호화 과정 분리: 데이터 복호화 로직을 EncryptionUtil에 위임.
데이터 키 복호화: kmsApiClient.decryptDataKey 메소드를 사용해 데이터 키 복호화를 처리.
데이터 변환: 복호화된 JSON 문자열을 Map으로 변환하여 처리.
변경 이유:

복호화 로직과 메소드의 책임을 분리하여 코드 가독성과 유지보수성을 높임.
복호화된 데이터를 처리하는 과정을 명확히 함.
주요 변경점 요약
KmsApiClient 도입: API 호출과 관련된 모든 로직(callApi, decryptDataKey)을 전담.
EncryptionUtil 도입: 암호화, 복호화, JSON 변환 등 공통 로직을 별도로 분리.
메소드 단순화: 비즈니스 로직과 유틸리티 로직을 명확히 분리하여 각 메소드의 단일 책임을 보장.
헬퍼 메소드 활용: 반복되던 데이터 생성 및 변환 과정을 메소드로 추출.
