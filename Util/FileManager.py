import os


def export_file(file_path, content):
    # 현재 실행 파일의 디렉토리 얻기
    base_dir = os.path.dirname(os.path.abspath(__file__))

    # 절대 경로로 변환 및 정규화
    absolute_path = os.path.normpath(os.path.join(base_dir, file_path))
    # 상대 경로 설정하기
    try:
        print(absolute_path)
        with open(absolute_path, 'w', encoding='utf-8') as file:
            file.write(content)
        print(f"데이터가 {absolute_path}에 성공적으로 기록되었습니다.")
    except Exception as e:
        print(f"파일을 쓰는 동안 오류가 발생했습니다: {e}")
