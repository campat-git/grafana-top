
DRAFT

![App Screenshot](top.png)

Grafana v10.2.6
wget https://github.com/prometheus/prometheus/releases/download/v3.1.0/prometheus-3.1.0.linux-amd64.tar.gz

wget https://github.com/prometheus/node_exporter/releases/download/v1.8.2/node_exporter-1.8.2.linux-amd64.tar.gz

wget https://github.com/prometheus/pushgateway/releases/download/v1.11.0/pushgateway-1.11.0.linux-amd64.tar.gz


all the ports for incoming and out got data is up to you but should be consistant. 

ports 
grafana-server 3000
prometheus server 9092

node_exporter 9093
pushgateway 9091
getbig 9091

--- client build

useradd -s /sbin/nologin node_exporter
useradd -s /sbin/nologin prometheus
useradd -s /sbin/nologin pushgateway


cp node_exporter.service /usr/lib/systemd/system/
cp pushgateway.service /usr/lib/systemd/system/
cp getbig.service /usr/lib/systemd/system/
systemctl daemon-reload

cp node_exporter /usr/local/bin/
cp getbig /usr/local/bin/
cp pushgateway /usr/local/bin/
chown node_exporter:node_exporter node_exporter
chown pushgateway:pushgateway pushgateway


firewall-cmd --zone=public --permanent --add-port=9093/tcp
firewall-cmd --zone=public --permanent --add-port=9091/tcp
firewall-cmd --reload

-- getbig version 
perl version needs
dnf install -y perl-LWP-Protocol-https.noarch perl-Sys-Hostname.x86_64

shell version needs nothing

rust version
dnf install -y cargo
dnf install -y openssl-devel

cargo build --release
cargo fix --bin "getbig" --allow-no-vcs
cp getbig_src/target/release/getbig /usr/local/bin

systemctl enable --now  node_exporter.service
systemctl enable --now  pushgateway.service
systemctl enable --now  getbig.service


stress test to see if its working

stress-ng --cpu 0 --timeout 60s
stress-ng --vm 2 --vm-bytes 1G --timeout 60s --verify


rebuilding binary 
cd src
cargo build --release
