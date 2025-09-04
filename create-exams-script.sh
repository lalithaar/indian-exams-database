#!/bin/bash

# Script to create exam YAML files and GitHub issues for indian-exams-database
# Usage: ./create_exam_files_and_issues.sh

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if required files exist
if [ ! -f "ug-exam-list.txt" ]; then
    echo -e "${RED}Error: ug-exam-list.txt not found!${NC}"
    echo "Please ensure the exam list file exists in the current directory."
    exit 1
fi

if [ ! -f "template.yml" ]; then
    echo -e "${RED}Error: template.yml not found!${NC}"
    echo "Please ensure the template file exists in the current directory."
    exit 1
fi

# Check if gh CLI is installed
if ! command -v gh &> /dev/null; then
    echo -e "${RED}Error: GitHub CLI (gh) is not installed!${NC}"
    echo "Please install GitHub CLI: https://cli.github.com/"
    exit 1
fi

# Check if user is authenticated with gh
if ! gh auth status &> /dev/null; then
    echo -e "${RED}Error: Not authenticated with GitHub CLI!${NC}"
    echo "Please run: gh auth login"
    exit 1
fi

# Create directory structure
echo -e "${BLUE}Creating directory structure...${NC}"
mkdir -p _data/entrance/ug

# Counter for created files and issues
file_count=0
issue_count=0
skip_count=0

echo -e "${BLUE}Starting to create exam files and GitHub issues...${NC}"
echo ""

# Read each exam from the list
while IFS= read -r exam_id; do
    # Skip empty lines
    if [ -z "$exam_id" ]; then
        continue
    fi
    
    # Remove any whitespace
    exam_id=$(echo "$exam_id" | tr -d '[:space:]')
    
    # Define file path
    file_path="_data/entrance/ug/${exam_id}.yml"
    
    # Check if file already exists
    if [ -f "$file_path" ]; then
        echo -e "${YELLOW}⏭️  Skipping $exam_id - file already exists${NC}"
        ((skip_count++))
        continue
    fi
    
    # Create exam file from template
    cp template.yml "$file_path"
    
    # Update the id field in the YAML file
    sed -i "s/^id: \"\"/id: \"$exam_id\"/" "$file_path"
    
    echo -e "${GREEN}✅ Created file: $file_path${NC}"
    ((file_count++))
    
    # Create GitHub issue
    issue_title="Information needed: $exam_id"
    repo_base_url="https://github.com/lalithaar/indian-exams-database/blob/main"
    file_url="$repo_base_url/$file_path"

    issue_body="Please fill out the exam details in \`$file_url\` with verified information from official sources.

## Required Information:
- [ ] Complete basic exam details (name, acronym, description)
- [ ] Fill in categorization (domain, field, specializations)
- [ ] Add exam details (level, conducting body, frequency, mode)
- [ ] Specify eligibility requirements
- [ ] Provide timeline information (application and exam months)
- [ ] **Most Important**: Add verification details with official website and latest notification URL
- [ ] Include relevant keywords for searchability
- [ ] Confirm exam status (active/discontinued/irregular)

## Guidelines:
- Use only **official sources** - websites, notifications, brochures
- Include **proof** - attach/link official notification PDFs or screenshots
- **No hearsay** - if you heard about it from someone, find official confirmation first
- Update \`last_verified\` field with current date (YYYY-MM-DD format)
- Add your GitHub username in \`verified_by\` field

## Template Path:
\`$file_path\`

**Please ensure all information is from official sources and includes verification links!**"
    
    # Create GitHub issue with appropriate labels
    if gh issue create \
        --title "$issue_title" \
        --body "$issue_body" \
        --label "help wanted,good first issue,data needed,entrance-exam" \
        --assignee ""; then

        
        echo -e "${GREEN}🎫 Created GitHub issue for: $exam_id${NC}"
        ((issue_count++))
    else
        echo -e "${RED}❌ Failed to create GitHub issue for: $exam_id${NC}"
    fi
    
    # Small delay to avoid rate limiting
    sleep 0.1
    
done < ug-exam-list.txt

echo ""
echo -e "${BLUE}=== Summary ===${NC}"
echo -e "${GREEN}Files created: $file_count${NC}"
echo -e "${GREEN}Issues created: $issue_count${NC}"
echo -e "${YELLOW}Files skipped (already exist): $skip_count${NC}"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo "1. Review the created files in _data/entrance/ug/"
echo "2. Check the GitHub issues that were created"
echo "3. Start filling out the exam information or invite contributors to help"
echo "4. Consider creating similar scripts for jobs and fellowships"
echo ""
echo -e "${GREEN}✨ Script completed successfully!${NC}"