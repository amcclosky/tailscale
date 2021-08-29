#!/usr/bin/env bash
if [[ ${TAILSCALE_AUTHKEY:-} ]]; then
  mkdir -p /home/render/.state
  /home/render/tailscaled -socket=/home/render/tailscaled.sock \
    -state=/home/render/.state/tailscaled.state \
    -tun=userspace-networking \
    -socks5-server=localhost:1055 &

  ADVERTISE_ROUTES=${ADVERTISE_ROUTES:-10.0.0.0/8}
  until /home/render/tailscale --socket=/home/render/tailscaled.sock up --authkey="${TAILSCALE_AUTHKEY}" --hostname="${RENDER_SERVICE_NAME}" --advertise-routes="$ADVERTISE_ROUTES"; do
    sleep 0.1
  done
  export ALL_PROXY=socks5://localhost:1055/
  tailscale_ip=$(/home/render/tailscale --socket=/home/render/tailscaled.sock ip)
  echo "Tailscale is up at IP ${tailscale_ip}"
fi
