import time
from typing import Dict, List

def dummy_func(name: str) -> str:
    return f"Helo, my name is {name}"

def generate(
        utterance: str,
        states: Dict[str, str],
        current_state: str,
        previous_state: str,
        tasks: Dict[int, str],
        current_task: str,
        previous_conversation_history: List[str],
    ):
    # print(
    #     utterance,
    #     states,
    #     current_state, 
    #     previous_state,
    #     tasks,
    #     current_task, 
    #     previous_conversation_history
    # )
    t = time.ctime()
    # print(t)
    return str(t)