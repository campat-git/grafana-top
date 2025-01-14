# **LINUX TOP PROCESS displayed on GRAFANA**

This grafana page displays the top cpu and memory users per application. There are a few other version of this out there, I created this version to make it easy to install. 


![App Screenshot](top.png)

 built for **Grafana v10.2.6**

```sh
wget https://github.com/prometheus/prometheus/releases/download/v3.1.0/prometheus-3.1.0.linux-amd64.tar.gz
wget https://github.com/prometheus/node_exporter/releases/download/v1.8.2/node_exporter-1.8.2.linux-amd64.tar.gz
wget https://github.com/prometheus/pushgateway/releases/download/v1.11.0/pushgateway-1.11.0.linux-amd64.tar.gz
```



**ports**  (can be anything but must be consistant )
- grafana-server 3000
- prometheus server 9092
- node_exporter 9093
- pushgateway 9091
- getbig 9091

**client build**
```sh
useradd -s /sbin/nologin node_exporter
useradd -s /sbin/nologin prometheus
useradd -s /sbin/nologin pushgateway
```

```sh
git clone git@github.com:campat-git/grafana-top.git
```

```sh
cd grafana-top
cp node_exporter.service /usr/lib/systemd/system/
cp pushgateway.service /usr/lib/systemd/system/
cp getbig.service /usr/lib/systemd/system/
systemctl daemon-reload
```

```sh
cp node_exporter /usr/local/bin/
cp getbig /usr/local/bin/
cp pushgateway /usr/local/bin/
chown node_exporter:node_exporter node_exporter
chown pushgateway:pushgateway pushgateway
```
```sh
firewall-cmd --zone=public --permanent --add-port=9093/tcp
firewall-cmd --zone=public --permanent --add-port=9091/tcp
firewall-cmd --reload
```

I have included multiple version of the same script in different languages, you only need to pick which one you want to uses. A python version is being worked on.

**getbig versions**  (pick any one)
*perl version needs*
```sh
dnf install -y perl-LWP-Protocol-https.noarch perl-Sys-Hostname.x86_64
```
*shell version* 
needs nothing

*rust version*
```sh
dnf install -y cargo
dnf install -y openssl-devel
cargo build --release
cargo fix --bin "getbig" --allow-no-vcs
cp getbig_src/target/release/getbig /usr/local/bin
```

```sh
systemctl enable --now  node_exporter.service
systemctl enable --now  pushgateway.service
systemctl enable --now  getbig.service
```

*Stress test your system to see if its all working*

```sh
stress-ng --cpu 0 --timeout 60s
stress-ng --vm 2 --vm-bytes 1G --timeout 60s --verify
```

rebuilding the rust binary 
```
cd src
cargo build --release
```

## License

MIT

