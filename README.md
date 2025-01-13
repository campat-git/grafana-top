# **TOP FOR GRAFANA**
**DRAFT**

![App Screenshot](top.png)

Grafana v10.2.6

<pre> 
wget https://github.com/prometheus/prometheus/releases/download/v3.1.0/prometheus-3.1.0.linux-amd64.tar.gz
wget https://github.com/prometheus/node_exporter/releases/download/v1.8.2/node_exporter-1.8.2.linux-amd64.tar.gz
wget https://github.com/prometheus/pushgateway/releases/download/v1.11.0/pushgateway-1.11.0.linux-amd64.tar.gz
</pre>

All the ports for incoming and out got data they should be consistent. 

**ports** 
grafana-server 3000
prometheus server 9092
node_exporter 9093
pushgateway 9091
getbig 9091

**client build**
<pre> 
useradd -s /sbin/nologin node_exporter
useradd -s /sbin/nologin prometheus
useradd -s /sbin/nologin pushgateway
</pre>

<pre> 
git clone git@github.com:campat-git/grafana-top.git
</pre>

<pre> 
cd grafana-top
cp node_exporter.service /usr/lib/systemd/system/
cp pushgateway.service /usr/lib/systemd/system/
cp getbig.service /usr/lib/systemd/system/
systemctl daemon-reload
</pre>

<pre>
cp node_exporter /usr/local/bin/
cp getbig /usr/local/bin/
cp pushgateway /usr/local/bin/
chown node_exporter:node_exporter node_exporter
chown pushgateway:pushgateway pushgateway
</pre>
<pre>
firewall-cmd --zone=public --permanent --add-port=9093/tcp
firewall-cmd --zone=public --permanent --add-port=9091/tcp
firewall-cmd --reload
</pre>

I have included multiple version of the same script in different languages, you only need to pick which one you want to uses. A python version is being worked on.

**getbig versions**  (pick any one)
*perl version needs*
<pre>
dnf install -y perl-LWP-Protocol-https.noarch perl-Sys-Hostname.x86_64
</pre>
*shell version* 
needs nothing

*rust version*
<pre>
dnf install -y cargo
dnf install -y openssl-devel
cargo build --release
cargo fix --bin "getbig" --allow-no-vcs
cp getbig_src/target/release/getbig /usr/local/bin
</pre>

<pre>
systemctl enable --now  node_exporter.service
systemctl enable --now  pushgateway.service
systemctl enable --now  getbig.service
</pre>

*Stress test your system to see if its all working*

<pre>
stress-ng --cpu 0 --timeout 60s
stress-ng --vm 2 --vm-bytes 1G --timeout 60s --verify
</pre>

rebuilding the rust binary 
<pre>
cd src
cargo build --release
</pre>
