for i in {1..10}; do
  echo "\nSending request $i/100"
  curl -X POST http://localhost:8000/llm
  sleep $(bc -l <<< "scale=2; ${RANDOM}/32767*0.2+0.1")
done