#!/usr/bin/env bash
# https://www.reddit.com/r/swaywm/comments/18czlul/pretty_print_your_sway_tree_bash_script_jq_is_the/

# ansi colors
bold='\033[1m'
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[1;33m'
blue='\033[0;34m'
reset='\033[0m'

r=$((16#58));
g=$((16#5b));
b=$((16#70));
grey="\x1b[38;2;${r};${g};${b}m"

vertical_line="| " 
leaf="\\_"

result=""

# print an output line
print_output() {
    local indent="$2"
    result="${result}${green}${indent}output $1${reset}\n"
}

# print a workspace line
print_workspace() {
    local indent="$2"
    result="${result}${grey}${indent}${leaf}${reset} ${yellow}workspace $1${reset}\n"
}

# print a container or an application line
print_container() {
    local name="$1"
    local pid="$2"
    local type="$3"
    local floating="$4"
    local indent="$5"
    local focused="$6"

    if [[ "$floating" == "true" ]]; then
        floating=" ${reset}(floating)${red}"
    else
        floating=""
    fi

    if [[ "$focused" == "true" ]]; then
        focused=" ${reset}${bold}<< you are here!"
    else
        focused=""
    fi

    if [[ "$pid" != "null" ]]; then
        result="${result}${grey}${indent}${leaf}${red}${floating} $name (pid: $pid)${focused}${reset}\n"
    else
        result="${result}${grey}${indent}${leaf}${blue}${floating} container $type${focused}${reset}\n"
    fi
}

traverse_tree() {
    local nodes="$1"
    local indent="$2"
    local is_last="$3"

    local count
    count=$(grep -c "^  {" <<< "$nodes")
    
    local i
    for (( i=0; i < $count; i++ )); do
        local last_arg="$is_last"
        if [[ $i -ne $((count-1)) ]]; then
            last_arg="false"
        else
            last_arg="true"
        fi

        # build prefix for child nodes
        local new_prefix="$indent"
        if [[ "$last_arg" == "true" ]]; then
            new_prefix="${new_prefix}    "
        else
            new_prefix="${new_prefix}${vertical_line}  "
        fi

        local child
        child=$(jq ".[$i]" <<< "$nodes")

        local type
        type="${child#*\"type\": \"}"
        type="${type%%\"*}"

        local name
        name="${child#*\"name\": \"}"
        name="${name%%\"*}"

        case "$type" in
            output)
                print_output "$name" "$indent"
                traverse_tree "$(jq '.nodes' <<< "$child")" "$new_prefix" "$last_arg"
                ;;
            workspace)
                print_workspace "$name" "$indent"
                traverse_tree "$(jq '.floating_nodes + .nodes' <<< "$child")" "$new_prefix" "$last_arg"
                ;;
            con|floating_con)
                local app_id
                app_id=${child#*\"app_id\": \"}
                app_id=${app_id%%\"*}

                local app_name
                if [[ "$app_id" != "null" ]]; then
                    app_name="$app_id"
                else
                    app_name="$name"
                fi

                # have to use jq on this one due to nesting
                local pid
                pid=$(echo "$child" | jq '.pid')

                local layout
                layout="${child#*\"layout\": \"}"
                layout="${layout%%\"*}"

                local floating_con
                floating_con="${child#*\"type\": \"}"
                floating_con="${floating_con%%\"*}"
                if [[ "$floating_con" == "floating_con" ]]; then
                    floating_con="true"
                else
                    floating_con="false"
                fi
                
                local focused
                focused="${child#*\"focused\": }"
                focused="${focused%%,*}"
                if [[ "$focused" == "true" ]]; then
                    focused="true"
                else
                    focused="false"
                fi

                print_container "$app_name" "$pid" "$layout" "$floating_con" "$indent" "$focused"
                traverse_tree "$(jq '.floating_nodes + .nodes' <<< "$child")" "$new_prefix" "$last_arg"
                ;;
        esac
    done
}

main() {
    local outputs=$(swaymsg -t get_tree | jq '.nodes')
    local count=$(grep -c "^  {" <<< "$outputs")

    local i
    for (( i=0; i < $count; i++ )); do
        local output=$(jq ".[$i]" <<< "$outputs")

        local name="${output#*\"name\": \"}"
        name="${name%%\"*}"

        print_output "$name" ""
        traverse_tree "$(jq '.nodes' <<< "$output")" " " "true"
    done
}

main
echo -ne "$result"
