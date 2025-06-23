# Create .log directory if it doesn't exist

# Where logs
LOG_DIR="$HOME/Logs"
if [[ ! -d "$LOG_DIR" ]]; then
    mkdir -p "$LOG_DIR"
fi

# Load .env overrides if they exist
ENV_FILE="$HOME/.env"
if [[ -f "$ENV_FILE" ]]; then
  while IFS='=' read -r key value; do
    [[ "$key" =~ ^\s*# || -z "$key" ]] && continue
    key="${key// /}"  # Trim spaces from key
    value="${value#"${value%%[![:space:]]*}"}"
    value="${value%"${value##*[![:space:]]}"}"
    case "$key" in
      USERNAME) ENV_USERNAME="$value" ;;
      SOURCE_IP) ENV_SOURCE_IP="$value" ;;
      HOSTNAME) ENV_HOSTNAME="$value" ;;
      DOMAIN) ENV_DOMAIN="$value" ;;
    esac
  done < "$ENV_FILE"
fi

# Define CSV filename dynamically
LOG_DATE=$(date '+%Y-%m-%d')
LOG_USER="${ENV_USERNAME:-$(whoami)}"
LOG_FILE="$LOG_DIR/${LOG_USER}_${LOG_DATE}_command_log.csv"

# Initialize CSV file with header if it doesn't exist
if [[ ! -f "$LOG_FILE" ]]; then
  echo "start_time,end_time,username,source_ip,hostname,destination,command,duration,status" > "$LOG_FILE"
fi

# --- Command start ---
log_command_start() {
  CMD_START_EPOCH=$(date +%s)
  CMD_START_HUMAN=$(date '+%Y-%m-%d %H:%M:%S')
  LAST_COMMAND="$1"
  CMD_STARTED=true
}

# --- Command end ---
log_command_end() {
  local exit_code=$?
  [[ -z "$CMD_STARTED" || -z "$LAST_COMMAND" ]] && return
  unset CMD_STARTED

  CMD_END_EPOCH=$(date +%s)
  CMD_END_HUMAN=$(date '+%Y-%m-%d %H:%M:%S')
  local duration=$((CMD_END_EPOCH - CMD_START_EPOCH))

  local cmd_status=""
  if [[ $exit_code -eq 0 ]]; then
    cmd_status="Success"
  elif [[ $exit_code -eq 130 ]]; then
    cmd_status="Interrupted"
  elif (( exit_code > 128 )); then
    sig=$(( exit_code - 128 ))
    cmd_status="Killed (SIG$sig)"
  else
    cmd_status="Failed"
  fi

  local ip="${ENV_SOURCE_IP:-$(hostname -I | awk '{print $1}')}"
  local host="${ENV_HOSTNAME:-$(hostname)}"
  local custom_domain="$ENV_DOMAIN"

  # Destination 
  destination="local"
  if [[ "$LAST_COMMAND" =~ ([0-9]{1,3}(\.[0-9]{1,3}){3}(/[0-9]{1,2})?) ]]; then
    destination="${match[1]}"
  elif [[ "$LAST_COMMAND" =~ ([a-zA-Z0-9._-]+\.[a-zA-Z]{2,}) ]]; then
    candidate="${match[1]}"
    if [[ -n "$custom_domain" && "$candidate" == *".$custom_domain" ]]; then
      destination="$candidate"
    elif [[ -z "$custom_domain" ]]; then
      destination="$candidate"
    fi
  fi

  # Log to CSV
  echo "$CMD_START_HUMAN,$CMD_END_HUMAN,$LOG_USER,$ip,$host,$destination,\"$LAST_COMMAND\",${duration}s,$cmd_status" >> "$LOG_FILE"
  echo "$CMD_START_HUMAN,$CMD_END_HUMAN,$LOG_USER,$ip,$host,$destination,\"$LAST_COMMAND\",${duration}s,$cmd_status"
  unset LAST_COMMAND
}

# Hook into Zsh events
autoload -Uz add-zsh-hook
add-zsh-hook preexec log_command_start
add-zsh-hook precmd log_command_end