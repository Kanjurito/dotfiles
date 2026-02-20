#!/usr/bin/env bash

# Paths
cache_dir="$HOME/.cache/eww/weather"
json_file="${cache_dir}/weather.json"
view_file="${cache_dir}/view_id"

# API Settings
KEY="4e8415587049b7a34ad4e3cc3fd47546"
ID="2624652"
UNIT="metric"

mkdir -p "${cache_dir}"

get_icon() {
    case $1 in
        "50d"|"50n") icon=""; quote="Mist" ;;
        "01d") icon=""; quote="Sunny" ;;
        "01n") icon=""; quote="Clear" ;;
        "02d"|"02n"|"03d"|"03n"|"04d"|"04n") icon=""; quote="Cloudy" ;;
        "09d"|"09n"|"10d"|"10n") icon=""; quote="Rainy" ;;
        "11d"|"11n") icon=""; quote="Storm" ;;
        "13d"|"13n") icon=""; quote="Snow" ;;
        *) icon=""; quote="Unknown" ;;
    esac
    echo "$icon|$quote"
}

get_hex() {
    case $1 in
        "50d"|"50n") echo "#84afdb" ;; # Mist Blue
        "01d") echo "#f9e2af" ;;       # Sunny Yellow
        "01n") echo "#cba6f7" ;;       # Clear Mauve
        "02d"|"02n"|"03d"|"03n"|"04d"|"04n") echo "#bac2de" ;; # Cloudy Gray
        "09d"|"09n"|"10d"|"10n") echo "#74c7ec" ;; # Rain Blue
        "11d"|"11n") echo "#f9e2af" ;; # Storm Yellow/Orange
        "13d"|"13n") echo "#cdd6f4" ;; # Snow White
        *) echo "#cdd6f4" ;;
    esac
}

get_data() {
    forecast_url="http://api.openweathermap.org/data/2.5/forecast?APPID=${KEY}&id=${ID}&units=${UNIT}"
    forecast=$(curl -sf "$forecast_url")

    if [ ! -z "$forecast" ]; then
        dates=$(echo "$forecast" | jq -r '.list[].dt_txt | split(" ")[0]' | uniq | head -n 5)
        
        final_json="["
        counter=0
        
        for d in $dates; do
            day_data=$(echo "$forecast" | jq "[.list[] | select(.dt_txt | startswith(\"$d\"))]")

            # Daily Stats
            f_max_temp=$(echo "$day_data" | jq '[.[].main.temp_max] | max | round')
            f_min_temp=$(echo "$day_data" | jq '[.[].main.temp_min] | min | round')
            
            # NEW: Feels Like
            f_feels_like=$(echo "$day_data" | jq '[.[].main.feels_like] | max | round')

            f_pop=$(echo "$day_data" | jq '[.[].pop] | max')
            f_pop_pct=$(echo "$f_pop * 100" | bc | cut -d. -f1)
            f_wind=$(echo "$day_data" | jq '[.[].wind.speed] | max | round')
            f_hum=$(echo "$day_data" | jq '[.[].main.humidity] | add / length | round')
            
            # Icon
            f_code=$(echo "$day_data" | jq -r '.[length/2 | floor].weather[0].icon')
            f_desc=$(echo "$day_data" | jq -r '.[length/2 | floor].weather[0].description' | sed -e "s/\b\(.\)/\u\1/g")
            f_icon_data=$(get_icon "$f_code")
            f_icon=$(echo "$f_icon_data" | cut -d'|' -f1)
            f_hex=$(get_hex "$f_code")
            
            f_day=$(date -d "$d" "+%a")
            f_full_day=$(date -d "$d" "+%A")
            f_date_num=$(date -d "$d" "+%d %b")

            # Hourly Slots
            hourly_json="["
            count_slots=$(echo "$day_data" | jq '. | length')
            count_slots=$((count_slots-1))
            
            for i in $(seq 0 1 $count_slots); do
                slot_item=$(echo "$day_data" | jq ".[$i]")
                s_temp=$(echo "$slot_item" | jq ".main.temp" | cut -d. -f1)
                s_dt=$(echo "$slot_item" | jq ".dt")
                s_time=$(date -d @$s_dt "+%H:%M")
                s_code=$(echo "$slot_item" | jq -r ".weather[0].icon")
                s_hex=$(get_hex "$s_code")
                s_icon=$(get_icon "$s_code" | cut -d'|' -f1)
                
                hourly_json="${hourly_json} {\"time\": \"${s_time}\", \"temp\": \"${s_temp}\", \"icon\": \"${s_icon}\", \"hex\": \"${s_hex}\"},"
            done
            hourly_json="${hourly_json%,}]"

            final_json="${final_json} {
                \"id\": \"${counter}\",
                \"day\": \"${f_day}\",
                \"day_full\": \"${f_full_day}\",
                \"date\": \"${f_date_num}\",
                \"max\": \"${f_max_temp}\",
                \"min\": \"${f_min_temp}\",
                \"feels_like\": \"${f_feels_like}\",
                \"wind\": \"${f_wind}\",
                \"humidity\": \"${f_hum}\",
                \"pop\": \"${f_pop_pct}\",
                \"icon\": \"${f_icon}\",
                \"hex\": \"${f_hex}\",
                \"desc\": \"${f_desc}\",
                \"hourly\": ${hourly_json}
            },"
            ((counter++))
        done
        final_json="${final_json%,}]"

        echo "{ \"forecast\": ${final_json} }" > "${json_file}"
    fi
}


# --- MODE HANDLING ---
if [[ "$1" == "--getdata" ]]; then 
    get_data
elif [[ "$1" == "--json" ]]; then
    # 1. Define Cache Limit (e.g., 30 minutes = 1800 seconds)
    CACHE_LIMIT=300

    if [ -f "$json_file" ]; then
        # 2. Check file age
        file_time=$(stat -c %Y "$json_file")
        current_time=$(date +%s)
        diff=$((current_time - file_time))
        
        # 3. If cache is old, update in BACKGROUND (so UI doesn't freeze)
        if [ $diff -gt $CACHE_LIMIT ]; then
            get_data &
        fi
        
        # 4. Print existing cache IMMEDIATELY
        cat "$json_file"
    else
        # 5. No cache exists (first run), must wait
        get_data
        cat "$json_file"
    fi

elif [[ "$1" == "--view-listener" ]]; then
    if [ ! -f "$view_file" ]; then echo "0" > "$view_file"; fi
    tail -F "$view_file"
elif [[ "$1" == "--nav" ]]; then
    # Note: This section is technically unused now that you switched to direct variables, 
    # but kept for compatibility.
    if [ ! -f "$view_file" ]; then echo "0" > "$view_file"; fi
    current=$(cat "$view_file")
    direction=$2
    max_idx=4
    if [[ "$direction" == "next" ]]; then
        if [ "$current" -lt "$max_idx" ]; then
            new=$((current + 1))
            echo "$new" > "$view_file"
        fi
    elif [[ "$direction" == "prev" ]]; then
        if [ "$current" -gt 0 ]; then
            new=$((current - 1))
            echo "$new" > "$view_file"
        fi
    fi
elif [[ "$1" == "--icon" ]]; then cat "$json_file" | jq -r '.forecast[0].icon'
elif [[ "$1" == "--temp" ]]; then t=$(cat "$json_file" | jq -r '.forecast[0].max'); echo "${t}°C"
elif [[ "$1" == "--hex" ]]; then cat "$json_file" | jq -r '.forecast[0].hex'
fi
