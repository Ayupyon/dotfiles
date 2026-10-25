PROXY_URL="http://127.0.0.1:7890"
NO_PROXY_URL="localhost,127.0.0.1,.example.com"

proxy_on() {
    export HTTP_PROXY=$PROXY_URL
    export HTTPS_PROXY=$PROXY_URL
    export NO_PROXY=$NO_PROXY_URL
    export http_proxy=$PROXY_URL
    export https_proxy=$PROXY_URL
    export no_proxy=$NO_PROXY_URL
}

proxy_off() {
    unset HTTP_PROXY HTTPS_PROXY NO_PROXY http_proxy https_proxy no_proxy
}

proxy_status() {
    if [ -z "$HTTP_PROXY" ]; then
        echo "Current proxy status：OFF"
    else
        echo "Current proxy status：ON ($HTTP_PROXY)"
    fi
}

proxy_on

