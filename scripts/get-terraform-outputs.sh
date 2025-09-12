# Function to get Terraform output
get_tf_output() {
    local result

    result=$(terraform -chdir="../" output -json | jq -r ".$1")
    if [[ "$result" == "null" || -z "$result" ]]; then
        echo "Error: Output '$result' is null or empty" >&2
        exit 1
    fi
    echo "$result"
}
