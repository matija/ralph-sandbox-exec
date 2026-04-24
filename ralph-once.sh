#!/bin/bash

claude --permission-mode acceptEdits "@PRD.md @progress.txt @plans/ \
1. Read the PRD, the progress file, and any plan files in plans/. \
2. If a plan exists for the next task, follow it. Otherwise, find the next incomplete task in the PRD and implement it. \
3. Commit your changes. \
4. Update progress.txt with what you did. \
ONLY DO ONE TASK AT A TIME."
