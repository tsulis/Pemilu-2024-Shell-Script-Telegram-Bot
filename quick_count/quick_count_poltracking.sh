#!/bin/bash


BOT_TOKEN="YOUR_BOT_TOKEN"
CHAT_ID="YOUR_CHAT_ID"

# URL of the JSON endpoint
URL="https://www.cnnindonesia.com/api/v2/external/pemilu2024?path=pilpres/2024/qc/summary/26"

send_message() {
    local message="$1"
    curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage?parse_mode=HTML" -d "chat_id=$CHAT_ID" -d text="$message" >/dev/null
}

JSON_DATA=$(curl -s "$URL")

# Extract relevant information using jq
nama_lembaga=$(echo "$JSON_DATA" | jq -r '.data.nama_lembaga')
data_masuk=$(echo "$JSON_DATA" | jq -r '.data.intdatamasuk')
last_update=$(echo "$JSON_DATA" | jq -r '.data.dtlastupdate')

count=1

formatted_perolehan=""
while IFS= read -r line; do
    formatted_perolehan+="$count: $line%0A%0A"
    ((count++))
done < <(echo "$JSON_DATA" | jq -r '.data.perolehan[] | "\(.nama_capres) - \(.nama_cawapres): \(.inthasil)%"')

# Stringify the message variable
message="✅ <b>Quick Count: $nama_lembaga</b>%0AData Masuk (%): $data_masuk%0AUpdate Terakhir : $last_update"%0A%0A"$formatted_perolehan"

echo -e "$message"
send_message "$message"