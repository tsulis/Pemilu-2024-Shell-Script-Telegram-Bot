#!/bin/bash


BOT_TOKEN="YOUR_BOT_TOKEN"
CHAT_ID="YOUR_CHAT_ID"

# Retrieve JSON data from the URL
json_ppwp=$(curl -s https://sirekap-obj-data.kpu.go.id/pemilu/hhcw/ppwp.json)
json_nama=$(curl -s https://sirekap-obj-data.kpu.go.id/pemilu/ppwp.json)

# Check if curl was successful for ppwp.json
if [ $? -ne 0 ]; then
  echo "Failed to retrieve ppwp.json."
  exit 1
fi

# Check if curl was successful for ppwp.json
if [ $? -ne 0 ]; then
  echo "Failed to retrieve ppwp.json."
  exit 1
fi

# Validate JSON data for ppwp.json
if ! jq -e . >/dev/null 2>&1 <<<"$json_ppwp"; then
  echo "Invalid JSON data for ppwp.json."
  exit 1
fi

# Validate JSON data for ppwp.json
if ! jq -e . >/dev/null 2>&1 <<<"$json_nama"; then
  echo "Invalid JSON data for ppwp.json."
  exit 1
fi

# Extract required keys and values from ppwp.json
keys=("100025" "100026" "100027")
values=()
for key in "${keys[@]}"; do
    value=$(jq -r ".chart.\"$key\"" <<< "$json_ppwp")
    values+=("$value")
done

# Extract nama from ppwp.json
nama=()
for key in "${keys[@]}"; do
    nama_val=$(jq -r ".\"$key\".nama" <<< "$json_nama")
    nama+=("$nama_val")
done

# Extract nomor_urut from ppwp.json
nomor_urut=()
for key in "${keys[@]}"; do
    nomor_urut_val=$(jq -r ".\"$key\".nomor_urut" <<< "$json_nama")
    nomor_urut+=("$nomor_urut_val")
done

# Calculate total summary value
total_summary=0
for value in "${values[@]}"; do
    total_summary=$((total_summary + value))
done

# Get the "chart.persen" value
chart_persen=$(jq -r '.chart.persen' <<< "$json_ppwp")

# Get the "ts" value
ts=$(jq -r '.ts' <<< "$json_ppwp")

# Prepare the message content
message="✅ REALTIME KPU ✅ %0A%0ATotal Data Masuk: $chart_persen%%0ALast Update: $ts%0A%0A"
for ((i = 0; i < ${#keys[@]}; i++)); do
    value=${values[i]}
    percentage=$(awk -v value="$value" -v total_summary="$total_summary" 'BEGIN { printf "%.2f", (value * 100 / total_summary) }')
    message+="${nomor_urut[i]}.) ${nama[i]}%0APerolehan: $percentage%%0A%0A"
done

# Telegram Bot API endpoint and your bot token
API_ENDPOINT="https://api.telegram.org/bot$BOT_TOKEN/sendMessage"

# Send message to Telegram bot
curl -s -X POST "$API_ENDPOINT" -d "chat_id=$CHAT_ID" -d "text=$message" > /dev/null
















