# prepare Docker for ipv6

echo '''
{
  "ipv6": true,
  "fixed-cidr-v6": "2001:db8:1::/64"
}
''' > /etc/docker/daemon.json

systemctl restart docker 

export PUBLIC_IPV4=$(curl -s http://169.254.169.254/metadata/v1/interfaces/public/0/ipv4/address)

docker run -d \
  --name wireguard \
  --cap-add=NET_ADMIN \
  --cap-add=SYS_MODULE \
  -e PUID=1000 -e PGID=1000 \
  -e TZ=Asia/Jakarta \
  -e SERVERURL=$PUBLIC_IPV4 \
  -e PEERS=laptop,phone,raspi \
  -e PEERDNS=auto \
  -p 51820:51820/udp \
  -v $(pwd)/wireguard_config:/config \
  -v /lib/modules:/lib/modules \
  --sysctl="net.ipv4.ip_forward=1" \
  --sysctl="net.ipv4.conf.all.src_valid_mark=1" \
  --sysctl="net.ipv6.conf.all.disable_ipv6=0" \
  --sysctl="net.ipv6.conf.all.forwarding=1" \
  --sysctl="net.ipv6.conf.default.forwarding=1" \
  --sysctl="net.ipv6.conf.all.proxy_ndp=1" \
  --restart=unless-stopped \
  linuxserver/wireguard

sleep 1m
