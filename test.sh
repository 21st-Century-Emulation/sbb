docker build -q -t sbb .
docker run --rm --name sbb -d -p 8080:8080 sbb

sleep 5

RESULT=`curl -s --header "Content-Type: application/json" \
  --request POST \
  --data '{"id":"abcd", "opcode":157,"state":{"a":4,"b":1,"c":66,"d":5,"e":15,"h":10,"l":2,"flags":{"sign":false,"zero":false,"auxCarry":false,"parity":false,"carry":true},"programCounter":1,"stackPointer":2,"cycles":0,"interruptsEnabled":true}}' \
  http://localhost:8080/api/v1/execute`
EXPECTED='{"id":"abcd", "opcode":157,"state":{"a":1,"b":1,"c":66,"d":5,"e":15,"h":10,"l":2,"flags":{"sign":false,"zero":false,"auxCarry":true,"parity":false,"carry":false},"programCounter":1,"stackPointer":2,"cycles":4,"interruptsEnabled":true}}'

docker kill sbb

DIFF=`diff <(jq -S . <<< "$RESULT") <(jq -S . <<< "$EXPECTED")`

if [ $? -eq 0 ]; then
    echo -e "\e[32mSBB Test Pass \e[0m"
    exit 0
else
    echo -e "\e[31mSBB Test Fail  \e[0m"
    echo "$RESULT"
    echo "$DIFF"
    exit -1
fi