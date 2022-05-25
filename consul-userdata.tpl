#!/usr/bin/env bash

apt-get install -y unzip
# apt-get install -y libtool libltdl-dev 

USER="consul"
COMMENT="Hashicorp consul user"
GROUP="consul"
HOME="/srv/consul"

# Detect package management system.
YUM=$(which yum 2>/dev/null)
APT_GET=$(which apt-get 2>/dev/null)

user_rhel() {
  # RHEL user setup
  sudo /usr/sbin/groupadd --force --system $${GROUP}

  if ! getent passwd $${USER} >/dev/null ; then
    sudo /usr/sbin/adduser \
      --system \
      --gid $${GROUP} \
      --home $${HOME} \
      --no-create-home \
      --comment "$${COMMENT}" \
      --shell /bin/false \
      $${USER}  >/dev/null
  fi
}

user_ubuntu() {
  # UBUNTU user setup
  if ! getent group $${GROUP} >/dev/null
  then
    sudo addgroup --system $${GROUP} >/dev/null
  fi

  if ! getent passwd $${USER} >/dev/null
  then
    sudo adduser \
      --system \
      --disabled-login \
      --ingroup $${GROUP} \
      --home $${HOME} \
      --no-create-home \
      --gecos "$${COMMENT}" \
      --shell /bin/false \
      $${USER}  >/dev/null
  fi
}

if [[ ! -z $${YUM} ]]; then
  logger "Setting up user $${USER} for RHEL/CentOS"
  user_rhel
elif [[ ! -z $${APT_GET} ]]; then
  logger "Setting up user $${USER} for Debian/Ubuntu"
  user_ubuntu
else
  logger "$${USER} user not created due to OS detection failure"
  exit 1;
fi

logger "User setup complete"



CONSUL_ZIP="consul.zip"
CONSUL_URL="${consul_url}"
CONSUL_SERVER="${consul_server}"

curl --silent --output /tmp/$${CONSUL_ZIP} $${CONSUL_URL}
unzip -o /tmp/$${CONSUL_ZIP} -d /usr/local/bin/
chmod 0755 /usr/local/bin/consul
chown consul:consul /usr/local/bin/consul
mkdir -pm 0755 /etc/consul.d
mkdir -pm 0755 /opt/consul
chown consul:consul /opt/consul


cat << EOF > /lib/systemd/system/consul.service
[Unit]
Description=consul Agent
Requires=network-online.target
After=network-online.target
[Service]
Restart=on-failure
PermissionsStartOnly=true
ExecStartPre=/sbin/setcap 'cap_ipc_lock=+ep' /usr/local/bin/consul
ExecStart=/usr/local/bin/consul server -config /etc/consul.d
ExecReload=/bin/kill -HUP $MAINPID
KillSignal=SIGTERM
User=consul
Group=consul
Restart=on-failure
RestartSec=42s
[Install]
WantedBy=multi-user.target
EOF


cat << EOF > /etc/consul.d/consul.json
"server": false,
"node_name": "vault-server",
"datacenter": "dc1",
"data_dir": "/var/lib/consul/data",
"bind_addr": "${vault_server}",
"client_addr": "127.0.0.1",
"retry_join": ["${consul_server1}","${consul_server2}", "${consul_server3}"],
"log_level": "DEBUG",
"enable_syslog": true
EOF


sudo chmod 0664 /lib/systemd/system/consul.service
systemctl daemon-reload
sudo chown -R consul:consul /etc/consul.d
sudo chmod -R 0644 /etc/consul.d/*

cat << EOF > /etc/profile.d/consul.sh
export CONSUL_ADDR=http://127.0.0.1:8500
export CONSUL_SKIP_VERIFY=true
EOF

systemctl enable consul
systemctl start consul
