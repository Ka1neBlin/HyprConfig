#!/bin/bash

sinks_info=$(pactl list sinks | grep -E "Name:|Description:")

declare -A sink_map
rofi_list=""
current_sink=$(pactl get-default-sink)
current_description=""

while IFS= read -r line; do
  if [[ "$line" =~ Name:[[:space:]](.+) ]]; then
    current_name="${BASH_REMATCH[1]}"
  elif [[ "$line" =~ Description:[[:space:]](.+) ]]; then
    current_description="${BASH_REMATCH[1]}"

    if [[ -n "$current_name" && -n "$current_description" ]]; then
      if [[ "$current_name" == "$current_sink" ]]; then
        display_str="✅ $current_description"
      else
        display_str="$current_description"
      fi

      sink_map["$display_str"]="$current_name"
      rofi_list+="$display_str\n"

      current_name=""
      current_description=""
    fi
  fi
done <<< "$sinks_info"

chosen=$(echo -e "$rofi_list" | rofi -dmenu -i -p "Вывод звука")

if [[ -n "$chosen" ]]; then
    selected_sink="${sink_map[$chosen]}"
    
    if [[ -n "$selected_sink" ]]; then
        # Устанавливаем новое устройство по умолчанию
        pactl set-default-sink "$selected_sink"
        
        # Перемещаем все текущие потоки
        while IFS= read -r input; do
            if [[ -n "$input" ]]; then
                pactl move-sink-input "$input" "$selected_sink"
            fi
        done < <(pactl list short sink-inputs | awk '{print $1}')
        
        # Уведомление
        clean_name=$(echo "$chosen" | sed 's/^✅ //')
        notify-send "🔊 Аудиоустройство" "Переключено на $clean_name" -t 2000
    fi
fi
