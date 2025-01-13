use std::process::Command;
use std::thread::sleep;
use std::time::Duration;
use std::io::{BufRead};
use reqwest::blocking::Client;
use sys_info::hostname;

fn main() {
    let client = Client::new();
    let hostname = hostname().unwrap_or_else(|_| "unknown".to_string());

    loop {
        let mut metrics = String::new();

        // Run `ps aux` command
        let output = Command::new("ps")
            .arg("aux")
            .output()
            .expect("Failed to execute ps command");

        if !output.status.success() {
            eprintln!("Error: Failed to execute ps aux");
            continue;
        }

        let stdout = String::from_utf8_lossy(&output.stdout);

        for (i, line) in stdout.lines().enumerate() {
            if i == 0 || line.contains("ps aux") || line.contains(&std::process::id().to_string()) {
                continue;
            }

            let fields: Vec<&str> = line.split_whitespace().collect();
            if fields.len() < 11 {
                continue;
            }

            let pid = fields[1];
            let cpu_usage = fields[2];
            let mem_usage = fields[3];
            let process = fields.get(10).unwrap_or(&"Unknown");

            metrics.push_str(&format!(
                "cpu_usage{{process=\"{}\", pid=\"{}\"}} {}\n",
                process, pid, cpu_usage
            ));
            metrics.push_str(&format!(
                "mem_usage{{process=\"{}\", pid=\"{}\"}} {}\n",
                process, pid, mem_usage
            ));
        }

        println!("{}  {}", hostname, metrics);

        let url = format!(
            "http://localhost:9091/metrics/job/system_metrics/instance/{}",
            hostname
        );

        match client.post(&url)
            .header("Content-Type", "text/plain")
            .body(metrics)
            .send() 
        {
            Ok(response) => {
                if !response.status().is_success() {
                    eprintln!("Failed to post metrics: {}", response.status());
                }
            }
            Err(e) => eprintln!("Failed to send request: {}", e),
        }

        sleep(Duration::from_secs(30));
    }
}
