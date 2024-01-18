#!/bin/bash

REPOSITORY=/home/ubuntu
PROJECT_NAME=app
JAR_PATH="/home/ubuntu/$PROJECT_NAME/build/libs/cicd-0.0.1-SNAPSHOT.jar"

#echo "> Build 파일 복사"
#cp $REPOSITORY/zip/*.jar $REPOSITORY/

echo "> 현재 구동중인 애플리케이션 pid 확인"
# 수행 중인 애플리케이션 프로세스 ID => 구동 중이면 종료하기 위함
CURRENT_PID=$(pgrep -fl $PROJECT_NAME | grep jar | awk '{print $1}')

echo "현재 구동중인 어플리케이션 pid: $CURRENT_PID"
if [ -z "$CURRENT_PID" ]; then
    echo "> 현재 구동중인 애플리케이션이 없으므로 종료하지 않습니다."
else
    echo "> kill -15 $CURRENT_PID"
    kill -15 $CURRENT_PID
    sleep 5
fi

echo "> 새 어플리케이션 배포"
#JAR_NAME=$(ls -tr $REPOSITORY/*.jar | tail -n 1)
echo "> JAR_PATH: $JAR_PATH"

#echo "> $JAR_NAME 에 실행권한 추가"
chmod +x $JAR_PATH # Jar 파일은 실행 권한이 없는 상태이므로 권한 부여

echo "> $JAR_PATH 실행"
nohup java -jar $JAR_PATH >> $APPLICATION_LOG_PATH 2> $DEPLOY_ERR_LOG_PATH &

# nohup 실행 시 CodeDeploy는 무한 대기한다. 이를 해결하기 위해 nohup.out 파일을 표준 입출력용으로 별도로 사용한다.
# 이렇게 하지 않으면 nohup.out 파일이 생성되지 않고 CodeDeploy 로그에 표준 입출력이 출력된다.