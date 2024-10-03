# SLSSEI---Setup-Linux-Server-to-be-Secured-Exposed-to-the-Internet

![Diagrama-SLSSEI drawio](https://github.com/user-attachments/assets/ee0b6bef-b5b0-4d7e-ab18-3deda2dff3b8)

---
## Badges
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![standard-readme compliant](https://img.shields.io/badge/readme%20style-standard-brightgreen.svg?style=flat-square)](https://github.com/RichardLitt/standard-readme)

## Table of Contents
  - [Description](#description)
  - [Project development](#project-development)
  - [Technologies used in this work](#technologies-used-in-this-work)
  - [Contributing](#contributing)
  - [License](#license)

## Description

SLSSEI (Setup Linux Server to be Secured Exposed to the Internet) is a project that was developed for the Systems Security curricular unit of Computer Engineering course at the Polytechnic of Leiria. The final grade for this project was 19 (nineteen, on a scale of 0 to 20). The aim of this project was to create and configure a Linux server that would be securely exposed on the Internet. To do this, it was necessary to install and configure it, set up a firewall, and install and configure other mechanisms that would allow the server to be securely exposed on the Internet. After these configurations, the server had to be tested to validate that the configurations really had an effect.

In order to achieve the main objective proposed for this project, it was necessary to:

  - **Install and configure Wordpress on the Linux server**
  
  - **Create and configure digital certificates for HTTPS connections (let's Encrypt)**

  - **Create and configure firewall rules from IPTABLES**
    - IPTABLES should allow the following services to enter the server (IN)
      - *HTTP*
      - *SSH*
      - *ICMP*
    - IPTABLES should allow the following services to leave the server (OUT)
      - *DNS*
      - *DNS over TLS*
      - *ICMP*
      - *SSH*
      - *Git*
      - *Docker*
      - *Whois*
      - *HTTP*
      - *HTTPS*
     
  - **All traffic generated had to be stored in logs, which had to fulfil the following requirements**
      - Carry out traffic logging of all services exposed to the Internet (IN)
      - Log invalid packets, both incoming (IN) and outgoing packets (OUT)
  - **The server should also be protected from flood protection attacks:**
      - Prevent ICMP packets flood whenever higher than 5 per second
      - Prevent UDP packets flood whenever higher than 10 per second, with a tolerance of 50
      - Prevent TCP packets flood whenever higher than 50 per second, with a tolerance of 100, the SSH service must be exception
   
  - **Apply the sshttps mechanism, which allows communication from two different protocols (SSH and HTTP) to be sent to the same port.**
  - **Study an extra security measure of our choice and implement it**

## Project development

### 1 -Setup Server
First of all, in order to have a Linux server available on the Internet, we decided to use Google Cloud, which offers 300 dollars of free credit for 3 months, which is more than enough to carry out this work. With these 300 dollars, we decided to create an Ubuntu 22.04.3 LTS server, with 1 virtual CPU, 4Gb of RAM and 10 Gb of disc, which contains all the necessary functionalities for the development of this project; the monthly cost of this machine was around 30 dollars per month.

![Dashboard Google](https://github.com/user-attachments/assets/b285a5de-3193-4e37-bbc3-68ce1a0c00e3)

### 2 - Create a Domain Name 
Secondly, we had to register a domain in our name so that we could create TLS certificates with ‘let's encrypt’ to use in the HTTPS protocol. To create the domain, we used the domains.pt service where we could obtain the ‘fourkings.pt’ domain free of charge for 1 year.

![dashboardDominios pt](https://github.com/user-attachments/assets/99d3ad02-27f6-45e3-911d-1d0f8ef670ba)

### 3 - Install and configure Apache2 and Wordpress
Thirdly, it was time to set up our web server and for this we installed the Apache 2 server and Wordpress in order to create a website as quickly and efficiently as possible.

The following command was used to install Apache 2

```
sudo apt install apache2
```

Installing Wordpress requires more complex commands, which is why you'll find a tutorial on ["HowToInstallWordpress"](https://github.com/DuarteBatista/SLSSEI---Setup-Linux-Server-to-be-Secured-Exposed-to-the-Internet/blob/main/HowToInstallWordpress.pdf) on how to install it.

### 4 - Create let's encrypt certeficates
Fourthly, it was necessary to create the ‘let's encrypt’ TLS certificates, using the apache certbot implemented in python for this purpose

```
sudo apt install certbot python3-certbot-apache
```

Then we had to run the following command to create the certificate

```
certbot --apache -d <DOMAIN NAME ex:www.fourkings.pt>
```

After that, the default configuration files with the certificates were already created for use in making the site available

![defaultwebfile](https://github.com/user-attachments/assets/83a136fe-3b91-4969-a4c4-60ebb209d6a3)

### 5 - Create a small website 
Fifthly, a small Wordpress website was created just to validate the prototype

![wordpressDashboard](https://github.com/user-attachments/assets/b4932875-182e-4d45-9ad2-4dc811268153)

![fourkingswebsite](https://github.com/user-attachments/assets/490b19e2-dcd5-474e-bc06-cde41440461e)

### 6 - Configure SSH 
Sixthly, the SSH service was configured according to the requested requirements and with some security implementations 

![ssh-configuration](https://github.com/user-attachments/assets/0750a067-c171-4b73-a41c-8408f9ba8967)

### 7 - Configure IPTABLES Firewall
Seventhly, the Firewall was configured using IPTABLES, this configuration can be found in ["Firewall-Rules.sh"](https://github.com/DuarteBatista/SLSSEI---Setup-Linux-Server-to-be-Secured-Exposed-to-the-Internet/blob/main/Firewall-Rules.sh), some examples of the commands applied were

Commands to allow incoming packages

```
IPT=/usr/sbin/iptables
$IPT -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
$IPT -A trafego_input -p tcp --dport 80 -m state --state NEW -j ACCEPT #HTTP
$IPT -A INPUT -j trafego_input
```

Commands to allow outgoing packets

```
IPT=/usr/sbin/iptables
$IPT -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
$IPT -A trafego_output -p tcp --dport 80 -m state --state NEW -j ACCEPT #HTTP
$IPT -A OUTPUT -j trafego_output
```

Commands for making traffic logs

```
IPT=/usr/sbin/iptables
$IPT -A INPUT -m state --state ESTABLISHED,RELATED  -j LOG --log-prefix "(TRAFEGO-INPUT) " --log-level 4 --log-ip-options --log-tcp-options --log-tcp-sequence
```

Commands to prevent flodding of a particular protocol

```
IPT=/usr/sbin/iptables
$IPT -N protecao_flood
$IPT -A protecao_flood -p icmp -m limit --limit 5/second -j RETURN
$IPT -A protecao_flood -p tcp -m limit --limit 50/second --limit-burst 100 -j RETURN
$IPT -A protecao_flood -p udp -m limit --limit 10/second --limit-burst 50 -j RETURN
$IPT -A protecao_flood -j DROP

$IPT -A INPUT -p ip -j protecao_flood
```

### 8 - Test the Server
NMAP was used to carry out the security tests on the server. These tests can be found in the ["Tests-Validate-Firewall"](https://github.com/DuarteBatista/SLSSEI---Setup-Linux-Server-to-be-Secured-Exposed-to-the-Internet/blob/main/Tests-Validate-Firewall.xls)

## Technologies used in this work
- **Google Cloud**
- **Ubuntu Server 22.04.3 LTS**
- **Apache2**
- **Wordpress**
- **Let's Encrypt**
- **SSH**
- **HTTPS**
- **IPTABLES**
- **Domain Names**

## Contributing
This project was developed by:
  - Duarte Bento Batista
  - João Miguel Pereira Lopes
  - Manuel José Antunes Eusébio
  - Rafael Moreira Nunes

## License
[GPL-3.0 license](../LICENSE)

















