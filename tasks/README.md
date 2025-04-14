# AI Task Cards

This folder contains task cards for the AI agent to read and execute. Each task is defined in a JSON file with a structured format that the AI can understand and act upon.

## Task File Structure

Each task file follows this JSON structure:

```json
{
  "id": "TASK-XXX",
  "title": "Task Title",
  "status": "TODO | IN_PROGRESS | DONE",
  "priority": "LOW | MEDIUM | HIGH",
  "description": "Detailed description of what needs to be done",
  "acceptance_criteria": [
    "List of criteria to consider the task complete"
  ],
  "ai_instructions": {
    "steps": [
      "Step-by-step instructions for the AI"
    ],
    "file_paths": {
      "key": "path/to/file.ext"
    },
    "additional_notes": "Any other information that might be helpful"
  },
  "created_at": "ISO date",
  "due_date": "ISO date"
}
```

## Task Workflow

1. Create a new task file with a unique ID (e.g., `task_002.json`)
2. Fill in the task details following the structure above
3. Ask the AI to work on the task by referencing the task ID
4. The AI will:
   - Read the task file
   - Follow the instructions
   - Update the task status when complete

## Task Statuses

- `TODO`: Task has been created but not started
- `IN_PROGRESS`: AI is currently working on the task
- `DONE`: Task has been completed and meets all acceptance criteria

## Example Usage

To ask the AI to work on a task:

```
Please work on task TASK-001 to implement the Todo feature
```

The AI will read the corresponding task file and execute the required steps. 