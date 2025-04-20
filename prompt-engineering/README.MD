# Prompt Engineering 

## What & Why
- there is an automated system to revise and improve upon these prompts. 
- it is based on PullRequests - so if you want to make a manual change, do so through typical GitHub processes. 
- Datasources: often 2 or more prompts
- User Stories: 1 or more 
- Operations Workflows: 1 or more

## Miro reference
- https://miro.com/app/board/uXjVLAtnvdw=/?moveToWidget=3458764611025416236&cot=14

## Naming Convention 
- Example: ds-github-yellow-cat-running-v1.0.yaml

### Component Types
- DS: Datasource
- US: User Story
- OPS: Operations

### Component Name
- github
- kaggle
- youtube
- semanticscholar
- googlescholar
- alpaca


### Arbitrary Name
- color, animal, verb

### Version Number
- always V
- Major (DOT) MINOR





## Contents Example


```
timestamp: "2024-12-18T12:00:00"
name: ds-semanticscholar-brown-dog-jumping-v1.0
prompt: "Explain the concept of LASSO regression in simple terms."
config:
  model: "gpt-4"
  temperature: 0.7
  max_tokens: 200
  top_p: 0.9
  frequency_penalty: 0.0
  presence_penalty: 0.0



```

## in code, usage 


```
import openai
import yaml
from datetime import datetime

# Load the configuration from the YAML file
def load_config(file_path):
    with open(file_path, "r") as file:
        return yaml.safe_load(file)

# Function to send the request to OpenAI API
def send_prompt_request(config):
    prompt = config["prompt"]
    model_config = config["config"]
    
    # Send request to OpenAI
    response = openai.ChatCompletion.create(
        model=model_config["model"],
        messages=[{"role": "user", "content": prompt}],
        temperature=model_config["temperature"],
        max_tokens=model_config["max_tokens"],
        top_p=model_config["top_p"],
        frequency_penalty=model_config["frequency_penalty"],
        presence_penalty=model_config["presence_penalty"],
    )
    
    # Extract and return the response
    return response['choices'][0]['message']['content']

# Main function
if __name__ == "__main__":
    # Path to the YAML configuration file
    config_file = "prompt_config.yaml"
    
    # Load configuration
    prompt_config = load_config(config_file)
    
    # Log timestamp of the request
    prompt_config["timestamp"] = datetime.now().isoformat()

    # Send the prompt to OpenAI
    openai.api_key = "your-api-key-here"  # Replace with your OpenAI API key
    response = send_prompt_request(prompt_config)
    
    # Print and save the response
    print("Response:", response)
    prompt_config["response"] = response

    # Save updated configuration back to the YAML file
    with open(config_file, "w") as file:
        yaml.safe_dump(prompt_config, file)

```