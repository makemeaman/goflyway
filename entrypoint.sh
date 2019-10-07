#! /bin/bash
if [[ -z "${KEY}" ]]; then
  KEY="1b62ec8c-e504-4a50-9f90-2e646636d242"
fi

if [[ -z "${PORT}" ]]; then
  PORT="45874"
fi

if [[ -z "${V2_Path}" ]]; then
  V2_Path="/FreeApp"
fi

rm -rf /etc/localtime
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
date -R

mkdir /goflyway
cd /goflyway
wget --no-check-certificate -qO 'goflyway.tar.gz' "http://github.com/coyove/goflyway/releases/download/2.0.0rc1/goflyway_linux_amd64.tar.gz"
tar -xvzf goflyway.tar.gz
chmod +x goflyway 

SYS_Bit="$(getconf LONG_BIT)"
[[ "$SYS_Bit" == '32' ]] && BitVer='_linux_386.tar.gz'
[[ "$SYS_Bit" == '64' ]] && BitVer='_linux_amd64.tar.gz'

C_VER=`wget -qO- "https://api.github.com/repos/mholt/caddy/releases/latest" | grep 'tag_name' | cut -d\" -f4`
mkdir /caddybin
cd /caddybin
wget --no-check-certificate -qO 'caddy.tar.gz' "https://github.com/mholt/caddy/releases/download/$C_VER/caddy_$C_VER$BitVer"
tar xvf caddy.tar.gz
rm -rf caddy.tar.gz
chmod +x caddy
cd /root
mkdir /wwwroot
cd /wwwroot

wget --no-check-certificate -qO 'demo.tar.gz' "https://github.com/z0day/v2ray-heroku-undone/raw/master/demo.tar.gz"
tar xvf demo.tar.gz
rm -rf demo.tar.gz

cat <<-EOF > /caddybin/Caddyfile
http://0.0.0.0:${PORT}
{
	root /wwwroot
	index index.html
	timeouts none
	proxy ${V2_Path} localhost:2333 {
		websocket
		header_upstream -Origin
	}
}
EOF

cd /goflyway
./goflyway k=1b62ec8c-e504-4a50-9f90-2e646636d242 -l=":45874" &
cd /caddybin
./caddy -conf="Caddyfile"
