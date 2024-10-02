#!/bin/bash

##############################################################
#     Team number:
#       Student names:
#         1 - Duarte Bento Batista 
#         2 - João Miguel Pereira Lopes 
#         3 - Manuel José Antunes Eusébio
#         4 - Rafael Moreira Nunes 
#
##############################################################
# change the file name:
#   firewall-06.sh
#       06      -> change to the team number
##############################################################


###############################
# Init. of iptables
###############################

IPT=/usr/sbin/iptables

RANGE_PORTOS=1024:65535

echo "Limpeza das Regras e das listas"
# Limpar todas as regras existentes
$IPT -F		#Apaga quaisquer regras anteririores do iptables
$IPT -X		#Apaga quaisquer "funcoes" que sejam criadas com o IPTABLES

echo "Políticas por omissão - Negar TUDO (INPUT,OUTPUT,FOWARD)"
$IPT -P INPUT DROP
$IPT -P OUTPUT DROP
$IPT -P FORWARD DROP

echo "Permitir loopback interface"
$IPT -A INPUT -i lo -j ACCEPT
$IPT -A OUTPUT -o lo -j ACCEPT

#############################
#Inicio das Regras Statefull#
#############################

######################################################
####### Negação de ataques por flood #################
######################################################
echo "Negação de ataques por flood"
$IPT -N protecao_flood
$IPT -A protecao_flood -p icmp -m limit --limit 5/second -j RETURN
$IPT -A proteca80o_flood -p tcp --dport 443 --sport $RANGE_PORTOS -j RETURN #sshttp
#$IPT -A protecao_flood -p tcp --dport 22 --sport $RANGE_PORTOS -j RETURN 
$IPT -A protecao_flood -p tcp -m limit --limit 50/second --limit-burst 100 -j RETURN
$IPT -A protecao_flood -p udp -m limit --limit 10/second --limit-burst 50 -j RETURN
$IPT -A protecao_flood -j DROP

$IPT -A INPUT -p ip -j protecao_flood

######################################################
####### Registo e Negação de pacotes inválidos #######
######################################################
echo "Registo e Negação de pacotes inválidos(IN)"
$IPT -A INPUT -m state --state INVALID -j LOG --log-prefix "(TRAFEGO-INVÁLIDO) " --log-level 4 --log-ip-options --log-tcp-options --log-tcp-sequence
$IPT -A INPUT -m state --state INVALID -j REJECT --reject-with icmp-port-unreachable

echo "Registo e Negação de pacotes inválidos(OUT)"
$IPT -A OUTPUT -m state --state INVALID -j LOG --log-prefix "(TRAFEGO-INVÁLIDO) " --log-level 4 --log-ip-options --log-tcp-options --log-tcp-sequence
$IPT -A OUTPUT -m state --state INVALID -j REJECT --reject-with icmp-port-unreachable


#########################################################
####### Regras Genericas statefull e LOG do Trafego #####
#########################################################

echo "Permitir log do tráfego relacionado e estabelecido"
$IPT -A INPUT -m state --state ESTABLISHED,RELATED  -j LOG --log-prefix "(TRAFEGO-INPUT) " --log-level 4 --log-ip-options --log-tcp-options --log-tcp-sequence

echo "Permitir tráfego relacionado e estabelecido (Regras genericas Statefull)"
$IPT -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
$IPT -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

####################################
####### Funções do tráfego #########
####################################
echo "Lista Personalizada para input"
$IPT -N trafego_input
$IPT -A trafego_input -j LOG --log-prefix "(TRAFEGO-INPUT-NEW-CONNECTION) " --log-level 4 --log-ip-options --log-tcp-options --log-tcp-sequence # Log do Trafico INPUT
$IPT -A trafego_input -p icmp --icmp-type echo-request -m state --state NEW -j ACCEPT #PING
$IPT -A trafego_input -p tcp --dport 80 -m state --state NEW -j ACCEPT #HTTP
$IPT -A trafego_input -p udp --dport 80 -m state --state NEW -j ACCEPT #HTTP3.0
#$IPT -A trafego_input -p tcp --dport 22 -m state --state NEW -j ACCEPT #SSH
$IPT -A trafego_input -p tcp --dport 443 -m state --state NEW -j ACCEPT #SSHTTPS
$IPT -A trafego_input -p udp --dport 443 -m state --state NEW -j ACCEPT #SSHTTPS3.0

echo "Lista Personalizada para output"
$IPT -N trafego_output
$IPT -A trafego_output -p icmp --icmp-type echo-request -m state --state NEW -j ACCEPT #PING
$IPT -A trafego_output -p udp --dport 53 -m state --state NEW -j ACCEPT #DNS
$IPT -A trafego_output -p tcp --dport 853 -m state --state NEW -j ACCEPT #DNS OVER TLS
$IPT -A trafego_output -p tcp --dport 22 -m state --state NEW -j ACCEPT #SSH
$IPT -A trafego_output -p tcp --dport 9418 -m state --state NEW -j ACCEPT #GIT
$IPT -A trafego_output -p tcp --dport 2375 -m state --state NEW -j ACCEPT #DOCKER
$IPT -A trafego_output -p tcp --dport 2376 -m state --state NEW -j ACCEPT #DOCKER
$IPT -A trafego_output -p tcp --dport 43 -m state --state NEW -j ACCEPT #WHOIS
$IPT -A trafego_output -p tcp --dport 80 -m state --state NEW -j ACCEPT #HTTP
$IPT -A trafego_output -p tcp --dport 443 -m state --state NEW -j ACCEPT #HTTPS




########################################
######### REGRAS INPUT e OUTPUT ########
########################################
echo "Aplicacao das lista personalizada para input"
$IPT -A INPUT -j trafego_input 

echo "Aplicacao das lista personalizada para output"
$IPT -A OUTPUT -j trafego_output







