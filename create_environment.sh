#!/bin/bash

# Prompt user for their name
read -p "Enter your name: " user_name

# Define main directory with the user's name
main_dir="submission_reminder_${user_name}"

# Create directory structure
mkdir -p "$main_dir/config"
mkdir -p "$main_dir/modules"
mkdir -p "$main_dir/app"
mkdir -p "$main_dir/assets"

# Create necessary files
touch "$main_dir/config/config.env"
touch "$main_dir/assets/submissions.txt"
touch "$main_dir/app/reminder.sh"
touch "$main_dir/modules/functions.sh"
touch "$main_dir/startup.sh"
touch "$main_dir/README.md"

# Create  config.env
echo "Creating confing.env..."
cat << EOF > "$main_dir/config/config.env"
# This is the config file
ASSIGNMENT="Shell Navigation"
DAYS_REMAINING=2
EOF

# Create submissions.txt
echo "Creating submissions.txt with student records..."
cat << EOF > "$main_dir/assets/submissions.txt"
student, assignment, submission status
Mugabo, Shell Navigation, not submitted
Iteka, Git, submitted
Divine, Shell Navigation,not submitted
Gaju, Shell Basics, submitted
Arnold, Shell Navigation, not submitted
Christian, Shell Navigation, not submitted
Burns, Shell Navigation, not submitted
Arya, Shell Navigation, not submitted
Valverde, Shell Navigation, submitted
Alvin, Git, submitted
King, Shell Basics, submitted  
EOF

# Create functions.sh
echo "Creating functions.sh..."
cat << 'EOF' > "$main_dir/modules/functions.sh"
#!/bin/bash

# Function to read submissions file and output students who have not submitted
function check_submissions() {
    local submissions_file=$1
    echo "Checking submissions in $submissions_file..."

    if [ ! -f "$submissions_file" ]; then
         echo "Error: Submissions file not found!"
         exit 1

    # Skip the header and iterate through the lines
    while IFS=, read -r student assignment status; do
        # Remove leading and trailing whitespace
        student=$(echo "$student" | xargs)
        assignment=$(echo "$assignment" | xargs)
        status=$(echo "$status" | xargs)

        # Check if assignment matches and status is 'not submitted'
        if [[ "$assignment" == "$ASSIGNMENT" && "$status" == "not submitted" ]]; then
            echo "Reminder: $student has not submitted the $ASSIGNMENT assignment!"
        fi
    done < <(tail -n +2 "$submissions_file") # Skip the header
}
EOF

# Create reminder.sh
echo "Creating reminder.sh"
cat << 'EOF' > "$main_dir/app/reminder.sh"
#!/bin/bash

# Source environment variables and helper functions
source ./config/config.env
source ./modules/functions.sh

# Path to the submissions file
submissions_file="./assets/submissions.txt"

# Print remaining time and run the reminder function
echo "Assignment: $ASSIGNMENT"
echo "Days remaining to submit: $DAYS_REMAINING days"
echo "--------------------------------------------"

check_submissions $submissions_file
EOF

# Create startup.sh
echo "Creating startup.sh..."
cat << 'EOF' > "$main_dir/startup.sh"
#!/bin/bash

# Load environment variables and functions
source ./config/config.env
source ./modules/functions.sh

# Path to submission file
submissions_file="./assets/submissions.txt"

# Check if submissions file exists
if [ ! -f "$submissions_file" ]; then
    echo "Error: Submissions file ($submissions_file) is missing!"
    exit 1
fi

# Display assignment details from the environment variables
echo "Assignment: $ASSIGNMENT"
echo "Days remaining to submit: $DAYS_REMAINING days"

echo "----------------------------------------------"

# Call the function to check submissions
check_submissions "$submissions_file"

# Final message
echo "Reminder application executed successfully!"
EOF

# Make scripts executable
chmod +x "$main_dir/modules/functions.sh"
chmod +x "$main_dir/startup.sh"
chmod +x "$main_dir/app/reminder.sh"

echo "Setup complete! Running the application..."
cd "$main_dir"
./startup.sh
