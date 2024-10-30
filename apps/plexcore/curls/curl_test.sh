curl -X 'POST' \
  'http://localhost:9091/llm/generate' \
  -H 'accept: application/json' \
  -H 'Content-Type: application/json' \
  -d '{
  "utterance": "Hey you!",
  "current_state": "In Progress",
  "previous_state": "",
  "current_task": "Talent entry form",
  "states": {
    "In Progress": "in_progress", 
    "Scheduled": "scheduled",
    "Completed": "completed"
  },
  "tasks": {
     "1": "Talent entry form",
     "2": "Grammar assessment form",
     "3": "Scripted text",
     "4": "Open question",
     "5": "End_of_task"
  },
  "previous_conversation_history": [
    "Hi, this is mi firts comment."
  ]
}'