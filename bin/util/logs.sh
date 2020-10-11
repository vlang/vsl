RED=`tput setaf 1`
GREEN=`tput setaf 2`
YELLOW=`tput setaf 3`
RESET=`tput sgr0`
CHECK="✓"
CROSS="✗"
WARN="⚠"

describe() {
    printf "$1"
    dots=${2:-3}
    for i in $(seq 1 ${dots}); do sleep 0.035; printf "."; done
    sleep 0.035
}

log_warn() {
    message=${1:-"Warning"}
    log="${YELLOW}${WARN} ${message}${RESET}\n"
    printf " ${log}"
    [ -f "$3" ] && printf "$2 ${log}" >> $3
}

log_failed() {
    message=${1:-"Failed"}
    log="${RED}${CROSS} ${message}${RESET}\n"
    printf " ${log}"
    [ -f "$3" ] && printf "$2 ${log}" >> $3
}

log_success() {
    message=${1:-"Success"}
    log="${GREEN}${CHECK} ${message}${RESET}\n"
    printf " ${log}"
    [ -f "$3" ] && printf "$2 ${log}" >> $3
}
